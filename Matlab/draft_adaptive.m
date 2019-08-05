%% Draft adaptive stimulus selection script
% Testing with just a 1D coherence stimulus

%% clear
clear;
clc;

%% set up TCP socket with Unity

t = tcpip('127.0.0.1',10061,'NetworkRole','Client','Timeout',60);
fopen(t)
t

%% Set up stimulus space and response spaces
% xx is stimulus space
% y is response space

% STIMULUS SPACE (1d coherence for now)
cohOrig = [1 2 4 6 8 10 14 18 25 35 50 75 100];
cohFlip = fliplr(cohOrig * -1);
cohVec = [cohFlip, cohOrig];
xx = cohVec/std(cohVec); % normalise to have std of 1, mean of 0
xx = xx'; 

% RESPONSE SPACE
yvalslist = [0 1];

dims.y = numel(yvalslist)-1; % degrees of freedom of response space
dims.g = numel(gfun(xx(1,:))); % degrees of freedom of internal feature vector of stim

K0 = dims.y * dims.g;


%% Generate some initial stimulus-response observations

% pick initial points
ninit = 10; % # initial trials (not adaptively sampled)
iinit = randsample(1:size(xx,1),ninit,false); % choose random stimuli (for now)
xinit = xx(iinit,:);
% just some false responses for testing
for i = 1:ninit
    if xinit(i) < 0
        yinit(i) = 0;
    else
        yinit(i) = 1;
    end
end
    
yinit = yinit';

% initialise dataset
seqdat = struct('x',xinit,'y',yinit,'i',iinit(:));

% plot initial stimuli
figure
hold on
for np = 1:ninit
    if yinit(np) == 0,
        pointcolor = [1 0 0];
    elseif yinit(np)==1,
        pointcolor = [0 1 0];
    end
    plot(xinit(np,1),'ko','markerfacecolor',pointcolor) % initial stimuli
end

%% Infer PF from initial data

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

%% === Pack options for sequential experiment =======

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


%% === Posterior inference with initial data =======

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


%% select next stimulus using infomax

% select next stimulus using infomax
[~,idxnext] = max(infoCrit); % find info-max stimulus
xnext = xx(idxnext,:)
ynext = 1;

%% Adaptively sample and add one stimulus at a time

nTrials = 200;

for jj = 1:nTrials
    
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
    nstim = cohVec(idxnext)
    if xnext < 0.4
        ynext = 0;
    else
        ynext = 1;
    end
    
    % can plot stuff here
    
end

% Final estimate after the last trial in sequence
paramEst = paramVec2Struct(prmEst,dims); % final parameter struct

    



