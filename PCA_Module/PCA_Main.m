
%% 

% minlen = min(get_length(Qhpc_left));
% 
% for iq= 1:size(Qhpc_left,2)
%     NQleft{iq}.data =Qhpc_left{iq}.data(:,end-minlen+1:end);
% end
% 
% minlen=min(get_length(Qhpc_right));
% for iq= 1:size(Qhpc_right,2)
%     NQright{iq}.data =Qhpc_right{iq}.data(:,end-minlen+1:end);
% end


%% Plot the data for the left trials. 
load('JS15allQmat.mat')


    InputMatrix = Qhpc_left;
    [Egvecs] = pca_egvecs(InputMatrix{1}.data,size(InputMatrix{1}.data,1));
    TransformM = Egvecs(:,1:3); % use the first 3 factor as the transformation matrix
    Ntrial = size(InputMatrix,2);    
    for itr = 1:Ntrial
        reconstruct_score{itr} = pca_project(InputMatrix{itr}.data,TransformM);
    end
    
    


figIn=3;
% for the left trials
for itr = 1:size(reconstruct_score,2)

     scoreR = reconstruct_score{itr};   
     curclr = rand(1,3);
     figure(figIn);subplot(1,3,1);    
     h=plot3(scoreR(:,1),scoreR(:,2),scoreR(:,3),'.-','color',curclr);
     h.Color(4) = 0.01;
     hold on; 
     axis on;
     grid on;title('left trials only')
     axis([-2 2 -2 2 -2 2]);

     
     figure(figIn);subplot(1,3,3);    
     h=plot3(scoreR(:,1),scoreR(:,2),scoreR(:,3),'r.-');
     h.Color(4) = 0.01;
     hold on; 
     axis on;
     grid on; title('left-red, right-blue')
     axis([-2 2 -2 2 -2 2]);

end

    InputMatrix = Qhpc_right;
    [Egvecs] = pca_egvecs(InputMatrix{1}.data,size(InputMatrix{1}.data,1));
    TransformM = Egvecs(:,1:3); % use the first 3 factor as the transformation matrix
    Ntrial = size(InputMatrix,2);    
    for itr = 1:Ntrial
        reconstruct_score{itr} = pca_project(InputMatrix{itr}.data,TransformM);
    end
    
% for the right trials
for itr = 1:size(reconstruct_score,2)

     scoreR = reconstruct_score{itr};   
     curclr = rand(1,3);
     figure(figIn);subplot(1,3,2);    
     h=plot3(scoreR(:,1),scoreR(:,2),scoreR(:,3),'.-','color',curclr);
     h.Color(4) = 0.01;
     hold on; 
     axis on;
     grid on;title('right trials only')
     axis([-2 2 -2 2 -2 2]);

     
     figure(figIn);subplot(1,3,3);    
     h=plot3(scoreR(:,1),scoreR(:,2),scoreR(:,3),'b.-');
     h.Color(4) = 0.01;
     hold on; 
     axis on;
     grid on; title('left-red, right-blue') 
     axis([-2 2 -2 2 -2 2]);

end