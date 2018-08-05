function [RT] = RegularizedTrials(TSE_A,TSE_B)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(TSE_A)
    dif_A(i,1) = TSE_A(i,2) - TSE_A(i,1);
    dif_B(i,1) = TSE_B(i,2) - TSE_B(i,1);
end

for i = 1:length(dif_A)
    search(i,1) = min(dif_A);
    search(i,2) = min(dif_B);
    Shortest = min(min(search));
end
clear search dif_A dif_B
for i = 1:length(TSE_A)
    RT_A(i,1) = TSE_A(i,2) - Shortest;
    RT_A(i,2) = TSE_A(i,2);
    RT_B(i,1) = TSE_B(i,2) - Shortest;
    RT_B(i,2) = TSE_B(i,2);
end
clear Shortest
for i = 1:size(RT_A,1)
    for j = 1:size(RT_A,2);
        RT.A(i,j) = RT_A(i,j);
        RT.B(i,j) = RT_B(i,j);
    end
end
clear i j RT_A RT_B

end

