% Last 2.4 second, dt = 50ms for Q
w_len = 48;
% Or last 41 bins (after all choice points) for TC
% w_len = 41;
rng(mean('hyperalignment'));
sim_data = cell(1, 19);
% Make two Qs - first: source, second: target
for s_i = 1:length(sim_data)
    % Number of neurons
    n_units = randi([60, 120]);
    sim_data{s_i}.left = zeros(n_units, w_len);
    sim_data{s_i}.right = zeros(n_units, w_len);
    p_has_field = 0.5;
    for n_i = 1:n_units
        if rand() < p_has_field
            mu = rand() * w_len;
            peak = rand() * 0.5 + 0.5;
            sig = rand() * 5 + 2;
            sim_data{s_i}.left(n_i, :) = gaussian_1d(w_len, peak, mu, sig);
        end
    end
end

NumComponents = 10;
% Project [L, R] to PCA space.
for sim_i = 1:length(sim_data)
    [sim_proj_data{sim_i}, sim_eigvecs{sim_i}, sim_pca_mean{sim_i}] = perform_pca(sim_data{sim_i}, NumComponents);
end

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

%% Hyperalign source-target pair version
% predicted_data_mat = cell(length(sim_data));
predicted_data_mat = cell(length(sim_data), length(sim_data));
for sr_i = 1:length(sim_data)
    for tar_i = 1:length(sim_data)
        if sr_i ~= tar_i
            % Hyperalignment on real data to get M transformation
            hyper_input = {proj_data{sr_i}, proj_data{tar_i}};
            [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);

            % Perform hyperalignment on L of simulated data in PCA.
            sim_hyper_input = {sim_proj_data{sr_i}, sim_proj_data{tar_i}};
            [sim_aligned_left, sim_aligned_right, sim_transforms] = get_aligned_left_right(sim_hyper_input);

            [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);

            predicted_aligned = p_transform(M, sim_aligned_left{2});
            project_back_pca = inv_p_transform(sim_transforms{2}, [sim_aligned_left{2}, predicted_aligned]);
            project_back_data = sim_eigvecs{tar_i} * project_back_pca + sim_pca_mean{tar_i};
            predicted_data_mat{sr_i, tar_i} = project_back_data(:, w_len+1:end);
            % sim_data{tar_i}.right = sim_data{tar_i}.right + (1/19 * project_back_data(:, 49:end));
        end
    end
end

%% Hyperalign-all version
% Hyperalignment on real data to get M transformation
hyper_input = proj_data;
[aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);

% Perform hyperalignment on L of simulated data in PCA.
sim_hyper_input = sim_proj_data;
[sim_aligned_left, sim_aligned_right, sim_transforms] = get_aligned_left_right(sim_hyper_input);

predicted_data_mat = cell(length(sim_data));
for sr_i = 1:length(sim_data)
    [~, ~, M] = procrustes(aligned_right{sr_i}', aligned_left{sr_i}', 'scaling', false);
    for tar_i = 1:length(sim_data)
        if sr_i ~= tar_i
            predicted_aligned = p_transform(M, sim_aligned_left{tar_i});
            project_back_pca = inv_p_transform(sim_transforms{tar_i}, [sim_aligned_left{tar_i}, predicted_aligned]);
            project_back_data = sim_eigvecs{tar_i} * project_back_pca + sim_pca_mean{tar_i};
            predicted_data_mat{sr_i, tar_i} = project_back_data(:, w_len+1:end);
            % sim_data{tar_i}.right = sim_data{tar_i}.right + (1/19 * project_back_data(:, 49:end));
        else
            predicted_data_mat{sr_i, tar_i} = zeros(size(sim_data{tar_i}.left, 1), w_len*2);
        end
    end
end

%% Cross-subject predictions.
cfg.use_adr_data = 0;
out_predicted_data_mat = set_withsubj_nan(cfg, predicted_data_mat);
out_predicted_data = cell(length(sim_data));
for s_i = 1:length(sim_data)
    a = out_predicted_data_mat(:, s_i);
    b = [];
    for o_i = 1:length(a)
        if ~isnan(a{o_i})
            if isempty(b)
                b = a{o_i};
            else
                b(:, :, end+1) = a{o_i};
            end
        end
    end
    sim_data{s_i}.right = mean(b, 3);
end

%% Including projected-back L.
% sim_predicted_Q_mat = cell(1, 19);
% for tar_i = 1:length(sim_data)
%     for sr_i = 1:length(sim_data)
%         if isempty(sim_predicted_Q_mat{tar_i})
%             sim_predicted_Q_mat{tar_i} = (1/19 * predicted_data_mat{sr_i, tar_i});
%         else
%             sim_predicted_Q_mat{tar_i} = sim_predicted_Q_mat{tar_i} + (1/19 * predicted_data_mat{sr_i, tar_i});
%         end
%     end
% end

% sim_predicted_Q = cell(1, 19);
% for s_i = 1:length(sim_data)
%     sim_predicted_Q{s_i}.left = sim_predicted_Q_mat{s_i}(:, 1:48);
%     sim_predicted_Q{s_i}.right = sim_predicted_Q_mat{s_i}(:, 49:end);
% end

%% Cell-by-cell correlation
mean_coefs = zeros(length(sim_data), length(sim_data));
std_coefs = zeros(length(sim_data), length(sim_data));
for i = 1:length(sim_data)
    whiten_left = sim_data{i}.left + 0.001 * rand(size(sim_data{i}.left));
    for j = 1:length(sim_data)
        if ~isnan(out_predicted_data_mat{j, i})
            whiten_right = out_predicted_data_mat{j, i} + 0.001 * rand(size(out_predicted_data_mat{j, i}));
            cell_coefs = zeros(size(whiten_left, 1), 1);
            for k = 1:size(whiten_left, 1)
                [coef] = corrcoef(whiten_left(k, :), whiten_right(k, :));
                cell_coefs(k) = coef(1, 2);
            end
            mean_coefs(j, i) = mean(cell_coefs, 'omitnan');
            std_coefs(j, i) = std(cell_coefs, 'omitnan');
        end
    end
end

errorbar(1:numel(mean_coefs), mean_coefs(:), std_coefs(:));
xlabel('corrcoefs'); ylabel('sessions')

%% Population Vector Analysis (PVA)
coefs = cell(length(sim_data), length(sim_data));
w_len = size(sim_data{1}.left, 2) * 2;
for i = 1:length(sim_data)
    for c_i = 1:length(sim_data)
        if ~isnan(out_predicted_data_mat{c_i, i})
            w_coefs = zeros(w_len, w_len);
            corr_data = [sim_data{i}.left, out_predicted_data_mat{c_i, i}];
            for j = 1:w_len
                for k = 1:w_len
                    [coef] = corrcoef(corr_data(:, j), corr_data(:, k));
                    w_coefs(j, k) = coef(1, 2);
                end
            end
            coefs{c_i, i} = w_coefs;
            imagesc(w_coefs);
            saveas(gcf, sprintf('PV_%d_%d.png', c_i, i));
        end
    end
end
mean_coefs = mean(cat(3, coefs{:}), 3, 'omitnan');

imagesc(mean_coefs);
colorbar;
xlabel('L -> R'); ylabel('L -> R');
