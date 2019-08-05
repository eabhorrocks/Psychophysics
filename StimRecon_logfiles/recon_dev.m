%% Stimulus reconstruction development script

% issues, think import funcs will fail with varying number of dots...

% dirs: 
% [0, pi/2, pi, 3pi/2, 2pi]
% [away, right, towards, left, away]
% x dec is to the left, x inc to the right
% z dec is towards, z inc away
% so unit vector is [z x] = pol2cart(angle,1);

params.dotLifetime = 0.2;
params.stimDur = 0.6;



%% import and create basic data struct


% import dot positions 
dspa = importDotPosAsStringArray('recon-testdotPos.txt');
trialStrings = dspa(:,1);
dspa(:,1) = []; % strip trial num column

% import life inis
lifea = importDotLifeiniAsArray('recon-testinilife.txt');
lifea(:,1) = []; % remove trial num tags  - could check none skipped first?

% import VM assigned directions + trial velocity (column 2).
vma = importVMdirAsArray('recon-testvmdist.txt');
vels = vma(:,2);
vma(:,1:2) = [];

% create struct
nTrials = size(dspa,1);
nDots = size(dspa,2);

trial = struct;
for itrial = 1:nTrials
    for idot = 1:nDots
        % assign variables from text files
        allPos = textscan( dspa(itrial,idot), '%f', 'Delimiter',',' );
        allPos = allPos{1};
        trial(itrial).vel = vels(itrial);
        trial(itrial).dot(idot).allposes = reshape(allPos,[],3);
        trial(itrial).dot(idot).inilife = lifea(itrial,idot);
        trial(itrial).dot(idot).dir = vma(itrial,idot);
        [z, x] = pol2cart(trial(itrial).dot(idot).dir,1);
        unitVector = [x 0 z];
        trial(itrial).dot(idot).moveVec = unitVector*trial(itrial).vel;
        
        % get teleport times
        iniTel = params.dotLifetime - trial(itrial).dot(idot).inilife;
        trial(itrial).dot(idot).teltime =...
            iniTel:params.dotLifetime:params.stimDur;
        trial(itrial).dot(idot).delTime =...
            [iniTel, diff(trial(itrial).dot(idot).teltime), params.stimDur-trial(itrial).dot(idot).teltime(end)];
        
        % get each trajectory for dots
        for itraj = 1:numel(trial(itrial).dot(idot).delTime) 
            trial(itrial).dot(idot).traj(itraj).traj = ...
        [trial(itrial).dot(idot).allposes(itraj,:);...
        trial(itrial).dot(idot).allposes(itraj,:)+...
        (trial(itrial).dot(idot).delTime(itraj)*trial(itrial).dot(idot).moveVec)];
        end
        
        clear allPos iniTel z x unitVector
    end
end


figure, hold on
itrial = 3;
for idot = 10
xVec = [];
zVec = [];
yVec = [];
for i = 1:4
xVec = [xVec, trial(itrial).dot(idot).traj(i).traj(1,1), trial(itrial).dot(idot).traj(i).traj(2,1), NaN];
yVec = [yVec, trial(itrial).dot(idot).traj(i).traj(1,2), trial(itrial).dot(idot).traj(i).traj(2,2), NaN];
zVec = [zVec, trial(itrial).dot(idot).traj(i).traj(1,3), trial(itrial).dot(idot).traj(i).traj(2,3), NaN];
plot3(xVec,zVec,yVec)

end
end

xlabel('x');
ylabel('z');
zlabel('y');


% need trial.speed, could log in vmDist?
% at what times does the dot teleport, based on dot.lifetime and lifeini...
% reconstruct trajectory?? at every 0.05 s? something like that?
% simplest first step is to weight according to real-world pos.
% i.e. cube up the area, x,y,z.

%% import dot life initialisations
