%%
% adjust = 1 for downsample adjust = 2 for upsample
adjust = 1;
%% chop signal from each trial
for i = 1:length(Int)
    temp{i,:} = time(time > Int(i,1) & time < Int (i,5));
end
%% not resizing
if adjust == 0;
for i = 1:length(temp)
    Time{i,:} = linspace(temp{i,:}(1,1),temp{i,:}(1,end),sigleng);
end
%% if down sample
elseif adjust == 1;
sigleng = length(temp{i,:});
for i = 1:length(temp)
    if length(temp{i,:}) < sigleng
        sigleng = length(temp{i,:});
    end
end
for i = 1:length(temp)
    Time{i,:} = linspace(temp{i,:}(1,1),temp{i,:}(1,end),sigleng);
end
clear temp adjust i sigleng;
%% if up sample
elseif adjust == 2
sigleng = 0;
for i = 1:length(temp)
    if length(temp{i,:}) > sigleng
        sigleng = length(temp{i,:});
    end
end
for i = 1:length(temp)
    Time{i,:} = linspace(temp{i,:}(1,1),temp{i,:}(1,end),sigleng);
end
clear temp adjust i sigleng;
end 