%% analysis of psignifits for MC

% pse = cond.pse

n = numel(a);

for ivel = 1:3
    for istate = 1:1%2
        for isub = 1:n
            vals(ivel,istate).pse(isub) = a(isub).cond(ivel,istate).pse;
            vals(ivel,istate).t80(isub) = a(isub).cond(ivel,istate).abs.t80;
            vals(ivel,istate).slopeAtt80(isub) = a(isub).cond(ivel,istate).abs.slopeAtt80;
            vals(ivel,istate).standMean(isub) = a(isub).cond(ivel,istate).standardParams(1);
            vals(ivel,istate).StanDev(isub) = a(isub).cond(ivel,istate).standardParams(2);
            vals(ivel,istate).slopeAtZeroStim(isub) = a(isub).cond(ivel,istate).slopeAtZero;
            vals(ivel,istate).slopeAtPSE(isub) = a(isub).cond(ivel,istate).slopeAtPSE;
            vals(ivel,istate).upperLapse(isub) = a(isub).cond(ivel,istate).standardParams(3);
            vals(ivel,istate).lowerLapse(isub) = a(isub).cond(ivel,istate).standardParams(4);
            vals(ivel,istate).disp(isub) = a(isub).cond(ivel,istate).standardParams(5);
        end
        vals(ivel,istate).stdSlope = 0.682./vals(ivel,istate).StanDev;

            vals(ivel,istate).z.stdSlope = zscore(vals(ivel,istate).stdSlope);
            vals(ivel,istate).z.pse = zscore(vals(ivel,istate).pse);
            vals(ivel,istate).z.t80 = zscore(vals(ivel,istate).t80);
            vals(ivel,istate).z.slopeAtt80 = zscore(vals(ivel,istate).slopeAtt80);
            vals(ivel,istate).z.standMean = zscore(vals(ivel,istate).standMean);
            vals(ivel,istate).z.StanDev = zscore(vals(ivel,istate).StanDev);
            vals(ivel,istate).z.slopeAtZeroStim = zscore(vals(ivel,istate).slopeAtZeroStim);
            vals(ivel,istate).z.slopeAtPSE = zscore(vals(ivel,istate).slopeAtPSE);
            vals(ivel,istate).z.upperLapse = zscore(vals(ivel,istate).upperLapse);
            vals(ivel,istate).z.lowerLapse = zscore(vals(ivel,istate).lowerLapse);

    end
end


%

%% plots

fieldName = 't80';

figure
n = numel(vals(1,1).(fieldName));
t80walkarray = [vals(1,2).(fieldName)', vals(2,2).(fieldName)', vals(3,2).(fieldName)'];
t80statarray = [vals(1,1).(fieldName)', vals(2,1).(fieldName)', vals(3,1).(fieldName)'];
t80walkmean = mean(t80walkarray);
t80statmean = mean(t80statarray);
t80walksem = std(t80walkarray)/sqrt(n);
t80statsem = std(t80statarray)/sqrt(n);

t80allmeans = [t80statmean; t80walkmean];
t80allerrs = [t80statsem; t80walksem];

eb = errorbar_groups(t80allmeans, t80allerrs);
legend({'stat', 'walk'},'AutoUpdate','off')

hbw = 0.45;
hold on
for isub = 1:n
    plot([eb(1)-hbw, eb(1)+hbw], [vals(1, 1).(fieldName)(isub), vals(1, 2).(fieldName)(isub)], 'Color', [.7 .7 .7])
    plot([eb(2)-hbw, eb(2)+hbw], [vals(2, 1).(fieldName)(isub), vals(2, 2).(fieldName)(isub)], 'Color', [.7 .7 .7])
    plot([eb(3)-hbw, eb(3)+hbw], [vals(3, 1).(fieldName)(isub), vals(3, 2).(fieldName)(isub)], 'Color', [.7 .7 .7])
   
end
%bar([t80statmean; t80walkmean]')

%% check normality



%% rm ANOVA 
yvals = [t80statarray(:); t80walkarray(:)];
velVec = [repelem(1, n, 1); repelem(2, n, 1); repelem(3, n, 1)];
velVec = [velVec; velVec]; % repeat for stat then walk;
stateVec = [repelem(1,3*n,1); repelem(2,3*n,1)];
subVec = repmat([1:n]',6,1);
factorNames = {'state', 'vel', 'subject'};

[p,tbl,stats,terms] = anovan(yvals,{stateVec velVec subVec},'model','interaction','varnames',{'walkState','Velocity','Subject'})

[c,m,h,nms] = multcompare(stats,'dimension', [1 2], 'display', 'on')

%% friedman
yv2 = [t80statarray; t80walkarray]

%%
%stats = rm_anova2(yvals,subVec,stateVec,velVec,factorNames)

%stats = rm_anova2(Y,S,F1,F2,FACTNAMES)
%
% function stats = rm_anova2(Y,S,F1,F2,FACTNAMES)
%
% Two-factor, within-subject repeated measures ANOVA.
% For designs with two within-subject factors.
%
% Parameters:
%    Y          dependent variable (numeric) in a column vector
%    S          grouping variable for SUBJECT
%    F1         grouping variable for factor #1
%    F2         grouping variable for factor #2
%    FACTNAMES  a cell array w/ two char arrays: {'factor1', 'factor2'}
%
%    Y should be a 1-d column vector with all of your data (numeric).
%    The grouping variables should also be 1-d numeric, each with same
%    length as Y. Each entry in each of the grouping vectors indicates the
%    level # (or subject #) of the corresponding entry in Y.
%
% Returns:



