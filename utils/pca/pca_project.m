function [OuputMatrix] = pca_project(InputMatrix, Egvecs)
    % InputMatrix is matrix N(neurons) by T(time) data
    OuputMatrix = Egvecs' * InputMatrix;
end
