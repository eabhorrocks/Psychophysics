%% 1D coherence matlab/unity
% need to write results to a txt file
% https://research.computing.yale.edu/hpc/faq/how-can-i-run-matlab-batch-mode-without-gui
% run w/o a gui would be good.

clear all
set(0,'DefaultFigureWindowStyle','docked')

%% set up TCP socket with Unity

t = tcpip('127.0.0.1',10061,'NetworkRole','Client','Timeout',60);
% t.ReadAsyncMode='continuous';
fopen(t)
t

% send global parameters for experiment
% gp tag, numDots, trial duration, dot lifetime, dot size
fwrite(t, char(['gp, 100, 1, 0.3, 1.5']));

%% Set up stimulus space and response spaces + other opts
% xx is stimulus space
% y is response space

% Coherence Space
cohOrig = [1, 2, 4, 6, 8, 10, 15, 20, 25, 35, 50, 60, 70, 80, 90, 100]; %add 0 to here so doesnt hang...
cohFlip = fliplr(cohOrig * -1);
cohVec = [cohFlip, cohOrig];
cohstd = cohVec/std(cohVec); % normalise to have std of 1, mean of 0
xx = cohstd'; % stimulus space is column vector of coherence from -100 to 100
rxx = cohVec; % real un-normalised coherences.

% Velocity Space
Velocities = [10 25 40];
Walk = [1]; % [1 2];

% RESPONSE SPACE
yvalslist = [0 1];

dims.y = numel(yvalslist)-1; % degrees of freedom of response space
dims.g = numel(gfun(xx(1,:))); % degrees of freedom of internal feature vector of stim
K0 = dims.y * dims.g;


% Other options
% === Specify algorithms to use =====================

% Select inference method (either MAP or MCMC)
nsamples = 0; % MCMC chain length
doingMAP = (nsamples==0); % if 0, we make MAP estimate;
doingMCMC = (nsamples>0); % if >0, we run MCMC sampling.

% Set prior hyperpameters
hyperprs = ...
    struct('wgtmean',0,'wgtsigma',3,... % gaussian prior for weights
    'lpsLB',log(0.001),'lpsUB',0, ... % range constraints for lapses
    'lpsInit',-5 ... % starting point for lapse parameters
    );

% Set whether to include lapses in the model being inferred
withLapse = 0; % 1: use lapse-aware model, 0: ignore lapse
% Unpack parameter dimensions
ydim = dims.y;
gdim = dims.g;
if(withLapse==1)
    udim = ydim+1; % lapse parameter length (equal to # choices)
else
    udim = 0; % no lapse parameter
end

% a human-readable string to remind what we do in this simulation
inftagList = {'Laplace',['MCMC',num2str(nsamples)]};
inftag = inftagList{doingMCMC+1}; % if not MCMC, then MAP
algtag = 'infomax';
withLapseTagList = {'lapse-unaware','lapse-aware'};
lpstag = withLapseTagList{withLapse+1};
runTag = [algtag,'-',inftag];

% === Pack options for sequential experiment =======

optSeq = [];
% parameter initialization, bounds and step sizes
K0 = ydim*gdim;
prsInit = [(hyperprs.wgtmean)*ones(K0,1); ...
    (hyperprs.lpsInit)*ones(udim,1)]; % initial value for parameters
optSeq.prs0 = prsInit(:)';
optSeq.prsInit = prsInit(:)'; % duplicate for re-initialization
optSeq.prsLB = [-Inf*ones(K0,1); (hyperprs.lpsLB)*ones(udim,1)]'; % lower bound
optSeq.prsUB = [Inf*ones(K0,1); (hyperprs.lpsUB)*ones(udim,1)]'; % upper bound
optSeq.steps = ones(1,numel(prsInit)); % initial step sizes
% numbers for MCMC samplings
optSeq.nsamples = nsamples; % length of chain
optSeq.nburn = 500; % # samples for "burn-in"
optSeq.nburnInit = 500; % duplicate for re-initialization
optSeq.nburnAdd = 50; % burn-in for additional runs
% more options
optSeq.prior = hyperprs;
optSeq.reportMoreValues = false;
optSeq.talkative = 1; % display level




%% generate initial trials
cohini = [-70, -35, -10, 10, 35, 70];
for i = 1:numel(cohini)
    cohinirxx(i) = find(rxx==cohini(i));
end

nRepsini = 1;
velini = Velocities;
walkini = 1;
iniTriPars = combvec(cohinirxx, velini, walkini);
iniTriPars = repmat(iniTriPars, 1, nRepsini);
nIni = length(iniTriPars);

iniTrials = iniTriPars(:, randperm(size(iniTriPars,2)));
vel1idx = find(iniTrials(2,:)==velini(1));
vel2idx = find(iniTrials(2,:)==velini(2));
vel3idx = find(iniTrials(2,:)==velini(3));

% set initial data points.
cond(1,1).iinit = iniTrials(1,vel1idx)'; % iinit just coherences?
cond(2,1).iinit = iniTrials(1,vel2idx)';
cond(3,1).iinit = iniTrials(1,vel3idx)';

cond(1,1).xinit = xx(cond(1,1).iinit); % iinit just coherences?
cond(2,1).xinit = xx(cond(2,1).iinit);
cond(3,1).xinit = xx(cond(3,1).iinit);

nConds = numel(cond);

figure,
for icon = 1:nConds
    subplot(nConds,1,icon)
    hold on, xlim([0 100]), ylim([-100 100]), grid on, box off, xlabel('Trial #'), ylabel('Coherence')
end

%% generate adaptive trial set
nReps = 1; % could split into smaller blocks and randomise within blocks...
uniqueTrials = combvec(velini, Walk);
adaptTrials = repmat(uniqueTrials, 1, nReps);
adaptTrials = adaptTrials(:, randperm(size(adaptTrials,2)));

totalTrials = nIni + nReps*nConds;

%% Start Experiment
% wait for start signal from Unity

while true
    startSig = fread(t,1);
    if startSig == 9
        tic
        break
    end
end
pause(2)


%% ============= Do the initial trial set. =============== %

for itrial = 1:nIni % do the initial trial set
    
    vel = iniTrials(2,itrial); velnum = find(velini==vel); velTrial = sum(iniTrials(2,1:itrial) == vel);
    coh = rxx(iniTrials(1,itrial)); % get real coherence
    cohabs = abs(coh); % magnitude of coherence
    %forwards or backwards
    if coh > 0
        vel = -abs(vel);
    elseif coh < 0
        vel = abs(vel);
    end
    
    % create and send data char to Unity
    data = char(['0,0,' num2str(vel) ',s,' num2str(cohabs)])
    fwrite(t,data);
    pause(1)
    trialResult = fread(t,1);
    disp(trialResult)
    if trialResult == 0
        pointcolor = [1 0 0];
    elseif trialResult==1
        pointcolor = [0 0 1];
    end
    subplot(nConds, 1, velnum)
    plot(velTrial, coh,'ko','markerfacecolor',pointcolor) % initial stimuli
    pause(0.1)
    cond(velnum,1).yinit(velTrial,1) = trialResult; % condition specific.
    
end

% initialise dataset(s)
cond(1,1).seqdat = struct('x',cond(1,1).xinit,'y',cond(1,1).yinit,'i',cond(1,1).iinit);
cond(2,1).seqdat = struct('x',cond(2,1).xinit,'y',cond(2,1).yinit,'i',cond(2,1).iinit);
cond(3,1).seqdat = struct('x',cond(3,1).xinit,'y',cond(3,1).yinit,'i',cond(3,1).iinit);

%% === Posterior inference with initial dataset(s) =======

for icon = 1:numel(cond)
    % MAP estimate
    [cond(icon).probEst,cond(icon).prmEst,cond(icon).infoCrit,cond(icon).covEntropy,~] = ...
        fun_BASS_MAP(xx,cond(icon).seqdat,dims,optSeq);
end



%% #################### ADAPTIVE TRIAL SELECTION #################### %%

for itrial = 1:length(adaptTrials)
    icon = find(velini==adaptTrials(1,itrial)); % find which condition trial is
    
    [~,idxnext] = max(cond(icon).infoCrit); % find info-max stimulus
    vel = velini(icon); 
    xnext = xx(idxnext,:);
    coh = rxx(idxnext); % get real coherence
    cohabs = abs(coh); % magnitude of coherence
    % forwards or backwards
    if coh > 0, vel = -abs(vel); elseif coh < 0, vel = abs(vel); end
    
    % create and send data char to Unity
    data = char(['0,0,' num2str(vel) ',s,' num2str(cohabs)])
    fwrite(t,data);
    pause(1)
    
    trialResult = fread(t,1);
    if trialResult == 0
        pointcolor = [1 0 0];
    elseif trialResult==1
        pointcolor = [0 0 1];
    end
    subplot(nConds, 1, velnum)
    plot(numel(cond(icon).seqdat.x)+1, coh,'ko','markerfacecolor',pointcolor) % initial stimuli
    pause(0.1)
    ynext = trialResult;
    
    cond(icon).seqdat.x(end+1) = xnext;
    cond(icon).seqdat.y(end+1) = ynext;
    cond(icon).seqdat.i(end+1) = idxnext;

    % MAP estimate
    [cond(icon).probEst,cond(icon).prmEst,cond(icon).infoCrit,cond(icon).covEntropy,~] = ...
        fun_BASS_MAP(xx,cond(icon).seqdat,dims,optSeq);
    
end


%%
% % Final estimate after the last trial in sequence
% paramEst = paramVec2Struct(prmEst,dims); % final parameter struct
% 
% %% plotting
% toc
% ncoh = numel(rxx);
% uniqueCohs = unique(v5(:,1));
% 
% for i = 1:numel(uniqueCohs)
%     idx = find(v5(:,1)==uniqueCohs(i));
%     pCorr(i) = sum(v5(idx,2))/numel(idx);
%     nN(i) = numel(idx);
%     clear idx
% end
% 
% 
% [uniqueCohs'; pCorr; nN]
% 
% figure, hold on
% for i = 1:numel(pCorr)
%     plot(uniqueCohs(i),1-pCorr(i),'ko', 'MarkerFaceColor', 'b', 'MarkerSize', 4 + nN(i))
% end
% grid on
% hold on
% 
% plot(rxx(1:ncoh),probEst(1,1:ncoh),'k-','LineWidth',2)
% 


