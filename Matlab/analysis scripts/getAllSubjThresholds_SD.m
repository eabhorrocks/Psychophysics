%% Script to plot all data.

fileNames = ...
    {'ASD-full-030619.mat';...
    'B-SD-full-030619.mat';...
    'C-SD-full-040619.mat';...
    'D-SD-full-040619.mat';...
    'E-SD-full-040619.mat';...
    'F-SD-full-040619.mat';...
    'G-SD-full-040619.mat'}

threshStruct = struct;
%%

for ifile = 1:numel(fileNames)
    load(fileNames{ifile})
    
    test = results.allTrials;
    correct = (test(5,:)>0 & test(6,:)==1) | (test(5,:)<0 & test(6,:)==0);
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
            
            a.res(ivel,istate).kval(icoh).nForward =...
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
        a.res(ivel).psigresult.deviance
    end
    
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
    
%biasAna(negData,posData,options)

absKs = unique(abs(uniqueKs));
trialAbsConvert = [abs(trialSet2(1,:)); trialSet2(2,:)];

allData = NaN*ones(numel(absKs),3);
for i = 1:numel(absKs)
    idx = find(trialAbsConvert(1,:)==absKs(i));
    allData(i,1) = absKs(i); % x val
    allData(i,2) = sum(trialAbsConvert(2,idx)); % n correct
    allData(i,3) = numel(idx); % n trials
end 

pos.res = psignifit(posData,options);
neg.res = psignifit(negData,options);
all.res = psignifit([posData; negData],options);

[pos.threshold,pos.CI] = getThreshold(pos.res, 0.8, true);
[neg.threshold,neg.CI] = getThreshold(neg.res, 0.8, true);
[all.threshold,all.CI] = getThreshold(all.res, 0.8, true);
[signed.threshold, signed.CI] = getThreshold(a.res(ivel).psigresult, 0.5, true);

threshStruct.vel(ivel).pT(ifile) = pos.threshold;
threshStruct.vel(ivel).nT(ifile) = neg.threshold;
threshStruct.vel(ivel).aT(ifile) = all.threshold;
threshStruct.vel(ivel).bias(ifile) = signed.threshold;

end

%pos, neg, all, signed
    
end


%% scatter comparing +ve versus -ve coherence thresholds

Markers = {'+','o','*','x','v','d','s','^','>','<'};
ColorArray =[0, 0, 1;...
    1, 0, 0;...
    0.9290,0.6940,0.125;...
    0.4940,0.1840,0.5560;...
    0.4660,0.674,0.188;...
    0.3010,0.7450,0.9330;...
    0,0,0];

figure(1)
hold on
for isubj = 1:numel(fileNames)
plot(threshStruct.vel(1).pT(isubj), threshStruct.vel(1).nT(isubj),'Color',ColorArray(isubj,:),'Marker',Markers{1},'MarkerSize',8,'MarkerFaceColor',ColorArray(isubj,:))
plot(threshStruct.vel(2).pT(isubj), threshStruct.vel(2).nT(isubj),'Color',ColorArray(isubj,:),'Marker',Markers{5},'MarkerSize',8,'MarkerFaceColor',ColorArray(isubj,:))
plot(threshStruct.vel(3).pT(isubj), threshStruct.vel(3).nT(isubj),'Color',ColorArray(isubj,:),'Marker',Markers{3},'MarkerSize',8,'MarkerFaceColor',ColorArray(isubj,:))
plot([0 3], [0 3], 'k--')
legend({'slow', 'med', 'fast'})
xlabel('Positive SD')
ylabel('Negative SD')
title('80% correct threshold values')
grid on, box off
end

%
figure(2), hold on
[v1vec, v2vec, v3vec] = threshStruct.vel.aT;
cats = categorical({'v1', 'v2', 'v3'});
bar(cats,mean([v1vec', v2vec', v3vec']), 'FaceAlpha', 1,'FaceColor',[.6 .6 .6])
hb = bar(cats,([v1vec; v2vec; v3vec;]));
e = errorbar(cats,mean([v1vec', v2vec', v3vec']),std([v1vec', v2vec', v3vec'])/sqrt(numel(v1vec)),'Marker','none')
e.LineStyle = 'none';
e.LineWidth = 1.5;
e.Color = [0 0 0];
e.Marker = 'none';
hold off


for isubj = 1:numel(fileNames)
hb(isubj).FaceColor = ColorArray(isubj,:);
end
grid on, box off
ylabel('Combined order SD')
title('Joint 80% thresholds by velocity')
xlabel('Velocity condition')
%
figure(3), hold on
[v1b, v2b, v3b] = threshStruct.vel.bias;
bar(cats,mean([v1b', v2b', v3b']), 'FaceAlpha', 1,'FaceColor',[.6 .6 .6])
hb2 = bar(cats,([v1b; v2b; v3b;]));
e2 = errorbar(cats,mean([v1b', v2b', v3b']),std([v1b', v2b', v3b'])/sqrt(numel(v1b)),'Marker','none')
e2.LineStyle = 'none';
e2.LineWidth = 1.5;
e2.Color = [0 0 0];
e2.Marker = 'none';
title('Points of Subjective Equality by Velocity')
ylabel('Signed SD')
xlabel('Velocity Condition')
grid on
box off
hold off

for isubj = 1:numel(fileNames)
hb2(isubj).FaceColor = ColorArray(isubj,:);
end
%
figure(4)
hold on
[vp] = [threshStruct.vel.pT];
[vn] = [threshStruct.vel.nT];

cat2 = categorical({'Pos SD', 'Neg SD'});
cat2 = reordercats(cat2, {'Pos SD', 'Neg SD'});
hb3 = bar(cat2, [mean(vp), mean(vn)]);
hb3.FaceColor = [0.6 0.6 0.6];
e3 = errorbar(cat2,[mean(vp),mean(vn)],std([vp', vn'])/sqrt(numel(vp)),'Marker','none')
e3.LineStyle = 'none';
e3.LineWidth = 1.5;
e3.Color = [0 0 0];
e3.Marker = 'none';
grid on, box off
ylabel('SD')
xlabel('Order')
title('Mean 80% SD Threshold, collapsed over velocity')
[h,p] = ttest(vn,vp);
text(1.5, 0.9,string(['p = ' num2str(p)]),'HorizontalAlignment','Center')
