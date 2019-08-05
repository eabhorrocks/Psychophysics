load('A-MC-030619.mat')
% trial log can be found in results.allTrials. Rows correspond to:
% 1) sampling method
% 2) subsampling (staircase dir/order)
% 3) velocity
% 4) state (0 for stat, 1 for walking)
% 5) coherences/speed diff
% 6) response (0 = towards/1st; 1 = away/2nd)

%% Extract just the slow trials
% get the index (columns of the array) of trials that were with the slow
% speed
slowSpeed = 15;
slowVelIndex = find(results.allTrials(3,:)==slowSpeed);
% extract just the slow trials from the results.allTrials array
slowTrials = results.allTrials(:,slowVelIndex);

%% analyse the repeated trials for each coherence value
% find the different coherences that were tested (found in 5th row of the
% array)
unique_coherences = unique(slowTrials(5,:));

% initialise an array to save our data into.
% this will have the structure: 
% 1st column: coherence value
% 2nd column: number of 'toward' responses
% 3rd column: total number of repeats for this speed/coherence value

data = NaN*ones(numel(unique_coherences), 3); 
data(:,1) = unique_coherences;

% for loop to go through each unique coherence value
for icoh = 1:numel(unique_coherences)
     
    % get the index of all trials with this coherence value
     idx = find(slowTrials(5,:)==unique_coherences(icoh));
     
     % you can look at these trials with this, just remove the semi colon
     % you can see all trials are all the same speed and coherence
     slowTrials(:,idx);
     % this finds for these trials which responses were 0 (indicating a
     % 'towards' response) and then counts them (this is the numel() part).
     % We assign this to the 2nd column of the data array for the icoh row
     % (the row assigned for this coherence);
     data(icoh,2) = numel(find(slowTrials(6,idx)==0)); 
     
     % now we assign to the 3rd column the total number of repeats, simply:
     data(icoh,3) = numel(idx);
     
end
     
% look at the array:
data
% this is the format psignifit likes the data to be in to plot the full
% psychometric curve, but first we should just plot the raw data. 

% Since we have the total number of repeats for each coherence, and the number
% of 'towards' responses for each coherence, we divide the total repeats by
% the number of 'towards' responses to get a 'proportion towards responses'
% which will range between 0 and 1.

proportionTowards = data(:,2)./data(:,3); % the ./ does elementwise division
% meaning that it will take the element in the 2nd column for each row and
% divide by the element in the 3rd column of the same row.

% plot the data:
figure
plot(data(:,1), proportionTowards, 'ko', 'MarkerFaceColor', 'k')
grid on
xlabel('Coherence Value')
ylabel('Proportion Towards Responses')
title('Psychometric curve for slow speed')

%% using the psignifit toolbox

options.expType = 'YesNo'; % we need this option to plot the full curve
slowresult = psignifit(data, options);
figure
plotPsych(slowresult)

% you can see that the toolbox provides some nice plotting features, such
% as changing the size of the dots proportional to the number of repeats.
% It also needs some work - e.g. the y-axis label is not correct for our
% purposes.




