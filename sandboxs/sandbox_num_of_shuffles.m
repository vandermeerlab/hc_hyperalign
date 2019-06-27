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
    p_vals = zeros(1, 30);
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
        zscore_mat = zeros(length(data));
        for i = 1:length(data)
            for j = 1:length(data)
                sf_dists = squeeze(sf_dists_mat(i, j, :))';
                zs = zscore([sf_dists, actual_dists_mat(i, j)]);
                zscore_mat(i, j) = zs(end);
            end
        end
        out_zscore_mat = set_withsubj_nan(cfg, zscore_mat);
        signrank_p = signrank(out_zscore_mat(:));
        p_vals(p_i) = signrank_p;
    end
    mean_p_vals(s_i) = mean(p_vals);
    std_p_vals(s_i) = std(p_vals);
end
