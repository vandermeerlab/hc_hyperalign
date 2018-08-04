
% PCA analysis

M1 = Q1(:,1:10000);
M2 = Q1(:,10001:20000);



y1 = M1'*TransformM;
y2 = M2'*TransformM;


% Get egvectors
[Egvecs] = pca_egvecs(M1,10);
TransformM = EgVecs(:,1:3); % use the first 3 factor as the transformation matrix

% project data to the same space using the transformation matrix
[output] = pca_project(M1,TransformM);

y1 = M1'*TransformM;
y2 = M2'*TransformM;
