function [RT] = RegularizedTrials(TSE)
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
% TSE: matrices of start and end times for each trial (Trials X 
%       2) for all trials of a given type, even if there are more than two
%       (left or right, correct or incorrect, etc.)
%
%
% OUTPUTS:
% 
% RT: Structure array with structure elements corrosponding to input 1 and
%       2, and contents of a matrix of adjusted start and end time for each
%       trial (i.e. RT.A and RT.B each containing N X 2 matrices).

for k = 1:length(TSE);
for i = 1:length(TSE{1,1})
    dif{k,:}(i,1) = TSE{k,:}(i,2) - TSE{k,:}(i,1);
end
end

for k = 1:length(TSE);
for i = 1:length(dif{1,1})
    search{k,:}(i,1) = min(dif{k,:});
end
    temp(k,1) = min(search{k,:});
end
Shortest = min(temp);
clear search dif temp;

for k = 1:2;
for i = 1:length(TSE{1,1})
    RT{k,:}(i,1) = TSE{k,:}(i,2) - Shortest;
    RT{k,:}(i,2) = TSE{k,:}(i,2);
end
end

clear i j k Shortest;

end

