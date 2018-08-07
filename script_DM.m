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
    InputMatrix1=[InputMatrix Sample.HC_MEC.Correct(i).Coh_Smooth];
    InputMatrix1=[InputMatrix Sample.HC_MEC.Incorrect(i).Coh_Smooth];
    
    InputMatrix1=[InputMatrix Choice.HC_MEC.Correct(i).Coh_Smooth];
    InputMatrix1=[InputMatrix Choice.HC_MEC.Incorrect(i).Coh_Smooth];

end
for i = 1:12;
    InputMatrix2=[InputMatrix Sample.HC_Re.Correct(i).Coh_Smooth];
    InputMatrix2=[InputMatrix Sample.HC_Re.Incorrect(i).Coh_Smooth];
    
    InputMatrix2=[InputMatrix Choice.HC_Re.Correct(i).Coh_Smooth];
    InputMatrix2=[InputMatrix Choice.HC_Re.Incorrect(i).Coh_Smooth];

end
for i = 1:12;
    InputMatrix3=[InputMatrix Sample.MEC_Re.Correct(i).Coh_Smooth];
    InputMatrix3=[InputMatrix Sample.MEC_Re.Incorrect(i).Coh_Smooth];
    
    InputMatrix3=[InputMatrix Choice.MEC_Re.Correct(i).Coh_Smooth];
    InputMatrix3=[InputMatrix Choice.MEC_Re.Incorrect(i).Coh_Smooth];
end
% InputMatrix = SmoothQ.left{1}.Q; 
NumComponents = 3;
[Egvecs1]=pca_egvecs(InputMatrix1,NumComponents);
[Egvecs2]=pca_egvecs(InputMatrix2,NumComponents);
[Egvecs3]=pca_egvecs(InputMatrix3,NumComponents);

InputMatrix=[]
%  project all other trials (both left and right trials) to the same dimension
for i = 1:12
    InputMatrix = Sample.HC_MEC.Correct(i).Coh;
    Sample.HC_MEC.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs1);
    
    InputMatrix = Sample.HC_MEC.Incorrect(i).Coh;
    Sample.HC_MEC.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs1);
    
    InputMatrix = Sample.HC_Re.Correct(i).Coh;
    Sample.HC_Re.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs2);
    
    InputMatrix = Sample.HC_Re.Incorrect(i).Coh;
    Sample.HC_Re.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs2);
    
    InputMatrix = Sample.MEC_Re.Correct(i).Coh;
    Sample.MEC_Re.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs3);
    
    InputMatrix = Sample.MEC_Re.Incorrect(i).Coh;
    Sample.MEC_Re.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs3);
    %
    InputMatrix = Choice.HC_MEC.Correct(i).Coh;
    Choice.HC_MEC.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs1);
    
    InputMatrix = Choice.HC_MEC.Incorrect(i).Coh;
    Choice.HC_MEC.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs1);
    
    InputMatrix = Choice.HC_Re.Correct(i).Coh;
    Choice.HC_Re.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs2);
    
    InputMatrix = Choice.HC_Re.Incorrect(i).Coh;
    Choice.HC_Re.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs2);
    
    InputMatrix = Choice.MEC_Re.Correct(i).Coh;
    Choice.MEC_Re.Correct(i).Coh_Recon = pca_project(InputMatrix,Egvecs3);
    
    InputMatrix = Choice.MEC_Re.Incorrect(i).Coh;
    Choice.MEC_Re.Incorrect(i).Coh_Recon = pca_project(InputMatrix,Egvecs3);
    
end

%% Plot the data 

figinx = 101;

colors = linspecer(2);

% need to fix the trial level 
for i = 1:12
    HC_MEC.Q_Sample(:,:,i) = Sample.HC_MEC.Correct(i).Coh_Recon;
    figure(figinx);
    p1=plot3(HC_MEC.Q_Sample(:,1,i), HC_MEC.Q_Sample(:,2,i), HC_MEC.Q_Sample(:,3,i), '-','color',[0 0 1],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    HC_MEC.Q_Choice(:,:,i) = Choice.HC_MEC.Correct(i).Coh_Recon;
    figure(figinx);
    p1=plot3(HC_MEC.Q_Choice(:,1,i), HC_MEC.Q_Choice(:,2,i), HC_MEC.Q_Choice(:,3,i), '-','color',[1 0 0],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    HC_MEC.Q_Sample_Inc(:,:,i) = Sample.HC_MEC.Incorrect(i).Coh_Recon;
    figure(figinx);
    p1=plot3(HC_MEC.Q_Sample_Inc(:,1,i), HC_MEC.Q_Sample_Inc(:,2,i), HC_MEC.Q_Sample_Inc(:,3,i), '-','color',[0 0 1],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    HC_MEC.Q_Choice_Inc(:,:,i) = Choice.HC_MEC.Incorrect(i).Coh_Recon;
    figure(figinx);
    p1=plot3(HC_MEC.Q_Choice_Inc(:,1,i), HC_MEC.Q_Choice_Inc(:,2,i), HC_MEC.Q_Choice_Inc(:,3,i), '-','color',[1 0 0],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    %
    HC_RE.Q_Sample(:,:,i) = Sample.HC_Re.Correct(i).Coh_Recon;
    figure(figinx);
    p1=plot3(HC_RE.Q_Sample(:,1,i), HC_RE.Q_Sample(:,2,i), HC_RE.Q_Sample(:,3,i), '-','color',[0 0 1],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    HC_RE.Q_Choice(:,:,i) = Choice.HC_Re.Correct(i).Coh_Recon;
    figure(figinx);
    p1=plot3(HC_RE.Q_Choice(:,1,i), HC_RE.Q_Choice(:,2,i), HC_RE.Q_Choice(:,3,i), '-','color',[1 0 0],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    HC_RE.Q_Sample_Inc(:,:,i) = Sample.HC_Re.Incorrect(i).Coh_Recon;
    figure(figinx);
    p1=plot3(HC_RE.Q_Sample_Inc(:,1,i), HC_RE.Q_Sample_Inc(:,2,i), HC_RE.Q_Sample_Inc(:,3,i), '-','color',[0 0 1],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    HC_RE.Q_Choice_Inc(:,:,i) = Choice.HC_Re.Incorrect(i).Coh_Recon;
    figure(figinx);
    p1=plot3(HC_RE.Q_Choice_Inc(:,1,i), HC_RE.Q_Choice_Inc(:,2,i), HC_RE.Q_Choice_Inc(:,3,i), '-','color',[1 0 0],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    %
    MEC_RE.Q_Sample(:,:,i) = Sample.MEC_Re.Correct(i).Coh_Recon;
    figure(figinx);
    p1=plot3(MEC_RE.Q_Sample(:,1,i), MEC_RE.Q_Sample(:,2,i), MEC_RE.Q_Sample(:,3,i), '-','color',[0 0 1],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    MEC_RE.Q_Choice(:,:,i) = Choice.MEC_Re.Correct(i).Coh_Recon;
    figure(figinx);
    p1=plot3(MEC_RE.Q_Choice(:,1,i), MEC_RE.Q_Choice(:,2,i), MEC_RE.Q_Choice(:,3,i), '-','color',[1 0 0],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    MEC_RE.Q_Sample_Inc(:,:,i) = Sample.MEC_Re.Incorrect(i).Coh_Recon;
    figure(figinx);
    p1=plot3(MEC_RE.Q_Sample_Inc(:,1,i), MEC_RE.Q_Sample_Inc(:,2,i), MEC_RE.Q_Sample_Inc(:,3,i), '-','color',[0 0 1],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
    MEC_RE.Q_Choice_Inc(:,:,i) = Choice.MEC_Re.Incorrect(i).Coh_Recon;
    figure(figinx);
    p1=plot3(MEC_RE.Q_Choice_Inc(:,1,i), MEC_RE.Q_Choice_Inc(:,2,i), MEC_RE.Q_Choice_Inc(:,3,i), '-','color',[1 0 0],'LineWidth',3);
    p1.Color(4) = 0.1;
    hold on;
end
grid on;

% plot the average
HC_MEC.Choice.c = mean(HC_MEC.Q_Choice,3);
HC_MEC.Sample.c = mean(HC_MEC.Q_Sample,3);
HC_MEC.Choice.i = mean(HC_MEC.Q_Choice_Inc,3);
HC_MEC.Sample.i = mean(HC_MEC.Q_Sample_Inc,3);

HC_RE.Choice.c = mean(HC_RE.Q_Choice,3);
HC_RE.Sample.c = mean(HC_RE.Q_Sample,3);
HC_RE.Choice.i = mean(HC_RE.Q_Choice_Inc,3);
HC_RE.Sample.i = mean(HC_RE.Q_Sample_Inc,3);

MEC_RE.Choice.c = mean(MEC_RE.Q_Choice,3);
MEC_RE.Sample.c = mean(MEC_RE.Q_Sample,3);
MEC_RE.Choice.i = mean(MEC_RE.Q_Choice_Inc,3);
MEC_RE.Sample.i = mean(MEC_RE.Q_Sample_Inc,3);

%%
figure(figinx);hold on;grid on;
p1=plot3(HC_MEC_Choice(:,1), HC_MEC_Choice(:,2), HC_MEC_Choice(:,3), '-','color',[1 0 0],'LineWidth',3);
p1.Color(4) = 1;