
% PCA demo
close all 
clear all 
%load example data
load T_maze_demo.mat pos1 Q1 


addpath('/Users/weizhenxie/Documents/Jupyter/mind2018/hc_hyperalign/history/PCA_module')

M{1} = Q1(:,1:10000);
M{2} = Q1(:,10001:20000);
M{3} = Q1(:,20001:30000);
M{4} = Q1(:,30001:40000);

%%


InputMatrix = M{1}; 
NumComponents = 3;
[Egvecs]=pca_egvecs(InputMatrix,NumComponents);

InputMatrix=[]

%  project all other trials (both left and right trials) to the same dimension
for i = 1:size(M,2)
    InputMatrix = M{i};
    Recon_Qmat{i} = pca_project(InputMatrix,Egvecs);
end


%%
mat = Recon_Qmat;
figinx = 101;

for i = 1:size(M,2)
    Q = Recon_Qmat{i};
    figure(figinx);plot3(Q(:,1), Q(:,2), Q(:,3), '.-');
    WaitSecs(1);
    hold on;
end


