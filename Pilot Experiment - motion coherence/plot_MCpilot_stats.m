load('MotionCoherence_paramSpace2.mat')

%paramSpace(isig,in).vel(ivel).fullPsych.t50 = signed.threshold;

% isig = 4;
% 
% for i = 1:size(paramSpace,2)
%     for ivel = 1:3
%     PSEvec(ivel,i) = paramSpace(isig,i).vel(ivel).fullPsych.t50;
%     PSECIvec(ivel,i) = paramSpace(isig,i).vel(ivel).fullPsych.t50CI(2)-paramSpace(isig,i).vel(ivel).fullPsych.t50CI(1);
%     
%     allt80vec(ivel,i) = paramSpace(isig,i).vel(ivel).allData.t80;
%     allt80vecCI(ivel,i) = paramSpace(isig,i).vel(ivel).allData.t80CI(2) - paramSpace(ivel,i).vel(ivel).allData.t80CI(1);
%     
%     allDev(ivel,i) = paramSpace(isig,i).vel(ivel).allData.deviance;
%     end
% end
% 

figure, hold on
for ivel = 1:3
    for isub = 1:size(paramSpace,3)
        for in = 1:size(paramSpace,2)
            vel(ivel).psevec(isub,in) = paramSpace(1,in,isub).vel(ivel).fullPsych.t50;
            vel(ivel).pseCIvec(isub,in) = paramSpace(1,in,isub).vel(ivel).fullPsych.t50CI(2)-paramSpace(1,in,isub).vel(ivel).fullPsych.t50CI(1);
            vel(ivel).fpsydev(isub,in) = paramSpace(1,in,isub).vel(ivel).fullPsych.deviance;
            
            vel(ivel).allt80(isub,in) = paramSpace(1,in,isub).vel(ivel).allData.t80;
            vel(ivel).allt80CI(isub,in) = paramSpace(1,in,isub).vel(ivel).allData.t80CI(2)- paramSpace(1,in,isub).vel(ivel).allData.t80CI(1);
            vel(ivel).post80(isub,in) = paramSpace(1,in,isub).vel(ivel).posData.t80;
            vel(ivel).post80CI(isub,in) = paramSpace(1,in,isub).vel(ivel).posData.t80CI(2)- paramSpace(1,in,isub).vel(ivel).posData.t80CI(1);
            vel(ivel).negt80(isub,in) = paramSpace(1,in,isub).vel(ivel).negData.t80;
            vel(ivel).negt80CI(isub,in) = paramSpace(1,in,isub).vel(ivel).negData.t80CI(2)- paramSpace(1,in,isub).vel(ivel).negData.t80CI(1);
        end
       
    end
    plot([50:50:574, 574], mean(vel(ivel).psevec))
    plot([50:50:574, 574], mean(vel(ivel).allt80), 'LineStyle', '--')
    %plot([50:50:574, 574], mean(vel(ivel).negt80CI), 'LineStyle', ':')
    
end
            
            
        
