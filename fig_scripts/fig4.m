rng(mean('hyperalignment'));
colors = get_hyper_colors();

% Correlation analysis in various simulations: L_R_ind, L_xor_R, L_R_same_μ, sim_HT
datas = {Q_ind, Q_xor, Q_same_mu, Q_sim_HT};
themes = {'ind.', 'x-or', 'ind.(same μ)', 'sim. HT'};

%% Example inputs
cfg_ex = [];
cfg_ex.n_units = 30;
ex_xor = L_xor_R(cfg_ex);
ex_ind = L_R_ind(cfg_ex);
ex_same_mu = L_R_ind(struct('same_mu', 1, 'n_units', 30));
ex_sim_HT = sim_HT(cfg_ex);

ex_datas = {ex_ind, ex_xor, ex_same_mu, ex_sim_HT};
for d_i = 1:length(datas)
    subplot(4, 4, d_i)
    imagesc([ex_datas{d_i}{1}.left, ex_datas{d_i}{1}.right]);
    colorbar;
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 12);
    ylabel('Cells');
    title(themes{d_i});
end

set(gcf, 'Position', [316 185 898 721]);

%% Hyperalignment procedure
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
end

%% ID prediction in various simulations.
x_limits = {[-10, 15], [-20, 10], [-40, 5], [-60, 10], ...
    [0 ,400], [0 ,500], [0 ,300], [0 ,400]};
x_tick = {-10:15, -20:10, -40:5, -60:10, 0:100:400, 0:100:500, 0:100:300, 0:100:400};
binsizes = [2.5, 2.5, 5, 5, 10, 10, 10, 10];

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist, colors.ID.hist};
cfg_plot.fit_colors = {colors.HT.fit, colors.ID.fit};

for d_i = 1:length(datas)
    [~, mean_shuffles, ~, M_ID] = calculate_common_metrics([], actual_dists_mat{d_i}, ...
    id_dists_mat{d_i}, sf_dists_mat{d_i});

    matrix_objs = {{mean_shuffles.out_actual_mean_sf}, {M_ID.out_actual_dists, M_ID.out_id_dists}};
    for m_i = 1:length(matrix_objs)
        this_ax = subplot(4, 4, 4 * m_i + d_i);
        p_i = (m_i - 1) * 4 + d_i; % % plot index to access x_limits etc defined above
        matrix_obj = matrix_objs{m_i};

        cfg_plot.xlim = x_limits{p_i};
        cfg_plot.xtick = x_tick{p_i};
        cfg_plot.binsize = binsizes(p_i);
        cfg_plot.ax = this_ax;
        cfg_plot.insert_zero = 0; % plot zero xtick
        cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)

        plot_hist2(cfg_plot, matrix_obj); % ht, then pca

    end
end

%% Population Vector analysis
for d_i = 1:length(datas)
    data = datas{d_i};
    data = cellfun(@(x) [x.left, x.right], data, 'UniformOutput', false);
    coefs = cell(1, length(data));

    w_len = size(data{1}, 2);
    for i = 1:length(data)
        w_coefs = zeros(w_len, w_len);
        for j = 1:w_len
            for k = 1:w_len
                [coef] = corrcoef(data{i}(:, j), data{i}(:, k));
                w_coefs(j, k) = coef(1, 2);
            end
        end
        coefs{i} = w_coefs;
    end

    mean_coefs = mean(cat(3, coefs{:}), 3);
    subplot(4, 4, 12 + d_i)
    imagesc(mean_coefs);
    colorbar;
    this_scale = [-0.2 1]; caxis(this_scale);
    xlabel('L -> R'); ylabel('L -> R');
end

%% Cell-by-cell correlation across subjects
mean_coefs_types = zeros(length(datas), 1);
% sem_coefs_types = zeros(length(datas), 1);
sd_coefs_types = zeros(length(datas), 1);
sub_ids_start = [1, 6, 8, 14];
sub_ids_end = [5, 7, 13, 19];

for d_i = 1:length(datas)
    data = datas{d_i};
    mean_coefs = zeros(1, length(sub_ids_start));

    for s_i = 1:length(sub_ids_start)
        cell_coefs = [];
        for w_i = sub_ids_start(s_i):sub_ids_end(s_i)
            whiten_left = data{w_i}.left + 0.00001 * rand(size(data{w_i}.left));
            whiten_right = data{w_i}.right + 0.00001 * rand(size(data{w_i}.right));

            for c_i = 1:size(data{w_i}.left, 1)
                [coef] = corrcoef(whiten_left(c_i, :), whiten_right(c_i, :));
                cell_coefs = [cell_coefs, coef(1, 2)];
            end
        end
        mean_coefs(s_i) = mean(cell_coefs, 'omitnan');
    end
    mean_coefs_types(d_i) = mean(mean_coefs);
    % sem_coefs_types(d_i) = std(mean_coefs) / sqrt(length(mean_coefs));
    sd_coefs_types(d_i) = std(mean_coefs);
end

figure; subplot(2, 3, 1);

dx = 0.1;
x = dx * (1:length(datas));
xpad = 0.05;
h = errorbar(x, mean_coefs_types, sd_coefs_types, 'LineStyle', 'none', 'LineWidth', 2);
set(h, 'Color', 'k');
hold on;
plot(x, mean_coefs_types, '.k', 'MarkerSize', 20);
set(gca, 'TickLabelInterpreter', 'latex');
set(gca, 'XTick', x, 'YTick', [-0.15:0.1:0.35], 'XTickLabel', themes, ...
    'XLim', [x(1)-xpad x(end)+xpad], 'YLim', [-0.15 0.35], 'FontSize', 12, ...
    'LineWidth', 1, 'TickDir', 'out');
% title('Cell-by-cell correlation (across subjects)');
box off;
plot([x(1)-xpad x(end)+xpad], [0 0], '--k', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);
