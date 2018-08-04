function [Trial] = SignalChop(adjust,n,time,TrialStart,TrialEnd)

%%
% adjust = 1 for downsample; 2 for upsample; 0 for no change to length

%% chop signal from each trial
for in = 1:n
    Trial(in).times = time(time > TrialStart & time < TrialEnd);
end

%% if down sample
if adjust == 1
sigleng = length(Trial(1).times);
for in = 1:length(Trial)
    if length(Trial(in).times) < sigleng
        sigleng = length(Trial(in).times);
    end
end
for in = 1:length(Trial)
    Trial(in).times = linspace(Trial(in).times(1,1),Trial(in).times(1,end),sigleng);
end
%% if up sample
elseif adjust == 2
sigleng = 0;
for in = 1:length(Trial)
    if length(Trial(in).times) > sigleng
        sigleng = length(Trial(in).times);
    end
end
for in = 1:length(Trial)
    Trial(in).times = linspace(Trial(in).times(1,1),Trial(in).times(1,end),sigleng);
end
end 
end