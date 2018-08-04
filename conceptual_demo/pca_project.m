
function [reconstruct_score] = pca_project(InputMatrix,coeff)

% InputMatrix is a cell struct.
% InputMatrix{itrial}.data is the Q matrix: N(neurons) by T(time) data

Ntrial = size(InputMatrix,2);

     for itr = 1:Ntrial
        % rawQ = score1*coeff' + repmat(mu1, size(score1,1),1);
        rawQ = InputMatrix{itr}.data';
        reconstruct_score{itr} = [rawQ - repmat(mean(rawQ), size(rawQ,1),1)]/coeff';
     end  
    
end

