
function [Egvecs]=pca_egvecs(InputMatrix,NumComponents)

% InputMatrix is matrix N(neurons) by T(time) data
% output is the Egvecs

[Egvecs] = pca(InputMatrix','NumComponents',NumComponents);
    
end