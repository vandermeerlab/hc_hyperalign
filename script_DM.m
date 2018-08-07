%%

% smooth the data 
for itr = 1:12 %trials number
      Sample.HC_MEC.Correct(itr).Coh_Smooth = zscore(smoothdata(Sample.HC_MEC.Correct(itr).Coh,'gaussian',20));
      Sample.HC_MEC.Incorrect(itr).Coh_Smooth = zscore(smoothdata(Sample.HC_MEC.Incorrect(itr).Coh,'gaussian',20));
      Sample.HC_Re.Correct(itr).Coh_Smooth = zscore(smoothdata(Sample.HC_Re.Correct(itr).Coh,'gaussian',20));
      Sample.HC_Re.Incorrect(itr).Coh_Smooth = zscore(smoothdata(Sample.HC_Re.Incorrect(itr).Coh,'gaussian',20));
      Sample.MEC_Re.Correct(itr).Coh_Smooth = zscore(smoothdata(Sample.MEC_Re.Correct(itr).Coh,'gaussian',20));
      Sample.MEC_Re.Incorrect(itr).Coh_Smooth = zscore(smoothdata(Sample.MEC_Re.Incorrect(itr).Coh,'gaussian',20));
      
      Choice.HC_MEC.Correct(itr).Coh_Smooth = zscore(smoothdata(Choice.HC_MEC.Correct(itr).Coh,'gaussian',20));
      Choice.HC_MEC.Incorrect(itr).Coh_Smooth = zscore(smoothdata(Choice.HC_MEC.Incorrect(itr).Coh,'gaussian',20));
      Choice.HC_Re.Correct(itr).Coh_Smooth = zscore(smoothdata(Choice.HC_Re.Correct(itr).Coh,'gaussian',20));
      Choice.HC_Re.Incorrect(itr).Coh_Smooth = zscore(smoothdata(Choice.HC_Re.Incorrect(itr).Coh,'gaussian',20));
      Choice.MEC_Re.Correct(itr).Coh_Smooth = zscore(smoothdata(Choice.MEC_Re.Correct(itr).Coh,'gaussian',20));
      Choice.MEC_Re.Incorrect(itr).Coh_Smooth = zscore(smoothdata(Choice.MEC_Re.Incorrect(itr).Coh,'gaussian',20));
end

%% PCA 
InputMatrix =[];
for i = 1:12
    InputMatrix=[InputMatrix Sample.HC_MEC.Correct(i).Coh];
    InputMatrix=[InputMatrix Sample.HC_MEC.Incorrect(i).Coh];
    InputMatrix=[InputMatrix Sample.HC_Re.Correct(i).Coh];
    InputMatrix=[InputMatrix Sample.HC_Re.Incorrect(i).Coh];
    InputMatrix=[InputMatrix Sample.MEC_Re.Correct(i).Coh];
    InputMatrix=[InputMatrix Sample.MEC_Re.Incorrect(i).Coh];
    
    InputMatrix=[InputMatrix Choice.HC_MEC.Correct(i).Coh];
    InputMatrix=[InputMatrix Choice.HC_MEC.Incorrect(i).Coh];
    InputMatrix=[InputMatrix Choice.HC_Re.Correct(i).Coh];
    InputMatrix=[InputMatrix Choice.HC_Re.Incorrect(i).Coh];
    InputMatrix=[InputMatrix Choice.MEC_Re.Correct(i).Coh];
    InputMatrix=[InputMatrix Choice.MEC_Re.Incorrect(i).Coh];
end

% InputMatrix = SmoothQ.left{1}.Q; 
NumComponents = 3;
[Egvecs]=pca_egvecs(InputMatrix,NumComponents);

InputMatrix=[]
%  project all other trials (both left and right trials) to the same dimension
for i = 1:12
    InputMatrix = Sample.HC_MEC.Correct(i).Coh;
    Sample.HC_MEC.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Sample.HC_MEC.Incorrect(i).Coh;
    Sample.HC_MEC.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Sample.HC_Re.Correct(i).Coh;
    Sample.HC_Re.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Sample.HC_Re.Incorrect(i).Coh;
    Sample.HC_Re.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Sample.MEC_Re.Correct(i).Coh;
    Sample.MEC_Re.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Sample.MEC_Re.Incorrect(i).Coh;
    Sample.MEC_Re.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    %
    InputMatrix = Choice.HC_MEC.Correct(i).Coh;
    Choice.HC_MEC.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Choice.HC_MEC.Incorrect(i).Coh;
    Choice.HC_MEC.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Choice.HC_Re.Correct(i).Coh;
    Choice.HC_Re.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Choice.HC_Re.Incorrect(i).Coh;
    Choice.HC_Re.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Choice.MEC_Re.Correct(i).Coh;
    Choice.MEC_Re.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
    InputMatrix = Choice.MEC_Re.Incorrect(i).Coh;
    Choice.MEC_Re.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs);
    
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




