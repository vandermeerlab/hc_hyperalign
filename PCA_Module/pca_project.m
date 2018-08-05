



function [OuputMatrix] = pca_project(InputMatrix,TranformMatrix)

% InputMatrix is matrix N(neurons) by T(time) data

OuputMatrix = InputMatrix'*TranformMatrix;

    
end

