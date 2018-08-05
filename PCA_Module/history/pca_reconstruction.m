
function [reconstruct_score ] = pca_reconstruction(InputMatrix,PCA_decision,NumComponents)

% InputMatrix is a cell struct.
% InputMatrix{itrial}.data is the Q matrix: N(neurons) by T(time) data


Ntrial = size(InputMatrix,2);
NumComponents = 30;
    
if PCA_decision == 1 % do the PCA only based on the first trial.
    
    % do the first trial seperately
%     [coeff,reconstruct_score{1},latent,tsquared,explained,mu1] = pca(InputMatrix{1}.data','NumComponents',NumComponents);
    [Egvecs] = pca_egvecs(InputMatrix{1}.data,NumComponents);
     TransformM = EgVecs(:,1:3); % use the first 3 factor as the transformation matrix

    for itr = 1:Ntrial
        reconstruct_score{itr} = pca_project(InputMatrix{itr}.data,TransformM);
    end
    
else
    
    %concatenate all trials together to get a single big matrix for PCA analysis     
    allQ = [];
    for itr = 1:Ntrial
        allQ = [allQ;InputMatrix{itr}.data'];
    end
        
     % do the pca based on the data from all trials
    [Egvecs] = pca_egvecs(allQ,NumComponents);
    TransformM = EgVecs(:,1:3); % use the first 3 factor as the transformation matrix
    
    for itr = 1:Ntrial
        reconstruct_score{itr} = pca_project(InputMatrix{itr}.data,TransformM);
    end
    
end

end






