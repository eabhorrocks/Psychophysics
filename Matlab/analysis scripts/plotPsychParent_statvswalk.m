%% plot walk v stat


%result_stat = a.cond(1,1).psigresult;
%result_walk = a.cond(1,2).psigresult;

function plotHandle = plotPsychParent_statvswalk(result_stat, result_walk, ivel, fileName)

plotOptions_stat.dataColor      = [1,0,0];  % color of the data
plotOptions_stat.plotData       = 1;                    % plot the data?
plotOptions_stat.lineColor      = [1,0,0];              % color of the PF

plotOptions_walk.dataColor      = [0,1,0];  % color of the data
plotOptions_walk.plotData       = 1;                    % plot the data?
plotOptions_walk.lineColor      = [0,1,0];              % color of the PF


%plotHandle = figure;
plotPsych_statVsWalk(result_stat,result_walk,plotOptions_stat,plotOptions_walk)
grid on
title(['Stationary vs Walking; Vel: ' num2str(ivel) '; Subj: ' num2str(fileName)])
ylabel('Prop. Towards Responses')
