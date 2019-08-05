%% 1D coherence matlab/unity
% need to write results to a txt file
% https://research.computing.yale.edu/hpc/faq/how-can-i-run-matlab-batch-mode-without-gui
% run w/o a gui would be good.

clear all
set(0,'DefaultFigureWindowStyle','docked')
figure, hold on, xlim([0 100]), ylim([-100 100]), grid on, box off, xlabel('Trial #'), ylabel('Coherence')

%% set up TCP socket with Unity

t = tcpip('127.0.0.1',10061,'NetworkRole','Client','Timeout',60);
t.Timeout = 60;
% t.ReadAsyncMode='continuous';
fopen(t)
t

%% Set up stimulus space and response spaces + other opts
% xx is stimulus space
% y is response space

% STIMULUS SPACE (coherence and speed);
cohOrig = [2, 4, 6, 8, 10, 15, 20, 25, 35, 50, 60, 70, 80, 90, 100];
cohFlip = fliplr(cohOrig * -1);
cohVec = [cohFlip, cohOrig];
cohstd = cohVec/std(cohVec); % normalise to have std of 1, mean of 0

velVec = [5 10 20 30 40];
velstd = velVec/std(velVec);

xx = combvec(cohstd, velstd)'; % stimulus space (coherence and vel)
rcoh = cohVec; % real un-normalised coherences.
rvel = velVec;
rxx = combvec(cohVec, velVec)';

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

%velocity = 40;

% probably need to weight the sampling or pick specific coherences
ninit = 10; % # initial trials (not adaptively sampled)
% change this -> systematic sampling
iinit = randsample(1:size(xx,1),ninit,false); % rand samples w/o replacement
xinit = xx(iinit,:);
%figure, xlim([0 100]), ylim([-100 100]), grid on, hold on

% ============= Do the initial trial set. =============== %

for itrial = 1:ninit % do the initial trials
    coh = rxx(iinit(itrial),1); % get real coherence
    vel = rxx(iinit(itrial),2);
    cohabs = abs(coh); % magnitude of coherence
    %forwards or backwards
    if coh > 0
        vel = -vel;
    elseif coh < 0
        vel = vel;
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
    plot(itrial, coh,'ko','markerfacecolor',pointcolor) % initial stimuli
    pause(0.1)
    yinit(itrial,:) = trialResult;
    
end

% initialise dataset
seqdat = struct('x',xinit,'y',yinit,'i',iinit(:));

% === Posterior inference with initial data =======

if(doingMAP)
    % MAP estimate
    [probEst,prmEst,infoCrit,covEntropy,~] = ...
        fun_BASS_MAP(xx,seqdat,dims,optSeq);
elseif(doingMCMC)
    % MCMC sampling
    [probEst,prmEst,infoCrit,covEntropy,chainLmat,~] = ...
        fun_BASS_MCMC(xx,seqdat,dims,optSeq);
    % adjust next sampling parameters
    optSeq.prs0 = prmEst;
    optSeq.steps = chainLmat;
    optSeq.nburn = optSeq.nburnAdd; % shorter burn-in for non-initial trials
    % track sampler properties
    chainstd = diag(chainLmat)'; % store diagonal part (std) only
end

% select next stimulus using infomax

[~,idxnext] = max(infoCrit); % find info-max stimulus
xnext = xx(idxnext,:);
coh = rxx(idxnext,1); % get real coherence
cohabs = abs(coh); % magnitude of coherence
vel = rxx(idxnext,2);

% forwards or backwards
if coh > 0
    vel = -vel;
elseif coh < 0
    vel = vel;
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
plot(itrial, coh,'ko','markerfacecolor',pointcolor) % initial stimuli
pause(0.1)
ynext = trialResult;


% =============== Adaptively sample trials =============

nTrials = 100;

for itrial = ninit+1:nTrials
    
    % update dataset
    seqdat.x(end+1,:) = xnext;
    seqdat.y(end+1) = ynext;
    seqdat.i(end+1) = idxnext;
    
    % posterior inference
    if(doingMAP)
        % MAP estimate
        [probEst,prmEst,infoCrit,covEntropy,~] = ...
            fun_BASS_MAP(xx,seqdat,dims,optSeq);
    elseif(doingMCMC)
        % MCMC sampling
        [probEst,prmEst,infoCrit,covEntropy,chainLmat,~] = ...
            fun_BASS_MCMC(xx,seqdat,dims,optSeq);
        % adjust next sampling parameters
        optSeq.prs0 = prmEst;
        optSeq.steps = chainLmat;
        optSeq.nburn = optSeq.nburnAdd; % shorter burn-in for non-initial trials
        % track sampler properties
        chainstd = diag(chainLmat)'; % store diagonal part (std) only
    end
    
    % select next stimulus using infomax
    [~,idxnext] = max(infoCrit); % find info-max stimulus
    xnext = xx(idxnext,:);
    coh = rxx(idxnext,1); % get real coherence
    cohabs = abs(coh); % magnitude of coherence
    vel = rxx(idxnext,2);
    % forwards or backwards
    if coh > 0
        vel = -vel;
    elseif coh < 0
        vel = vel;
    end
    
    % create and send data char to Unity
    data = char(['0,0,' num2str(vel) ',s,' num2str(cohabs)])
    fwrite(t,data);
    pause(1)
    %get response
    trialResult = fread(t,1);
    disp(trialResult)
    if trialResult == 0
        pointcolor = [1 0 0];
    elseif trialResult==1
        pointcolor = [0 0 1];
    end
    plot(itrial, coh, 'ko','markerfacecolor',pointcolor) % initial stimuli
    pause(0.1)
    ynext = trialResult;
    
end

% Final estimate after the last trial in sequence
paramEst = paramVec2Struct(prmEst,dims); % final parameter struct

%% plotting
toc
ncoh = numel(rcoh);
nvel = numel(rvel);
uniqueCohs = unique(v5(:,1));

for i = 1:numel(uniqueCohs)
    idx = find(v5(:,1)==uniqueCohs(i));
    pCorr(i) = sum(v5(idx,3))/numel(idx);
    nN(i) = numel(idx);
    clear idx
end


[uniqueCohs'; pCorr; nN]

figure, hold on
for i = 1:numel(pCorr)
    plot(uniqueCohs(i),1-pCorr(i),'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 4 + nN(i))
end
grid on
hold on
for i = 5
    plot(rxx(1+(i-1)*ncoh:i*ncoh,1),probEst(1,1+(i-1)*ncoh:i*ncoh),'k-')
end


