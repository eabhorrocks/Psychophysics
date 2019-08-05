set(0,'DefaultFigureWindowStyle','docked')

fileNames = {};
folderFiles = dir;
for i = 3:numel(dir)
fileNames{i-2} = folderFiles(i).name;
end

%%
tic
for i = 1:numel(fileNames)
figure
a(i) = devMCanalysis(fileNames{i});
end
toc

