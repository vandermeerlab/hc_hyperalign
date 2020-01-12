function [sim_data] = sim_HT(cfg_in)
    % Last 2.4 second, dt = 50ms, or last 41 bins (after all choice points) for TC
    cfg_def.w_len = 48;
    % Number of neurons; set to different random number for each session if not specified.
    cfg_def.n_units = 30;
    cfg_def.sample_real_data = 0;
    % Number of iterations
    cfg_def.n_iters = 100;

    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    % Use M from real data
    cfg_data = [];
    cfg_data.use_adr_data = 0;
    cfg_data.removeInterneurons = 1;
    [Q] = prepare_all_Q(cfg_data);
    data = Q;

    % PCA
    NumComponents = 10;
    for rd_i = 1:length(data)
        proj_data{rd_i} = perform_pca(data{rd_i}, NumComponents);
    end

    for d_i = 1:cfg.n_iters
        for s_i = 1:length(data)
            if length(cfg.n_units) == 1
                n_units = cfg.n_units;
            else
                n_units = cfg.n_units(s_i);
            end
            sim_data{d_i}{s_i}.left = zeros(n_units, cfg.w_len);
            sim_data{d_i}{s_i}.right = zeros(n_units, cfg.w_len);
            p_has_field = 0.5;
            for n_i = 1:n_units
                if rand() < p_has_field
                    mu = rand() * cfg.w_len;
                    peak = rand() * 0.5 + 0.5;
                    sig = rand() * 5 + 2;
                    sim_data{d_i}{s_i}.left(n_i, :) = gaussian_1d(cfg.w_len, peak, mu, sig);
                end
            end
        end
    end

    %% Hyperalign real data and simulated data pair version
    for d_i = 1:cfg.n_iters
        % Randomly pick one real session as transformation from real data
        real_idx = datasample(1:length(data), 1);
        for s_i = 1:length(data)
            NumComponents = 10;
            [sim_proj_data{s_i}, sim_eigvecs{s_i}, sim_pca_mean{s_i}] = perform_pca(sim_data{d_i}{s_i}, NumComponents);

            hyper_input = {proj_data{real_idx}, sim_proj_data{s_i}};
            [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);

            [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
            predicted_aligned = p_transform(M, aligned_left{2});
            project_back_pca = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);
            project_back_data = sim_eigvecs{s_i} * project_back_pca + sim_pca_mean{s_i};

            sim_data{d_i}{s_i}.right = project_back_data(:, cfg.w_len+1:end);
        end
    end

end
