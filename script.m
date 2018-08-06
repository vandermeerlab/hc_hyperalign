% Decription of purpose
% Users/Owners
% Date of modification

% Add Path
hc_hyperalign_path = '/Users/weizhenxie/Documents/Jupyter/mind2018';

addpath([hc_hyperalign_path '/hc_hyperalign/SpecFun'])
addpath([hc_hyperalign_path '/hc_hyperalign/R042-2013-08-18'])

% load data
load('R042-2013-08-18-metadata.mat') % metadata
load('Spike.mat') % metadata


%% Regularize left and right trials
TSE_L(:, 1) = metadata.taskvars.trial_iv_L.tstart;
TSE_L(:, 2) = metadata.taskvars.trial_iv_L.tend;
TSE_R(:, 1) = metadata.taskvars.trial_iv_R.tstart;
TSE_R(:, 2) = metadata.taskvars.trial_iv_R.tend;

reg_trials = RegularizedTrials(TSE_L, TSE_R);

%% Produce the Q matrix (Neuron by Time)
Qmat = generateQmatrix(reg_trials, S, 0);



%% PCA 
% InputMatrix =[];
% for i = 1:size(Qmat.left,2)
%     InputMatrix=[InputMatrix Qmat.left{i}.Q];
% end

InputMatrix = Qmat.left{1}.Q; 
NumComponents = 3;
[Egvecs]=pca_egvecs(InputMatrix,NumComponents);

InputMatrix=[]
%  project all other trials (both left and right trials) to the same dimension
for i = 1:size(Qmat.left,2)
    InputMatrix = Qmat.left{i}.Q;
    Recon_Qmat.left{i}.Q = pca_project(InputMatrix,Egvecs);
end

for i = 1:size(Qmat.right,2)
    InputMatrix = Qmat.right{i}.Q;
    Recon_Qmat.right{i}.Q = pca_project(InputMatrix,Egvecs);
end



%% Plot the data 

mat = Recon_Qmat;
figinx = 101;

colors = linspecer(2);
for i_left = 1:numel(mat.left)
    Q_left = mat.left{i_left}.Q;
    figure(figinx);plot3(Q_left(:,1), Q_left(:,2), Q_left(:,3), '.-','color', colors(1,:));
    hold on;
end
for i_right = 1:numel(mat.right)
    Q_right = mat.right{i_right}.Q;
    figure(figinx);plot3(Q_right(:,1), Q_right(:,2), Q_right(:,3), '.-','color', colors(2,:));
    hold on;
end
grid on;



