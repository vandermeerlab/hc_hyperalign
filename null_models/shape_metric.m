%%
rng(mean('hyperalignment'));

%%
data = TC_norm_Z;

% Project [L, R] to PCA space.
cfg.NumComponents = 10;
for p_i = 1:length(data)
    pca_input = data{p_i};
    [proj_data{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(pca_input, cfg.NumComponents);
end

%% Calculate procrustes distances between all pairs of matrices (19 sessions * 2 condtions = 38 matrices in total)
dists_mat  = zeros(length(data) * 2);
conditions = {'left', 'right'};

for sr_i = 1:length(data)
    for sr_cdt_i = 1:2
        sr_cdt = conditions{sr_cdt_i};
        for tar_i = 1:length(data)
            for tar_cdt_i = 1:2
                tar_cdt = conditions{tar_cdt_i};
                
                if ~(sr_i == tar_i && sr_cdt_i  == tar_cdt_i)
                    X = proj_data{sr_i}.(sr_cdt)';
                    Y = proj_data{tar_i}.(tar_cdt)';
                    [d, Z, transform] = procrustes(X, Y, 'scaling', false);
                    
                    Fro_error = sum((X - Z).^2, 'all');
                    % Normalize by the average of Frobenius norms of X and Y
                    % norm_factor = (sum(X.^2, 'all') + sum(Y.^2, 'all')) / 2;
                    norm_factor = sqrt(sum(X.^2, 'all')) * sqrt(sum(Y.^2, 'all'));
                    dists_mat((sr_i-1)*2+sr_cdt_i, (tar_i-1)*2+tar_cdt_i) = Fro_error / norm_factor;
                end
            end
        end
    end
end

%% Plot
imagesc(dists_mat); colorbar;

%% Compare norms (Frobenius and geodesic distance) of rotation matrices.
sr_i = 1;
tar_i = 10;

Xs = {proj_data{sr_i}.left, proj_data{sr_i}.right, proj_data{tar_i}.left, proj_data{tar_i}.right};

rotation_mat_cells = cell(length(Xs));
Fro_dist_mat = zeros(length(Xs));
rotation_dist_mat = zeros(length(Xs));

for i = 1:length(Xs)
    for j = 1:length(Xs)
        X = Xs{j}';
        Y = Xs{i}';
        [d, Z, transform] = procrustes(X, Y, 'scaling', false, 'reflection',false);
        rotation_mat_cells{i, j} = transform.T;
        Fro_dist_mat(i, j) = sum((eye(cfg.NumComponents) - transform.T).^2, 'all');
        
        rotation_eigvs = eig(eye(cfg.NumComponents)' * transform.T);
        rotation_dist_mat(i, j) = sqrt(sum(angle(rotation_eigvs(1:2:end)).^ 2));
    end
end

%% Compare distance between pairs of rotation matrices.
diff_indices = {[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]};
diff_Fro_dist_mat = zeros(length(diff_indices));
diff_rotation_dist_mat = zeros(length(diff_indices));

for i = 1:length(diff_indices)
    rot_X = rotation_mat_cells{diff_indices{i}(1), diff_indices{i}(2)};
    for j = 1:length(diff_indices)
        rot_Y = rotation_mat_cells{diff_indices{j}(1), diff_indices{j}(2)};
        diff_Fro_dist_mat(i, j) = sum((rot_X - rot_Y).^2, 'all');
        
        diff_rotation_eigvs = eig(rot_X' * rot_Y);
        diff_rotation_dist_mat(i, j) = sqrt(sum(angle(diff_rotation_eigvs(1:2:end)).^ 2));

    end
end

%%

%% Plot of Frobenius norm
set(0,'defaultTextInterpreter','latex'); %trying to set the default

figure;
subplot(1, 2, 1);
imagesc(Fro_dist_mat); colorbar;
set(gca, 'XTick', 1:4, 'XTickLabel', {'X1', 'X2', 'X3', 'X4'}, ...
    'YTick', 1:4, 'YTickLabel', {'X1', 'X2', 'X3', 'X4'});
title('Frobenius norms of rotation matrices');

subplot(1, 2, 2);
imagesc(diff_Fro_dist_mat); colorbar;
set(gca, 'XTick', 1:6, 'XTickLabel', {'R_{12}', 'R_{13}', 'R_{14}', 'R_{23}', 'R_{24}', 'R_{34}'}, ...
    'YTick', 1:6, 'YTickLabel', {'R_{12}', 'R_{13}', 'R_{14}', 'R_{23}', 'R_{24}', 'R_{34}'});
title('Frobenius norms of difference between pairs');

%% Plot of geodesic distances
set(0,'defaultTextInterpreter','latex'); %trying to set the default

figure;
subplot(1, 2, 1);
imagesc(rotation_dist_mat); colorbar;
set(gca, 'XTick', 1:4, 'XTickLabel', {'X1', 'X2', 'X3', 'X4'}, ...
    'YTick', 1:4, 'YTickLabel', {'X1', 'X2', 'X3', 'X4'});
title('Geodesic distances of rotation matrices');

subplot(1, 2, 2);
imagesc(diff_rotation_dist_mat); colorbar;
set(gca, 'XTick', 1:6, 'XTickLabel', {'R_{12}', 'R_{13}', 'R_{14}', 'R_{23}', 'R_{24}', 'R_{34}'}, ...
    'YTick', 1:6, 'YTickLabel', {'R_{12}', 'R_{13}', 'R_{14}', 'R_{23}', 'R_{24}', 'R_{34}'});
title('Geodesic distances of difference between pairs');

%% Obtain the distances between rotation matices (from L to R) for all source-target pairs.
Fro_dist_diffs = zeros(length(data));
rotation_dist_diffs = zeros(length(data));

for sr_i = 1:length(data)
    for tar_i = 1:length(data)
        if sr_i ~= tar_i
            X1 = proj_data{sr_i}.left;
            Y1 = proj_data{sr_i}.right;
            X2 = proj_data{tar_i}.left;
            Y2 = proj_data{tar_i}.right;
            [~, ~, transform_sr] = procrustes(Y1', X1', 'scaling', false, 'reflection',false);
            [~, ~, transform_tar] = procrustes(Y2', X2', 'scaling', false, 'reflection',false);
            
            rot_X = transform_sr.T;
            rot_Y = transform_tar.T;
            Fro_dist_diffs(sr_i, tar_i) = sum((rot_X - rot_Y).^2, 'all');
            
            diff_rotation_eigvs = eig(rot_X' * rot_Y);
            rotation_dist_diffs(sr_i, tar_i) = sqrt(sum(angle(diff_rotation_eigvs(1:2:end)).^ 2));
        else
            Fro_dist_diffs(sr_i, tar_i) = NaN;
            rotation_dist_diffs(sr_i, tar_i) = NaN;
        end
    end
end

%%
out_actual_dists = set_withsubj_nan([], actual_dists_mat{1});
out_Fro_dist_diffs = set_withsubj_nan([], Fro_dist_diffs);
out_rotation_dist_diffs = set_withsubj_nan([], rotation_dist_diffs);

%% Plot Frobenius norm / Geodesic distance with z-scores
figure;
y = z_score{1}.out_zscore_mat(~isnan(z_score{1}.out_zscore_mat));
% x = out_Fro_dist_diffs(~isnan(out_Fro_dist_diffs));
x = out_rotation_dist_diffs(~isnan(out_rotation_dist_diffs));

P = polyfit(x, y, 1);
yfit = polyval(P, x);

plot(x, y, '.');
% xlabel('Frobenius norm');
xlabel('Geodesic distance');
ylabel('cross-subject predictability (z-scores)');
hold on;

plot(x, yfit,'r-.');
[R, P] = corrcoef(x, y);
eqn = string(" Correlation: " + R(1, 2));
text(min(x), max(y), eqn, "HorizontalAlignment","left","VerticalAlignment","top")

%% Obtain the distances of rotation matrices (from target to source) for all source-target pairs.
Fro_dists = zeros(length(data));
rotation_dists = zeros(length(data));

for sr_i = 1:length(data)
    for tar_i = 1:length(data)
        if sr_i ~= tar_i
            X1 = proj_data{sr_i}.left;
            Y1 = proj_data{sr_i}.right;
            X2 = proj_data{tar_i}.left;
            Y2 = proj_data{tar_i}.right;
            [~, ~, transform] = procrustes([X1, Y1]', [X2, Y2]', 'scaling', false);
            
            Fro_dists(sr_i, tar_i) = sum((eye(cfg.NumComponents) - transform.T).^2, 'all');
            
            rotation_eigvs = eig(eye(cfg.NumComponents)' * transform.T);
            rotation_dists(sr_i, tar_i) = sqrt(sum(angle(rotation_eigvs(1:2:end)).^ 2));
        else
            Fro_dists(sr_i, tar_i) = NaN;
            rotation_dists(sr_i, tar_i) = NaN;
        end
    end
end

%%
out_actual_dists = set_withsubj_nan([], actual_dists_mat{1});
out_Fro_dists = set_withsubj_nan([], Fro_dists);
out_rotation_dists = set_withsubj_nan([], rotation_dists);