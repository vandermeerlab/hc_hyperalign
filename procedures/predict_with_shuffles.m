function [actual_dists_mat, id_dists_mat, sf_dists_mat] = predict_with_shuffles(cfg_in, data, func)
    cfg_def = [];
    cfg_def.hyperalign_all = false;
    cfg_def.predict_target = 'Q';
    cfg_def.normalization = 'none';
    cfg_def.dist_dim = 'all';
    cfg_def.n_shuffles = 1000;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    % Main Procedure
    [actual_dists_mat, id_dists_mat] = func(cfg, data);

    % Shuffling operations
    sf_dists_mat  = zeros(length(data), length(data), cfg.n_shuffles);

    for i = 1:cfg.n_shuffles
        cfg.shuffled = 1;
        [s_actual_dists_mat] = func(cfg, data);
        sf_dists_mat(:, :, i) = s_actual_dists_mat;
    end
end
