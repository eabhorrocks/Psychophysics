%% Script to plot all data.

fileNames = ...
    {'A-MC-030619.mat';...
    'B-MC-full-030619.mat';...
    'C-MC-full-040619.mat';...
    'D-MC-full-040619.mat';...
    'E-MC-full-040619.mat';...
    'F-MC-040619.mat';...
    'G-MC-040619.mat'}

ColorArray =[0, 0, 1;...
    1, 0, 0;...
    0.9290,0.6940,0.125;...
    0.4940,0.1840,0.5560;...
    0.4660,0.674,0.188;...
    0.3010,0.7450,0.9330;...
    0,0,0];

%%

for ifile = 1:numel(fileNames)
    load(fileNames{ifile})
    
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
    options.sigmoidName = 'norm'; %'rgumbel'   % choose a cumulative Gaussian as the sigmoid
    options.expType     = 'equalAsymptote';
    
    %%
    plotOptions.yLabel = ' ';
    plotOptions.xLabel = ' ';
    plotOptions.lineColor = ColorArray(ifile,:);
    for ivel = 1:size(results.cond,1)
        for istate = 1:size(results.cond,2)
            temp_idx = find(a.res(ivel,istate).psigMatrix(:,3)==0);
            a.res(ivel,istate).psigMatrix(temp_idx,:) = [];
            a.res(ivel,istate).psigresult = psignifit(a.res(ivel,istate).psigMatrix,options);
            a.res(ivel,istate).standardParams = getStandardParameters(a.res(ivel,istate).psigresult);
            figure(ivel)
            subplot(3,3,ifile)
            plotPsych(a.res(ivel,istate).psigresult, plotOptions);
            %title(['Velocity: ' string(results.info.velocities(ivel)) ' State: ' string(results.info.states(istate))])
            grid on
            xlim([-5 5])
        end
        a.res(ivel).psigresult.deviance
    end
    
end