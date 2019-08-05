function [a, plotHandle] = getAndPlotConditionTrials(a, results)

figure
plotidx = 1;
for ivel = 1:size(results.cond,1)
    for istate = 1:size(results.cond,2)
        % index of condition
        a.res(ivel,istate).TrialIdx =...
            find(a.allTrials(3,:)==results.info.velocities(ivel) &...
            a.allTrials(4,:)== results.info.states(istate));
        % all the trials for this condition
        a.res(ivel,istate).allTrials = a.allTrials(:,a.res(ivel,istate).TrialIdx);
        
        
        subplot(size(results.cond,2),size(results.cond,1),1)
        % plot trial responses and coherences
        for idx = 1:numel(a.res(ivel,istate).TrialIdx)
            if a.res(ivel,istate).allTrials(6,idx) == 1
                colR = [0 1 0]; 
            elseif a.res(ivel,istate).allTrials(6,idx) == 0
                colR = [0 0 1];
            elseif isnan(a.res(ivel,istate).allTrials(6,idx))
                colR = [1 1 1];
            end
            subplot(size(results.cond,2),size(results.cond,1),plotidx)
            plot(idx, a.res(ivel,istate).allTrials(5,idx), 'o', 'color', colR), hold on
        end
        plot([1 idx], [0 0], 'k--')
        grid on
        title(['Velocity: ' string(results.info.velocities(ivel)) ' State: ' string(results.info.states(istate))])
        xlabel('condition trial #'), ylabel('coherence (k)')
        plotidx = plotidx + 1;
        
    end
end