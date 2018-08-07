% Decription of purpose
% Users/Owners
% Date of modification

clear all 
close all

% Add Path
hc_hyperalign_path = '/Users/weizhenxie/Documents/Jupyter/mind2018/hc_hyperalign';
addpath([hc_hyperalign_path '/SpecFun'])
addpath([hc_hyperalign_path '/hypertools_matlab_toolbox'])

% load data
%datatoload = '/R042-2013-08-18/'; % sub42
%datatoload = '/R044-2013-12-21/'; % sub44
datatoload = '/R064-2015-04-20/'; % sub64

load([hc_hyperalign_path '/Data' datatoload 'metadata.mat']) % metadata
load([hc_hyperalign_path '/Data' datatoload 'Spikes.mat']) % metadata

%% Regularize left and right trials
wholetrial = 1;
if wholetrial
    TSE_L(:, 1) = metadata.taskvars.trial_iv_L.tstart;
    TSE_L(:, 2) = metadata.taskvars.trial_iv_L.tend;
    TSE_R(:, 1) = metadata.taskvars.trial_iv_R.tstart;
    TSE_R(:, 2) = metadata.taskvars.trial_iv_R.tend;
    reg_trials = RegularizedTrials(TSE_L, TSE_R,5); % extract data from the last 5 seconds
else  
    load([hc_hyperalign_path '/Data' '/R042-2013-08-18/' 'StemSE.mat']) % metadata
    opt =[];
    reg_trials = RegularizedTrials(StemSE_L, StemSE_R,opt); 
end

%Produce the Q matrix (Neuron by Time)
Qmat = generateQmatrix(reg_trials, S, 0, 0.05);

% smooth the data 
for itr = 1:size(Qmat.left,2)
    for it=1:size(Qmat.left{itr}.Q,1)
      SmoothQ.left{itr}.Q(it,:) = zscore(smoothdata(Qmat.left{itr}.Q(it,:),'gaussian',30));
    end
end

for itr = 1:size(Qmat.right,2)
    for it=1:size(Qmat.right{itr}.Q,1)
      SmoothQ.right{itr}.Q(it,:) = zscore(smoothdata(Qmat.right{itr}.Q(it,:),'gaussian',30));
    end
end



%% PCA 
InputMatrix =[];
for i = 1:size(Qmat.right,2)
    InputMatrix=[InputMatrix Qmat.right{i}.Q];
end
for i = 1:size(Qmat.left,2)
    InputMatrix=[InputMatrix Qmat.left{i}.Q];
end

% InputMatrix = SmoothQ.left{1}.Q; 
NumComponents = 10;
[Egvecs]=pca_egvecs(InputMatrix,NumComponents);

InputMatrix=[];
%  project all other trials (both left and right trials) to the same dimension
for i = 1:size(SmoothQ.left,2)
    InputMatrix = SmoothQ.left{i}.Q;
    Recon_Qmat.left{i}.Q = pca_project(InputMatrix,Egvecs);
end
for i = 1:size(Qmat.right,2)
    InputMatrix = SmoothQ.right{i}.Q;
    Recon_Qmat.right{i}.Q = pca_project(InputMatrix,Egvecs);
end

%% Plot the data 
mat = Recon_Qmat;
figinx = 101;

colors = linspecer(2);
% need to fix the trial level 
for i = 1: numel(mat.left)
    Q_left(:,:,i) = mat.left{i}.Q;
    figure(figinx); 
    p1=plot3(Q_left(:,1,i), Q_left(:,2,i), Q_left(:,3,i), '-','color',[0 0 1],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
end
grid on;

for i = 1:numel(mat.right)
    Q_right(:,:,i) = mat.right{i}.Q;
    figure(figinx);
    p1=plot3(Q_right(:,1,i), Q_right(:,2,i), Q_right(:,3,i), '-','color',[1 0 0],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
end
grid on;

% plot the average
all_right = mean(Q_right,3);
figure(figinx);
p1=plot3(all_right(:,1), all_right(:,2), all_right(:,3), '-','color',[1 0 0],'LineWidth',3);
p1.Color(4) = 1;
xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')

all_left = mean(Q_left,3);
figure(figinx);hold on
p1=plot3(all_left(:,1), all_left(:,2), all_left(:,3), '-','color',[0 0 1],'LineWidth',3);
p1.Color(4) = 1;
xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')
title([datatoload ' : Blue - Left, Red - Right'])


save sub64.mat all_right all_left

%% Do the hyperalignment

load sub42.mat 
lMats{1}=all_left;

load sub44.mat 
lMats{2}=all_left;

load sub64.mat 
lMats{3}=all_left;

load sub42.mat 
lMats{4}=all_right;

load sub44.mat 
lMats{5}=all_right;

load sub64.mat 
lMats{6}=all_right;

[alighleft, averaged_transforms] = hyperalign(lMats{1:3});

% 
alighright{1} = averaged_transforms{1}.T*lMats{3};
alighright{2} = averaged_transforms{2}.T*lMats{4};
alighright{3} = averaged_transforms{3}.T*lMats{5};

% alighright{1} = averaged_transforms{4}.T*lMats{4};
% alighright{2} = averaged_transforms{5}.T*lMats{5};
% alighright{3} = averaged_transforms{6}.T*lMats{6};


trajectory_plotter(20, alighright{1}, alighright{2}, alighright{3});
trajectory_plotter(20, alighleft{1}, alighleft{2}, alighleft{3});

% figure(2) % aligned
% trajectory_plotter('trajectories_test', 30, aligned{1}, aligned{2}, aligned{3});

