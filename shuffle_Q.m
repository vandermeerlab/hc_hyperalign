% Common binning and windowing configurations.
cfg = [];
cfg.dt = 0.05;
cfg.smooth = 'gauss';
cfg.gausswin_size = 1;
cfg.gausswin_sd = 0.02;

% Get processed data
Q_42 = get_processed_Q(cfg, '/R042-2013-08-18/');
Q_44 = get_processed_Q(cfg, '/R044-2013-12-21/');
Q_64 = get_processed_Q(cfg, '/R064-2015-04-20/');

% Shuffle PCA projected Q matrix
rand_dists_42_44 = [];
rand_dists_42_64 = [];
rand_dists_44_64 = [];

for i = 1:100
    shuffle_Q_42.left = Q_42.left;
    shuffle_indices = randperm(size(Q_42.right{1}.data, 1));
    for j = 1:length(Q_42.right)
        shuffle_Q_42.right{j}.data = Q_42.right{j}.data(shuffle_indices, :);
    end

    % PCA
    NumComponents = 10;
    shuffle_proj_Q_42 = perform_pca(shuffle_Q_42, NumComponents);
    proj_Q_44 = perform_pca(Q_44, NumComponents);
    proj_Q_64 = perform_pca(Q_64, NumComponents);

    % Average across all left (and right) trials
    shuffle_mean_proj_Q.left{1} = mean(cat(3, shuffle_proj_Q_42.left{:}), 3);
    shuffle_mean_proj_Q.left{2} = mean(cat(3, proj_Q_44.left{:}), 3);
    shuffle_mean_proj_Q.left{3} = mean(cat(3, proj_Q_64.left{:}), 3);

    shuffle_mean_proj_Q.right{1} = mean(cat(3, shuffle_proj_Q_42.right{:}), 3);
    shuffle_mean_proj_Q.right{2} = mean(cat(3, proj_Q_44.right{:}), 3);
    shuffle_mean_proj_Q.right{3} = mean(cat(3, proj_Q_64.right{:}), 3);

    % Hyperalignment
    [shuffle_aligned_left, shuffle_aligned_right] = hyperalignment(shuffle_mean_proj_Q.left, shuffle_mean_proj_Q.right);

    % Calculate distance for 3 pairs of subjects
    rand_dists_42_44 = [rand_dists_42_44, calculate_dist(shuffle_aligned_right{1}, shuffle_aligned_right{2})];
    rand_dists_42_64 = [rand_dists_42_64, calculate_dist(shuffle_aligned_right{1}, shuffle_aligned_right{3})];
    rand_dists_44_64 = [rand_dists_44_64, calculate_dist(shuffle_aligned_right{2}, shuffle_aligned_right{3})];
end
