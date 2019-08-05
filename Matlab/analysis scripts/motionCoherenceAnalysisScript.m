%% exmaple analysis script

% load matlab results data
% load('eh-16019test2.mat')

%[results.info.rxx(results.cond(2).seqdat.i)' results.cond(2).seqdat.y]

%% plot raw data
nConds = numel(results.cond);
for icond = 1:nConds
    figure
% plot trials for a specific condition.
for idx = 1:numel(results.cond(icond).seqdat.i)
if results.cond(icond).seqdat.y(idx) == 1
colR = [0 1 0];
else colR = [0 0 1];
end

plot(idx, results.info.rxx(results.cond(icond).seqdat.i(idx)), 'o', 'color', colR), hold on
end
hold on,
plot([1 idx], [0 0], 'k--')
end


%% plot psychometric function
% options, e.g. what function to fit etc..
analysis = struct;

for icond = 1:numel(results.cond)
testdata = results.cond(icond);

kappa = results.info.rxx(testdata.seqdat.i);
uniqueKappa = unique(kappa);

for i = 1:numel(uniqueKappa) 
    analysis(icond).trials(i).idx = find(kappa == uniqueKappa(i));
    analysis(icond).trials(i).kval = uniqueKappa(i);
    analysis(icond).trials(i).res = testdata.seqdat.y(analysis(icond).trials(i).idx);
    analysis(icond).trials(i).nTrials = numel(analysis(icond).trials(i).idx);
    analysis(icond).trials(i).resProp = 1 - (sum(analysis(icond).trials(i).res))/analysis(icond).trials(i).nTrials;
end

psigMatrix = [analysis(icond).trials.kval; analysis(icond).trials.resProp; analysis(icond).trials.nTrials]';
analysis(icond).result = psignifit(psigMatrix)
analysis(icond).standardParams = getStandardParameters(analysis(icond).result);

figure, hold on, grid on, title(['condition: ' num2str(icond)]);
plotPsych(analysis(icond).result)

%for i = 1:numel(uniqueKappa)
%    plot(analysis(icond).trials(i).kval, analysis(icond).trials(i).resProp, 'b.', 'MarkerSize', 3 + analysis(icond).trials(i).nTrials)
%end

clear kappa uniqueKappa
end


%% get thresholds, bias and sensitivity... (see macbook data...)
% collapse -ve and +ve kappa values, treat trials as identical...

for icond = 1:numel(results.cond)
testdata = results.cond(icond);

% get whether response was correct or not
test = [results.cond(icond).seqdat.x, results.cond(icond).seqdat.y];
for i = 1:length(test)
if ((test(i,1) > 0 && test(i,2)==0) || (test(i,1) < 0 && test(i,2)==1))
correctVec(i) = 1;
else
correctVec(i) = 0;
end
end

kappa = abs(results.info.rxx(testdata.seqdat.i));
uniqueKappa = unique(kappa);

for i = 1:numel(uniqueKappa)
    analysis(icond).trials(i).idx = find(kappa == uniqueKappa(i));
    analysis(icond).trials(i).kval = uniqueKappa(i);
    analysis(icond).trials(i).nCorrect = sum(correctVec(analysis(icond).trials(i).idx));
    analysis(icond).trials(i).nTrials = numel(analysis(icond).trials(i).idx);
end


psigMatrix = [analysis(icond).trials.kval; analysis(icond).trials.nCorrect; analysis(icond).trials.nTrials]';

analysis(icond).result = psignifit(psigMatrix);
figure, title([num2str(icond)]);
plotPsych(analysis(icond).result)
analysis(icond).thresh = getThreshold(analysis(icond).result, 0.95)
analysis(icond).standardParams = getStandardParameters(analysis(icond).result);

%for i = 1:numel(uniqueKappa)
%    plot(analysis(icond).trials(i).kval, analysis(icond).trials(i).resProp, 'b.', 'MarkerSize', 3 + analysis(icond).trials(i).nTrials)
%end

clear kappa uniqueKappa
end



%% tracking data
% load tracking data
uniqueTrials = unique(trialNum);

for itrial = numel(uniqueTrials):-1:1
    trials(itrial).idx = find(trialNum==itrial);
end

for itrial = 1:numel(uniqueTrials)
    x = xpos(trials(itrial).idx);
    z = zpos(trials(itrial).idx);
    t = time(trials(itrial).idx);
    dx = diff(x);
    dz = diff(z);
    dt = diff(t);
    trials(itrial).speed = sqrt(dx.^2 + dz.^2) ./ dt;
    trials(itrial).meanSpeed = mean(trials(itrial).speed);
end

%% catenate meanSpeeds to trialOrders
    
