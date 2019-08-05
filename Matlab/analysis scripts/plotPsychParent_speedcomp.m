function plotHandle = plotPsychParent_speedcomp(result_spd1, result_spd2, result_spd3, istate, fileName)

plotOptions_spd1.dataColor      = [0,0,.2];  % color of the data
plotOptions_spd1.plotData       = 1;                    % plot the data?
plotOptions_spd1.lineColor      = [0,0,.2];              % color of the PF

plotOptions_spd2.dataColor      = [0,0,1];  % color of the data
plotOptions_spd2.plotData       = 1;                    % plot the data?
plotOptions_spd2.lineColor      = [0,0,1];              % color of the PF

plotOptions_spd3.dataColor      = [0,1,1];  % color of the data
plotOptions_spd3.plotData       = 1;                    % plot the data?
plotOptions_spd3.lineColor      = [0,1,1];              % color of the PF

%plotHandle = figure;
plotPsych_spdComp(result_spd1, result_spd2, result_spd3, plotOptions_spd1, plotOptions_spd2, plotOptions_spd3)
grid on
title(['Speed Comp.; State: ' num2str(istate) '; Subj: ' num2str(fileName)])
ylabel('Prop. Towards Responses')
