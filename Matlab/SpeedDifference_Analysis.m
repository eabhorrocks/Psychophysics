%% speed Difference analysis script
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

test = results.allTrials;
correct = (test(5,:)>0 & test(6,:)==1) | (test(5,:)<0 & test(6,:)==0);
a.allTrials = [results.allTrials; correct; 1:length(results.allTrials)];
a.allConds = unique(a.allTrials(1:4,:)', 'rows');

clear test

%% Plot colour-coded trials for each condition (velocity/state)

a = getAndPlotConditionTrials(a, results)

%% get and plot individual staircases

a = getAndPlotStaircases(a, results)


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
            
            a.res(ivel,istate).kval(icoh).nForward =...
                sum(a.res(ivel,istate).allTrials(6,a.res(ivel,istate).kval(icoh).idx));
            
            a.res(ivel,istate).psigMatrix = [a.res(ivel,istate).psigMatrix;...
                results.info.coherences(icoh), a.res(ivel,istate).kval(icoh).nForward, a.res(ivel,istate).kval(icoh).nTrials];
        end
        
    end
end

options             = struct;   % initialize as an empty struct
options.sigmoidName = 'logistic'; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
options.expType     = 'YesNo';

%%
plotOptions.yLabel = 'Prop. 2nd was Faster Responses';
plotOptions.xLabel = 'Speed Difference of 2nd';
for ivel = 1:size(results.cond,1)
    for istate = 1:size(results.cond,2)
        temp_idx = find(a.res(ivel,istate).psigMatrix(:,3)==0);
        a.res(ivel,istate).psigMatrix(temp_idx,:) = [];
        a.res(ivel,istate).psigresult = psignifit(a.res(ivel,istate).psigMatrix,options);
        a.res(ivel,istate).standardParams = getStandardParameters(a.res(ivel,istate).psigresult);
        figure
        title(['Velocity: ' string(results.info.velocities(ivel)) ' State: ' string(results.info.states(istate))])
        plotPsych(a.res(ivel,istate).psigresult, plotOptions);
        grid on
        xlim([-2 2])
    end
    a.res(ivel).psigresult.deviance
end
