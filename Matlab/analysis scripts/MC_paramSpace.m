%% get mc thresholds for different n
% save:
% - the actual threshold
% - threshold CI
% - deviance of the fit
% - width?
tic

%% Script to plot all data.

% interested in how number of trials and fit type effects results.
% our repeats are the fileNames. within this we also have 3 velocities.
% for each velocity we want to save:
% - psych curve: fit. CIs, deviance, 50% threshold (+ CIs), width
% pos, neg and allData: Fit, conf_ints, deviance, 80%thresh + CIs, width

fileNames = ...
    {'A-MC-030619.mat';...
    'B-MC-full-030619.mat';...
    'C-MC-full-040619.mat';...
    'D-MC-full-040619.mat';...
    'E-MC-full-040619.mat';...
    'F-MC-040619.mat';...
    'G-MC-040619.mat'};

sigmoidFits = {'norm';...
    'logistic';...
    %'logn';...
    %'weibull';...
    'gumbel';...
    'rgumbel'};
    

% pSpace(subject,nTrials,fit?).vel(2).fullpsych.fit(2),.deviance...
%. posData
%. negData, .allData
load(fileNames{1})
nTrials = length(results.allTrials);
nTrialVec = [50:50:nTrials, nTrials];

threshStruct = struct;
pSpace = struct;

% pSpace(isig,in).vel(ivel).


%%
for isig = 1:numel(sigmoidFits)
    for in = 1:numel(nTrialVec)
        for ifile = 1:numel(fileNames)
            
            load(fileNames{ifile}) % load the relevant subject
            
            % truncate results.allTrials to ntrials length
            results.allTrials = results.allTrials(:,1:nTrialVec(in));
            test = results.allTrials;
            correct = (test(5,:)>0 & test(6,:)==0) | (test(5,:)<0 & test(6,:)==1);
            
            a.allTrials = [results.allTrials; correct; 1:length(results.allTrials)];
            a.allConds = unique(a.allTrials(1:4,:)', 'rows');
            
            for ivel = 1:size(results.cond,1)
                for istate = 1:size(results.cond,2)
                    % index of condition
                    a.res(ivel,istate).TrialIdx =...
                        find(a.allTrials(3,:)==results.info.velocities(ivel) &...
                        a.allTrials(4,:)== results.info.states(istate));
                    % all the trials for this condition
                    a.res(ivel,istate).allTrials = a.allTrials(:,a.res(ivel,istate).TrialIdx);
                end
            end
            
            
            sampling = [1 2 3];
            subsampling = [1 2 3];
            
            for ivel = 1:size(a.res,1)
                for istate = 1:size(a.res,2)
                    for isamp = sampling
                        for isubsamp = subsampling
                            idx = find(a.res(ivel,istate).allTrials(1,:)==isamp & ...
                                a.res(ivel,istate).allTrials(2,:)==isubsamp-1);
                            a.res(ivel,istate).sampling(isamp,isubsamp).trials = ...
                                a.res(ivel,istate).allTrials(:,idx);
                        end
                    end
                end
            end
            
            
            %% First we need the data in the format (x | nCorrect | total)
            % find each kappa value.
            % for that value, find the number of trials, and number of 1s
            
            for ivel = 1:size(results.cond,1)
                for istate = 1:size(results.cond,2)
                    a.res(ivel,istate).psigMatrix = [];
                    for icoh = 1:numel(results.info.coherences)
                        
                        a.res(ivel,istate).kval(icoh).idx = find(a.res(ivel,istate).allTrials(5,:)==...
                            results.info.coherences(icoh));
                        
                        a.res(ivel,istate).kval(icoh).nTrials =...
                            numel(a.res(ivel,istate).kval(icoh).idx);
                        
                        a.res(ivel,istate).kval(icoh).nForward =  a.res(ivel,istate).kval(icoh).nTrials -...
                            sum(a.res(ivel,istate).allTrials(6,a.res(ivel,istate).kval(icoh).idx));
                        
                        a.res(ivel,istate).psigMatrix = [a.res(ivel,istate).psigMatrix;...
                            results.info.coherences(icoh), a.res(ivel,istate).kval(icoh).nForward, a.res(ivel,istate).kval(icoh).nTrials];
                    end
                    
                end
            end
            
            options             = struct;   % initialize as an empty struct
            options.sigmoidName = sigmoidFits{isig}; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
            options.expType     = 'YesNo';
            
            %%
            plotOptions.yLabel = ' ';
            plotOptions.xLabel = ' ';
            for ivel = 1:size(results.cond,1)
                for istate = 1:size(results.cond,2)
                    temp_idx = find(a.res(ivel,istate).psigMatrix(:,3)==0);
                    a.res(ivel,istate).psigMatrix(temp_idx,:) = [];
                    a.res(ivel,istate).psigresult = psignifit(a.res(ivel,istate).psigMatrix,options);
                    a.res(ivel,istate).standardParams = getStandardParameters(a.res(ivel,istate).psigresult);
                    
                    %title(['Velocity: ' string(results.info.velocities(ivel)) ' State: ' string(results.info.states(istate))])
                    %grid on
                    %xlim([-25 25])
                end
            end
            
            % save the fit, confidence intervas and deviance of the fit
%             paramSpace(isig,in).vel(ivel).fullPsych.Fit = a.res(ivel).psigresult.Fit;
%             paramSpace(isig,in).vel(ivel).fullPsych.FitCI = a.res(ivel).psigresult.conf_Intervals(:,:,1);
%             paramSpace(isig,in).vel(ivel).fullPsych.deviance = a.res(ivel).psigresult.deviance;
            
            
            for ivel = 1:3
                options.expType = '2AFC';
                
                trialSet = a.res(ivel).allTrials;
                trialSet2 = trialSet([5,7],:);
                
                uniqueKs = unique(trialSet2(1,:));
                negKs = uniqueKs(uniqueKs<0);
                posKs = uniqueKs(uniqueKs>0);
                
                negData = NaN*ones(numel(negKs),3);
                for i = 1:numel(negKs)
                    idx = find(trialSet2(1,:)==negKs(i));
                    negData(i,1) = abs(negKs(i)); % x val
                    negData(i,2) = sum(trialSet2(2,idx)); % n correct
                    negData(i,3) = numel(idx); % n trials
                end
                
                posData = NaN*ones(numel(posKs),3);
                for i = 1:numel(posKs)
                    idx = find(trialSet2(1,:)==posKs(i));
                    posData(i,1) = posKs(i); % x val
                    posData(i,2) = sum(trialSet2(2,idx)); % n correct
                    posData(i,3) = numel(idx); % n trials
                end
                
                
                pos.res = psignifit(posData,options);
                neg.res = psignifit(negData,options);
                all.res = psignifit([posData;negData],options);
                
                [pos.threshold,pos.CI] = getThreshold(pos.res, 0.8, true);
                [neg.threshold,neg.CI] = getThreshold(neg.res, 0.8, true);
                [all.threshold,all.CI] = getThreshold(all.res, 0.8, true);
                [signed.threshold, signed.CI] = getThreshold(a.res(ivel).psigresult, 0.5, true);
                
                threshStruct.vel(ivel).pT(ifile) = pos.threshold;
                threshStruct.vel(ivel).nT(ifile) = neg.threshold;
                threshStruct.vel(ivel).aT(ifile) = all.threshold;
                threshStruct.vel(ivel).bias(ifile) = signed.threshold;
                
                paramSpace(isig,in,ifile).vel(ivel).posData.Fit = pos.res.Fit;
                paramSpace(isig,in,ifile).vel(ivel).posData.FitCI = pos.res.conf_Intervals(:,:,1);
                paramSpace(isig,in,ifile).vel(ivel).posData.deviance = pos.res.deviance;
                paramSpace(isig,in,ifile).vel(ivel).posData.t80 = pos.threshold;
                paramSpace(isig,in,ifile).vel(ivel).posData.t80CI = pos.CI(1,:);
                
                paramSpace(isig,in,ifile).vel(ivel).negData.Fit = neg.res.Fit;
                paramSpace(isig,in,ifile).vel(ivel).negData.FitCI = neg.res.conf_Intervals(:,:,1);
                paramSpace(isig,in,ifile).vel(ivel).negData.deviance = neg.res.deviance;
                paramSpace(isig,in,ifile).vel(ivel).negData.t80 = neg.threshold;
                paramSpace(isig,in,ifile).vel(ivel).negData.t80CI = neg.CI(1,:);
                
                paramSpace(isig,in,ifile).vel(ivel).allData.Fit = all.res.Fit;
                paramSpace(isig,in,ifile).vel(ivel).allData.FitCI = all.res.conf_Intervals(:,:,1);
                paramSpace(isig,in,ifile).vel(ivel).allData.deviance = all.res.deviance;
                paramSpace(isig,in,ifile).vel(ivel).allData.t80 = all.threshold;
                paramSpace(isig,in,ifile).vel(ivel).allData.t80CI = all.CI(1,:);
                
                paramSpace(isig,in,ifile).vel(ivel).fullPsych.t50 = signed.threshold;
                paramSpace(isig,in,ifile).vel(ivel).fullPsych.t50CI = signed.CI(1,:);
                paramSpace(isig,in,ifile).vel(ivel).fullPsych.Fit = a.res(ivel).psigresult.Fit;
                paramSpace(isig,in,ifile).vel(ivel).fullPsych.FitCI = a.res(ivel).psigresult.conf_Intervals(:,:,1);
                paramSpace(isig,in,ifile).vel(ivel).fullPsych.deviance = a.res(ivel).psigresult.deviance;
                
            end
            
        end
        in
    end
    isig
end
%pos, neg, all, signed
toc
save('MotionCoherence_paramSpace2.mat', 'paramSpace')


