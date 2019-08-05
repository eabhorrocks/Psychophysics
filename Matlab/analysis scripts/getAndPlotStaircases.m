function [a, plotHandle] = getAndPlotStaircases(a, results)

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

for ivel = 1:size(a.res,1)
    for istate = 1:size(a.res,2)
        figure,
        
        
        subplot(2,1,1), hold on, grid on
        title(['Velocity: ' string(results.info.velocities(ivel)) ' State: ' string(results.info.states(istate))])
        cohVals =  a.res(ivel, istate).sampling(2,2).trials(5,:);
        correctVec = a.res(ivel, istate).sampling(2,2).trials(7,:);
        xlabel('staircase trial #')
        ylabel('Stimulus')
        stairs(cohVals);
        for i = 1:numel(cohVals)
            plot(i, cohVals(i), 'o', 'MarkerFaceColor', [1-correctVec(i), correctVec(i), 0], 'color', 'k')
        end
        
        %subplot(4,1,2), hold on, grid on
        cohVals =  a.res(ivel, istate).sampling(2,3).trials(5,:);
        correctVec = a.res(ivel, istate).sampling(2,3).trials(7,:);
        xlabel('staircase trial #')
        ylabel('Stimulus')
        stairs(cohVals);
        for i = 1:numel(cohVals)
            plot(i, cohVals(i), 'o', 'MarkerFaceColor', [1-correctVec(i), correctVec(i), 0], 'color', 'k')
        end
        plot([1 numel(cohVals)], [0, 0], 'k--')

        
        subplot(2,1,2), hold on, grid on
        cohVals =  a.res(ivel, istate).sampling(3,2).trials(5,:);
        correctVec = a.res(ivel, istate).sampling(3,2).trials(7,:);
        xlabel('staircase trial #')
        ylabel('Stimulus')
        stairs(cohVals);
        for i = 1:numel(cohVals)
            plot(i, cohVals(i), 'o', 'MarkerFaceColor', [1-correctVec(i), correctVec(i), 0], 'color', 'k')
        end
        
        %subplot(4,1,4), hold on, grid on
        cohVals =  a.res(ivel, istate).sampling(3,3).trials(5,:);
        correctVec = a.res(ivel, istate).sampling(3,3).trials(7,:);
        xlabel('staircase trial #')
        ylabel('Stimulus')
        stairs(cohVals);
        for i = 1:numel(cohVals)
            plot(i, cohVals(i), 'o', 'MarkerFaceColor', [1-correctVec(i), correctVec(i), 0], 'color', 'k')
        end
        plot([1 numel(cohVals)], [0, 0], 'k--')

        
    end
end
