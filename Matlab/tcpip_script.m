%% TCPIP comm between Unity/Matlab. Open Unity first

t = tcpip('127.0.0.1',10061,'NetworkRole','Client','Timeout',60);
fopen(t)
t

%%
data = '0,0,-40,s,29'
fwrite(t,data)
pause(0.5)

%%
while true
    trialResult = fread(t,1);
    disp(trialResult)
    
    if trialResult == 1
        pause(0.1) % needs to pause for sockets
        data = '0,0,40,s,12'; % 3d velocity vec, stat/walk, coherence
        fwrite(t,data)

    elseif trialResult == 0
        pause(0.1)
        data = '0,0,-40,w,12';
        fwrite(t,data)
    else
        continue

    end
end

%%
fclose(t)
delete(t)
clear