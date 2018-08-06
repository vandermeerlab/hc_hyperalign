function [RT] = RegularizedTrials(TSE_L,TSE_R,opt)
% 
% Regularize Trial Lengths
%
%   This script takes the user generate input of start and end times for
% for trials, but expects them to generate trials of different lengths, 
% due to variability in rat running behavior. The output then, accordin to
% user-configured options, is to adjust the length of the trial to a
% standard length.
%
% INPUTS:
%
% TSE_A & TSE_B: matrices of start and end times for each trial (Trials X 
%       2) for all trials of a given type (left or right, correct or 
%       incorrect, etc.)
% Opt: Input is in seconds. Option for defining a specific time duration 
% for the legnth of a trial, based on counting back from the trial end by 
% that many seconds
%
% OUTPUTS:
% 
% RT: Structure array with structure elements corrosponding to input 1 and
%       2, and contents of a matrix of adjusted start and end time for each
%       trial (i.e. RT.A and RT.B each containing N X 2 matrices).

if opt==[]
for i = 1:length(TSE_L)
    dif_A(i,1) = TSE_L(i,2) - TSE_L(i,1);
end
for i = 1:length(TSE_R)
    dif_B(i,1) = TSE_R(i,2) - TSE_R(i,1);
end

for i = 1:length(dif_A)
    search(i,1) = min(dif_A);
end
for i = 1:length(dif_B)
    search(i,2) = min(dif_B);
    Shortest = min(min(search));
end
    Shortest = min(min(search));
clear search dif_A dif_B

for i = 1:length(TSE_L)
    RT_A(i,1) = TSE_L(i,2) - Shortest;
    RT_A(i,2) = TSE_L(i,2);
end
for i = 1:length(TSE_R)
    RT_B(i,1) = TSE_R(i,2) - Shortest;
    RT_B(i,2) = TSE_R(i,2);
end
clear Shortest

else
    for i = 1:length(TSE_L)
    RT_A(i,1) = TSE_L(i,2) - opt;
    RT_A(i,2) = TSE_L(i,2);
    end
    for i = 1:length(TSE_R)
    RT_B(i,1) = TSE_R(i,2) - opt;
    RT_B(i,2) = TSE_R(i,2);
    end
    
RT.left = RT_A;
RT.right = RT_B;
clear i j RT_A RT_B

end
end

