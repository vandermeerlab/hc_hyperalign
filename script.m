% Decription of purpose
% Users/Owners
% Date of modification

clear all 
close all

% Add Path
hc_hyperalign_path = '/Users/weizhenxie/Documents/Jupyter/mind2018';

addpath([hc_hyperalign_path '/hc_hyperalign/SpecFun'])
addpath([hc_hyperalign_path '/hc_hyperalign/R042-2013-08-18'])

% load data
load('metadata.mat') % metadata
load('Spikes.mat') % metadata


%% Regularize left and right trials
TSE_L(:, 1) = metadata.taskvars.trial_iv_L.tstart;
TSE_L(:, 2) = metadata.taskvars.trial_iv_L.tend;
TSE_R(:, 1) = metadata.taskvars.trial_iv_R.tstart;
TSE_R(:, 2) = metadata.taskvars.trial_iv_R.tend;

reg_trials = RegularizedTrials(TSE_L, TSE_R,5); % extract data from the last 5 seconds

%% Produce the Q matrix (Neuron by Time)
Qmat = generateQmatrix(reg_trials, Spikes, 0);

%%

% smooth the data 
for itr = 1:size(Qmat.left,2)
    for it=1:size(Qmat.left{itr}.Q,1)
      SmoothQ.left{itr}.Q(it,:) = zscore(smoothdata(Qmat.left{itr}.Q(it,:),'gaussian',20));
    end
end

for itr = 1:size(Qmat.right,2)
    for it=1:size(Qmat.right{itr}.Q,1)
      SmoothQ.right{itr}.Q(it,:) = zscore(smoothdata(Qmat.right{itr}.Q(it,:),'gaussian',20));
    end
end



%% PCA 
InputMatrix =[];
for i = 1:size(Qmat.left,2)
    InputMatrix=[InputMatrix Qmat.left{i}.Q];
end

for i = 1:size(Qmat.right,2)
    InputMatrix=[InputMatrix Qmat.right{i}.Q];
end

% InputMatrix = SmoothQ.left{1}.Q; 
NumComponents = 3;
[Egvecs]=pca_egvecs(InputMatrix,NumComponents);

InputMatrix=[]
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
for i_left = 1:numel(mat.left)
    Q_left(:,:,i_left) = mat.left{i_left}.Q(1:99,:);
    figure(figinx);
    p1=plot3(Q_left(:,1,i_left), Q_left(:,2,i_left), Q_left(:,3,i_left), '-','color',[0 0 1],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
end
grid on;

for i_right = 1:numel(mat.right)
    Q_right(:,:,i_right) = mat.right{i_right}.Q;
    figure(figinx);
    p1=plot3(Q_right(:,1,i_right), Q_right(:,2,i_right), Q_right(:,3,i_right), '-','color',[1 0 0],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
end
grid on;

% plot the average
all_right = mean(Q_right,3);
figure(figinx);
p1=plot3(all_right(:,1), all_right(:,2), all_right(:,3), '-','color',[1 0 0],'LineWidth',3);
p1.Color(4) = 1;
mean(Q_right,3)

all_left = mean(Q_left,3);
figure(figinx);
p1=plot3(all_left(:,1), all_left(:,2), all_left(:,3), '-','color',[0 0 1],'LineWidth',3);
p1.Color(4) = 1;




