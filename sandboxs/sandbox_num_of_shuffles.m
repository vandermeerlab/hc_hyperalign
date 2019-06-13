%% Get Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
cfg_data.removeInterneurons = 1;
[Q] = prepare_all_Q(cfg_data);

%% Main Procedure
data = Q;
cfg_pre = [];
cfg_pre.hyperalign_all = false;
cfg_pre.predict_target = 'Q';
cfg_pre.normalization = 'none';
cfg_pre.dist_dim = 'all';
[actual_dists_mat, id_dists_mat, predicted_Q_mat] = predict_with_L_R(cfg_pre, data);

num_shuffles = 100:100:1000;

mean_p_vals = zeros(1, length(num_shuffles));
std_p_vals = zeros(1, length(num_shuffles));

for s_i = 1:length(num_shuffles)
    p_vals = zeros(1, 10);
    for p_i = 1:length(p_vals)
        % Shuffling operations
        n_shuffles = num_shuffles(s_i);
        sf_dists_mat  = zeros(length(data), length(data), n_shuffles);

        for i = 1:n_shuffles
            cfg_pre.shuffled = 1;
            [s_actual_dists_mat] = predict_with_L_R(cfg_pre, data);
            sf_dists_mat(:, :, i) = s_actual_dists_mat;
        end
        cfg.use_adr_data = 0;
        % Matrix of differences between actual distance (identity distance) and mean of shuffled distance.
        actual_mean_sf = actual_dists_mat - mean(sf_dists_mat, 3);
        out_actual_mean_sf = set_withsubj_nan(cfg, actual_mean_sf);
        % Binomial stats
        bino_p_mean = calculate_bino_p(sum(sum(out_actual_mean_sf < 0)), sum(sum(~isnan(out_actual_mean_sf))), 0.5);
        p_vals(p_i) = bino_p_mean;
    end
    mean_p_vals(s_i) = mean(p_vals);
    std_p_vals(s_i) = std(p_vals);
end
