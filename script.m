% Decription of purpose
% Users/Owners
% Date of modification

clear all 
close all

% Add Path
hc_hyperalign_path = '/Users/mac/Projects/hc_hyperalign';
addpath([hc_hyperalign_path '/utils'])
addpath([hc_hyperalign_path '/hypertools_matlab_toolbox'])

% load data
datatoload = '/R042-2013-08-18/'; % sub42
% datatoload = '/R044-2013-12-21/'; % sub44
% datatoload = '/R064-2015-04-20/'; % sub64

load([hc_hyperalign_path '/Data' datatoload 'metadata.mat']) % metadata
load([hc_hyperalign_path '/Data' datatoload 'Spikes.mat']) % metadata

% Common binning and windowing configurations.
cfg = [];
cfg.dt = 0.05;
cfg.smooth = 'gauss';
cfg.gausswin_size = 1;
cfg.gausswin_sd = 0.02;

% The end times of left and right trials.
left_tend = metadata.taskvars.trial_iv_L.tend;
right_tend = metadata.taskvars.trial_iv_R.tend;

% PCA
pca_input = [];

% Do the left trials first.
for i = 1:length(left_tend)
    % Regularize the trials
    reg_S.left{i} = restrict(S, left_tend(i) - 5, left_tend(i));
    
    % Produce the Q matrix (Neuron by Time)
    cfg.tvec_edges = left_tend(i)-5:cfg.dt:left_tend(i);
    Q.left{i} = MakeQfromS(cfg, reg_S.left{i});
    % By z-score the smoothed binned spikes, we try to decorrelate the
    % absolute spike rate with the later PCAed space variables.
    % The second variable determine using population standard deviation
    % (1 using n, 0(default) using n-1)
    % The third argument determine the dim, 1 along columns and 2 along
    % rows.
    Q.left{i}.data = zscore(Q.left{i}.data, 0, 2);
    
    % Produce to the input matrix for PCA
    pca_input = [pca_input Q.left{i}.data];
end

% Do the right trials later. DRY: I will make it as a function if it
% happens third times.
for i = 1:length(right_tend)
    reg_S.right{i} = restrict(S, right_tend(i) - 5, right_tend(i));
    
    cfg.tvec_edges = right_tend(i)-5:cfg.dt:right_tend(i);
    Q.right{i} = MakeQfromS(cfg, reg_S.right{i});
    Q.right{i}.data = zscore(Q.right{i}.data, 0, 2);
    
    pca_input = [pca_input Q.right{i}.data];
end

NumComponents = 10;
[eigvecs] = pca_egvecs(pca_input, NumComponents);

%  project all other trials (both left and right trials) to the same dimension
for i = 1:size(Q.left,2)
    InputMatrix = Q.left{i}.data;
    Recon_Q.left{i}.Q = pca_project(InputMatrix, eigvecs);
end
for i = 1:size(Q.right,2)
    InputMatrix = Q.right{i}.data;
    Recon_Q.right{i}.Q = pca_project(InputMatrix, eigvecs);
end

%% Plot the data 
mat = Recon_Q;
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


save sub42_new.mat all_right all_left



%% Do the hyperalignment

load sub42_new.mat 
lMats{1}=all_left;

load sub44_new.mat 
lMats{2}=all_left;

load sub64_new.mat 
lMats{3}=all_left;

load sub42_new.mat 
lMats{4}=all_right;

load sub44_new.mat 
lMats{5}=all_right;

load sub64_new.mat 
lMats{6}=all_right;

[alighleft, averaged_transforms] = hyperalign(lMats{1:3});

% Z = TRANSFORM.b * Y .* TRANSFORM.T + TRANSFORM.c;

alighright{1} = totransform(averaged_transforms{1},lMats{4});
alighright{2} = totransform(averaged_transforms{2},lMats{5});
alighright{3} = totransform(averaged_transforms{3},lMats{6});

z{1} = totransform(averaged_transforms{1},lMats{1});
z{2} = totransform(averaged_transforms{2},lMats{2});
z{3} = totransform(averaged_transforms{3},lMats{3});

% function Z = totransform(TRANSFORM,Y)
% Z = TRANSFORM.b * Y * TRANSFORM.T + TRANSFORM.c;
% end


% alighright{1} = averaged_transforms{4}.T*lMats{4};
% alighright{2} = averaged_transforms{5}.T*lMats{5};
% alighright{3} = averaged_transforms{6}.T*lMats{6};

%%
% left
trajectory_plotter(10, alighleft{1}, alighleft{2}, alighleft{3});
title('hyperaligned left trials');

% right
trajectory_plotter(10, alighright{1}, alighright{2}, alighright{3});
title('hyperaligned right trials');

% non-aligned right trials
trajectory_plotter(10, lMats{4}, lMats{5}, lMats{6});
title('non-aligned right trials');


% trajectory_plotter(20, z{1}, z{2}, z{3});
% figure(2) % aligned
% trajectory_plotter('trajectories_test', 30, aligned{1}, aligned{2}, aligned{3});