function [giant_sim_data, sim_corr_right] = sim_HT(cfg_in)
    % Last 2.4 second, dt = 50ms, or last 41 bins (after all choice points) for TC
    cfg_def.w_len = 48;
    % Number of neurons; set to different random number for each session if not specified.
    cfg_def.n_units = [];
    cfg_def.sample_real_data = 0;

    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    % Use M from real data
    cfg_data = [];
    cfg_data.use_adr_data = 0;
    cfg_data.removeInterneurons = 1;
    [Q] = prepare_all_Q(cfg_data);
    data = Q;

    if cfg.sample_real_data
        % cfg_data = [];
        % cfg_data.use_adr_data = 1;
        % cfg_data.removeInterneurons = 0;
        % [adr_Q] = prepare_all_Q(cfg_data);
        all_left = cellfun(@(x) x.left, [Q], 'UniformOutput', false);
        all_left = cell2mat(all_left');

        all_right = cellfun(@(x) x.right, [Q], 'UniformOutput', false);
        all_right = cell2mat(all_right');
    end

    % PCA
    NumComponents = 10;
    for rd_i = 1:length(data)
        proj_data{rd_i} = perform_pca(data{rd_i}, NumComponents);
    end

    rng(mean('mvdmlab'));
    sim_data = cell(size(data));
    % Make two Qs - first: source, second: target
    for s_i = 1:length(sim_data)
        if ~isempty(cfg.n_units)
            n_units = cfg.n_units;
        else
            n_units = randi([60, 120]);
            % Make the number of neurons as same in real data.
            % n_units = size(data{s_i}.left, 1);
        end
        if cfg.sample_real_data
            [sim_data{s_i}.left, sim_indices{s_i}] = datasample(all_left, n_units, 'Replace', false);
            sim_corr_right{s_i} = all_right(sim_indices{s_i}, :);
            sim_data{s_i}.right = zeros(n_units, cfg.w_len);
        else
            sim_data{s_i}.left = zeros(n_units, cfg.w_len);
            sim_data{s_i}.right = zeros(n_units, cfg.w_len);
            p_has_field = 0.5;
            for n_i = 1:n_units
                if rand() < p_has_field
                    mu = rand() * cfg.w_len;
                    peak = rand() * 0.5 + 0.5;
                    sig = rand() * 5 + 2;
                    sim_data{s_i}.left(n_i, :) = gaussian_1d(cfg.w_len, peak, mu, sig);
                end
            end
        end
    end

    NumComponents = 10;
    % Project [L, R] to PCA space.
    for sim_i = 1:length(sim_data)
        [sim_proj_data{sim_i}, sim_eigvecs{sim_i}, sim_pca_mean{sim_i}] = perform_pca(sim_data{sim_i}, NumComponents);
    end

    giant_sim_data = cell(size(data));
    for s_i = 1:length(data)
        giant_sim_data{s_i} = sim_data;
    end

    %% Hyperalign real data and simulated data pair version
    for d_i = 1:length(data)
        for s_i = 1:length(sim_data)
        hyper_input = {proj_data{d_i}, sim_proj_data{s_i}};
        [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);

        [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
        predicted_aligned = p_transform(M, aligned_left{2});
        project_back_pca = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);
        project_back_data = sim_eigvecs{s_i} * project_back_pca + sim_pca_mean{s_i};

        giant_sim_data{d_i}{s_i}.right = project_back_data(:, cfg.w_len+1:end);
        end
    end

end
