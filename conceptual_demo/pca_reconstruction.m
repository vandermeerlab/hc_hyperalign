
function [reconstruct_score coeff] = pca_reconstruction(InputMatrix,PCA_decision,NumComponents)

% InputMatrix is a cell struct.
% InputMatrix{itrial}.data is the Q matrix: N(neurons) by T(time) data

% PCA_decision = 2

Ntrial = size(InputMatrix,2);

if NumComponents == 0 
    NumComponents = size(InputMatrix{1}.data,1);
end
    
if PCA_decision == 1 % do the PCA only based on the first trial.
    
    % do the first trial seperately
    [coeff,reconstruct_score{1},latent,tsquared,explained,mu1] = pca(InputMatrix{1}.data','NumComponents',NumComponents);
    
    for itr = 2:Ntrial
        % rawQ = score1*coeff' + repmat(mu1, size(score1,1),1);
        rawQ = InputMatrix{itr}.data';
        reconstruct_score{itr} = [rawQ - repmat(mean(rawQ), size(rawQ,1),1)]/coeff';
    end
    
else
    
    %concatenate all trials together to get a single big matrix for PCA analysis     
    allQ = [];
    for itr = 1:Ntrial
        allQ = [allQ;InputMatrix{itr}.data'];
    end
        
     % do the pca based on the data from all trials
    [coeff,score,latent,tsquared,explained,mu1] = pca(allQ,'NumComponents',NumComponents);
       
     for itr = 1:Ntrial
        % rawQ = score1*coeff' + repmat(mu1, size(score1,1),1);
        rawQ = InputMatrix{itr}.data';
        reconstruct_score{itr} = [rawQ - repmat(mean(rawQ), size(rawQ,1),1)]/coeff';
    end  
end

end






