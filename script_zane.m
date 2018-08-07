% Decription of purpose
% Users/Owners
% Date of modification

clear all 
close all

% Add Path
hc_hyperalign_path = '/Users/weizhenxie/Documents/Jupyter/mind2018/hc_hyperalign';
addpath([hc_hyperalign_path '/hc_hyperalign/SpecFun'])


% load data
datatoload = '/R042-2013-08-18/';
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
NumComponents = 3;
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
mean(Q_right,3)
xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')

all_left = mean(Q_left,3);
figure(figinx);
p1=plot3(all_left(:,1), all_left(:,2), all_left(:,3), '-','color',[0 0 1],'LineWidth',3);
p1.Color(4) = 1;
xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')
title([datatoload ' : Blue - Left, Red - Right'])





%% Do the hyperalignment

% the input of to-be-aligned matrixes should have the same dimension. 


Mats{1}=all_left;
Mats{2}=all_right;
Mats{3}=all_left;
Mats{4}=all_right;
Mats{5}=all_left;

varargin =Mats;


%step 1: compute common template
for s = 1:length(varargin)        
    if s == 1
        template = varargin{s};
    else
        [~, next] = procrustes((template./(s - 1))', varargin{s}');
        template = template + next';
    end
end
template = template./length(varargin);

%step 2: align each pattern to the common template template and compute a
%new common template
template2 = zeros(size(template));
for s = 1:length(varargin)
    [~, next] = procrustes(template', varargin{s}');
    template2 = template2 + next';
end
template2 = template2./length(varargin);

%step 3: align each subject to the mean alignment from the previous round.
%save the transformation parameters
[aligned, transforms] = deal(cell(size(varargin)));
for s = 1:length(varargin)
    [~, next, transforms{s}] = procrustes(template2', varargin{s}');
    aligned{s} = next';
end