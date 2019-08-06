function a = devMCanalysis(resultsFile)

load(resultsFile,'results');
fileName = resultsFile;
%% motion coherence analysis script

% this needs re-doing.
% split data into +ve and -ve
% https://github.com/wichmann-lab/psignifit/wiki/Interval-Bias
%load('eh-mc-2205.mat')
% 1) sampling method
% 2) subsampling (staircase dir/order)
% 3) velocity
% 4) state
% 5) coherences/speed diff
% 6) response (0 = towards/1st; 1 = away/2nd)
% 7) correctness of response
% 8) trial index for entire experiment.



%%
test = results.allTrials;
invalidTrials = find(test(6,:)==9);
test(:,invalidTrials) = [];
correct = (test(5,:)>0 & test(6,:)==0) | (test(5,:)<0 & test(6,:)==1);
a.allTrials = [test; correct; 1:length(test)];
a.allConds = unique(a.allTrials(1:4,:)', 'rows');

clear test

%% Plot colour-coded trials for each condition (velocity/state)

%a = getAndPlotConditionTrials(a, results)

%% get and plot individual staircases

%a = getAndPlotStaircases(a, results)


%% First we need the data in the format (x | nCorrect | total)
% for the full psychometric curve we chance nCorrect to nTowards

velVec = unique(a.allTrials(3,:));
stateVec = unique(a.allTrials(4,:));

for ivel = 1:size(results.cond,1)
    for istate = 1:size(results.cond,2)
        
        % initialise the input matrix for this condition
        a.cond(ivel,istate).psigMatrix = [];
        % trial array for this condition
        a.cond(ivel,istate).idx = find(a.allTrials(3,:)==velVec(ivel)...
            & a.allTrials(4,:)==stateVec(istate));
        a.cond(ivel,istate).trials = a.allTrials(:,a.cond(ivel,istate).idx);
        % unique coherences for this condition
        a.cond(ivel,istate).cohVec = unique(a.cond(ivel,istate).trials(5,:));
        
        % loop through these coherences to build psig input matrix
        for icoh = 1:numel(a.cond(ivel,istate).cohVec)
            
            % trials for this condition and coherence value
            a.cond(ivel,istate).kval(icoh).idx = find(a.cond(ivel,istate).trials(5,:)==...
                a.cond(ivel,istate).cohVec(icoh));
            a.cond(ivel,istate).kval(icoh).trials = a.cond(ivel,istate).trials(:,a.cond(ivel,istate).kval(icoh).idx);
            % number of trials at this coherence
            a.cond(ivel,istate).kval(icoh).nTrials =...
                numel(a.cond(ivel,istate).kval(icoh).idx);
            % number of 'towards' responses
            a.cond(ivel,istate).kval(icoh).nTowards =...
                numel(find(a.cond(ivel,istate).kval(icoh).trials(6,:)==0));
            
            % fill in corresponding row of input psigmatrix
            % coh value, nTowards responses, nTrials
            a.cond(ivel,istate).psigMatrix = [a.cond(ivel,istate).psigMatrix;...
                a.cond(ivel,istate).cohVec(icoh),...
                a.cond(ivel,istate).kval(icoh).nTowards,...
                a.cond(ivel,istate).kval(icoh).nTrials];
        end
        
    end
end

%% psignifit options

options             = struct;   % initialize as an empty struct
options.sigmoidName = 'norm'; %'rgumbel'   % choose a cumulative GaussNNian as the sigmoid
options.expType     = 'equalAsymptote';
options.estimateType = 'MAP'; %mean

% [threshold,width,upper asymptote,lower asymptote,variance scaling]
%options.stepN   = [80,80,40,404020];
%options.mbStepN = [40,30,15,15,15];

options.confP = [.99, .95,.9,.68];
options.threshPC       = .5;
options.betaPrior      = 20;
options.poolMaxLength  = 50;  %50
options.moveBorders    = 1;

% fix lapse rate to 0
options.fixedPars = NaN(5,1);
options.fixedPars(3) = 0;
options.fixedPars(4) = 0;
%options.borders = nan(5,2);
%options.borders(3,:)=[0,.05];
%options.borders(4,:)=[0,.05];


%% Generate psignifit result and plot psychometric curve

plotOptions.yLabel = 'Prop. Towards Responses';
plotOptions.xLabel = 'Coherence (k)';
for ivel = 1:size(results.cond,1)
    for istate = 1:size(results.cond,2)
        a.cond(ivel,istate).psigresult = psignifit(a.cond(ivel,istate).psigMatrix,options);
        a.cond(ivel,istate).standardParams = getStandardParameters(a.cond(ivel,istate).psigresult);
        a.cond(ivel,istate).slopeAtZero = getSlope(a.cond(ivel,istate).psigresult, 0);
        a.cond(ivel,istate).slopeAtPSE = getSlopePC(a.cond(ivel,istate).psigresult, 0.5, true);
        %figure
        %title(['Velocity: ' string(results.info.velocities(ivel)) ' State: ' string(results.info.states(istate))])
        %plotPsych(a.cond(ivel,istate).psigresult, plotOptions);
        %grid on
        %xlim([-5 5])
    end
    a.cond(ivel,istate).psigresult.deviance;
end

%% plot comparison of stationary vs walking

for ivel = 1:3
    subplot(2,3,ivel)
    result_stat = a.cond(ivel,1).psigresult;
    result_walk = a.cond(ivel,2).psigresult;
    plotPsychParent_statvswalk(result_stat, result_walk, ivel, fileName)
end


%% plot comparison of speeds for walking and stationary separately

for istate = 1:2
    result_spd1 = a.cond(1,istate).psigresult;
    result_spd2 = a.cond(2,istate).psigresult;
    result_spd3 = a.cond(3,istate).psigresult;
    subplot(2,3,3+istate)
    plotPsychParent_speedcomp(result_spd1, result_spd2, result_spd3, istate, fileName)
end
%% get bias values

for ivel = 1:size(results.cond,1)
    for istate = 1:size(results.cond,2)
        a.cond(ivel,istate).pse = getThreshold(a.cond(ivel,istate).psigresult, 0.5, true);
    end
end

%statBias = [signed(1:3,1).threshold];
%walkBias = [signed(1:3,2).threshold];
%walkMinStatBias = [signed(1:3,2).threshold]-[signed(1:3,1).threshold];


%walkMinStatThresh = [all(1:3,2).threshold]-[all(1:3,1).threshold]

%% pass your data in the n x 3 matrix of the form:
%       [x-value, number correct, number of trials]
options.expType = '2AFC';

for ivel = 1:size(results.cond,1)
    for istate = 1:size(results.cond,2)
        
        
        
        %%%%%%% negative (away) coherences %%%%%%%
        a.cond(ivel,istate).neg.psigMatrix = [];
        
        a.cond(ivel,istate).neg.cohVec = a.cond(ivel,istate).cohVec...
            (a.cond(ivel,istate).cohVec<0);
        
        % loop through these coherences to build psig input matrix
        for icoh = 1:numel(a.cond(ivel,istate).neg.cohVec)
            
            % trials for this condition and coherence value
            a.cond(ivel,istate).neg.kval(icoh).idx = find(a.cond(ivel,istate).trials(5,:)==...
                a.cond(ivel,istate).neg.cohVec(icoh));
            a.cond(ivel,istate).neg.kval(icoh).trials = a.cond(ivel,istate).trials(:,a.cond(ivel,istate).neg.kval(icoh).idx);
            % number of trials at this coherence
            a.cond(ivel,istate).neg.kval(icoh).nTrials =...
                numel(a.cond(ivel,istate).neg.kval(icoh).idx);
            % number of correct (here==1) responses
            a.cond(ivel,istate).neg.kval(icoh).nCorrect =...
                numel(find(a.cond(ivel,istate).neg.kval(icoh).trials(6,:)==1));
            
            % fill in corresponding row of input psigmatrix
            % coh value, nTowards responses, nTrials
            a.cond(ivel,istate).neg.psigMatrix = [a.cond(ivel,istate).neg.psigMatrix;...
                a.cond(ivel,istate).neg.cohVec(icoh),...
                a.cond(ivel,istate).neg.kval(icoh).nCorrect,...
                a.cond(ivel,istate).neg.kval(icoh).nTrials];
        end
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
      %%%%%%% positive (towards) coherences %%%%%%%
        a.cond(ivel,istate).pos.psigMatrix = [];
        
        a.cond(ivel,istate).pos.cohVec = a.cond(ivel,istate).cohVec...
            (a.cond(ivel,istate).cohVec>0);
        
        % loop through these coherences to build psig input matrix
        for icoh = 1:numel(a.cond(ivel,istate).pos.cohVec)
            
            % trials for this condition and coherence value
            a.cond(ivel,istate).pos.kval(icoh).idx = find(a.cond(ivel,istate).trials(5,:)==...
                a.cond(ivel,istate).pos.cohVec(icoh));
            a.cond(ivel,istate).pos.kval(icoh).trials = a.cond(ivel,istate).trials(:,a.cond(ivel,istate).pos.kval(icoh).idx);
            % number of trials at this coherence
            a.cond(ivel,istate).pos.kval(icoh).nTrials =...
                numel(a.cond(ivel,istate).pos.kval(icoh).idx);
            % number of correct (here==0) responses
            a.cond(ivel,istate).pos.kval(icoh).nCorrect =...
                numel(find(a.cond(ivel,istate).pos.kval(icoh).trials(6,:)==0));
            
            % fill in corresponding row of input psigmatrix
            % coh value, nTowards responses, nTrials
            a.cond(ivel,istate).pos.psigMatrix = [a.cond(ivel,istate).pos.psigMatrix;...
                a.cond(ivel,istate).pos.cohVec(icoh),...
                a.cond(ivel,istate).pos.kval(icoh).nCorrect,...
                a.cond(ivel,istate).pos.kval(icoh).nTrials];
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        %%%%%%% collapse over distance coherences %%%%%%%
        a.cond(ivel,istate).abs.psigMatrix = [];
        
        a.cond(ivel,istate).abs.absTrials = a.cond(ivel,istate).trials;
        a.cond(ivel,istate).abs.absTrials(5,:) = abs(a.cond(ivel,istate).abs.absTrials(5,:));
        
        a.cond(ivel,istate).abs.psigMatrix = []; 
        a.cond(ivel,istate).abs.cohVec = unique(a.cond(ivel,istate).abs.absTrials(5,:));
        
        % loop through these coherences to build psig input matrix
        for icoh = 1:numel(a.cond(ivel,istate).abs.cohVec)
            
            % trials for this condition and coherence value
            a.cond(ivel,istate).abs.kval(icoh).idx = find(a.cond(ivel,istate).abs.absTrials(5,:)==...
                a.cond(ivel,istate).abs.cohVec(icoh));
            a.cond(ivel,istate).abs.kval(icoh).trials = a.cond(ivel,istate).abs.absTrials(:,a.cond(ivel,istate).abs.kval(icoh).idx);
            % number of trials at this coherence
            a.cond(ivel,istate).abs.kval(icoh).nTrials =...
                numel(a.cond(ivel,istate).abs.kval(icoh).idx);
            % number of correct (here use correct row of array==1) responses
            a.cond(ivel,istate).abs.kval(icoh).nCorrect =...
                numel(find(a.cond(ivel,istate).abs.kval(icoh).trials(7,:)==1));
            
            % fill in corresponding row of input psigmatrix
            % coh value, nTowards responses, nTrials
            a.cond(ivel,istate).abs.psigMatrix = [a.cond(ivel,istate).abs.psigMatrix;...
                a.cond(ivel,istate).abs.cohVec(icoh),...
                a.cond(ivel,istate).abs.kval(icoh).nCorrect,...
                a.cond(ivel,istate).abs.kval(icoh).nTrials];
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %biasAna(negData,posData,options)
     
        a.cond(ivel,istate).neg.psigresult = psignifit(a.cond(ivel,istate).neg.psigMatrix,options);
        a.cond(ivel,istate).pos.psigresult = psignifit(a.cond(ivel,istate).pos.psigMatrix,options);
        a.cond(ivel,istate).abs.psigresult = psignifit(a.cond(ivel,istate).abs.psigMatrix,options);
        
        a.cond(ivel,istate).neg.t80 = getThreshold(a.cond(ivel,istate).neg.psigresult, 0.8, true);
        a.cond(ivel,istate).pos.t80 = getThreshold(a.cond(ivel,istate).pos.psigresult, 0.8, true);
        a.cond(ivel,istate).abs.t80 = getThreshold(a.cond(ivel,istate).abs.psigresult, 0.8, true);
        a.cond(ivel,istate).abs.slopeAtt80 = getSlopePC(a.cond(ivel,istate).abs.psigresult, 0.8, true);
        
        %[pos(ivel,istate).threshold,pos(ivel,istate).CI] = getThreshold(pos(ivel,istate).res, 0.8, true);
        %[neg(ivel,istate).threshold,neg(ivel,istate).CI] = getThreshold(neg(ivel,istate).res, 0.8, true);
        %[all(ivel,istate).threshold,all(ivel,istate).CI] = getThreshold(all(ivel,istate).res, 0.8, true);
        
        %[signed(ivel,istate).threshold, signed(ivel,istate).CI] = getThreshold(a.res(ivel,istate).psigresult, 0.5, true);
    end
end
%%

%walkMinStatBias = [signed(1:3,2).threshold]-[signed(1:3,1).threshold]
%walkMinStatThresh = [all(1:3,2).threshold]-[all(1:3,1).threshold]



%% psres = psignifit(allData,options);
%
% plotsModelfit(psres)
% plotBayes(psres);
% figure
% plotMarginal(psres,5)