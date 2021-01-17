rng(mean('hyperalignment'));

colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();

%% Plotting source and target (ordered by L of source)
data = Q;
[~, ~, predicted_Q_mat] = predict_with_L_R([], data);

for i = 1:length(data)
    target_sname = ['/Users/mac/Desktop/hyperalign_revision/sorted_Q/predicted/source/', sprintf('Q_%d', i)];
    mkdir(target_sname);
    cd(target_sname);
    for j = 1:length(data)
        [~, max_idx] = max(data{i}.left, [], 2);
        [~, sorted_idx] = sort(max_idx);
        if i ~= j
            figure;
            imagesc(predicted_Q_mat{j, i}(sorted_idx, :)); colorbar;
            saveas(gcf, sprintf('S_%d_T_%d.jpg', j, i));
            close;
        end
    end
end

%% Visualize Principal components
% Extract top pcs and reconstruct them in Q/TC space.
data = TC;
NumComponents = 10;
for p_i = 1:length(data)
    cd '/Users/mac/Desktop/hyperalign_revision/top_pcs_recon/TC';
    folder_name = sprintf('TC_%d', p_i);
    mkdir(folder_name);
    cd(folder_name);
    % Project [L, R] to PCA space
    pca_input = [data{p_i}.left, data{p_i}.right];
    pca_mean = mean(pca_input, 2);
    pca_input = pca_input - pca_mean;
    [eigvecs] = pca_egvecs(pca_input, NumComponents);
    for ev_i = 1:NumComponents
        proj_x = pca_project(pca_input, eigvecs(:, ev_i));
        recon_x = eigvecs(:, ev_i) * proj_x + pca_mean;
        % Plot reconstrcuted PCs
        imagesc(recon_x)
        colorbar;
        ylabel('Neurons');
        xlabel('L & R');
        saveas(gcf, sprintf('PC_%d.jpg', ev_i));
    end
end

%% Visualize Principal components for example sessions
figure;
set(gcf, 'Position', [37 154 1644 794]);

data = Q;
NumComponents = 10;
ex_sess_idx = [5, 14];
for s_i = 1:length(ex_sess_idx)
    sess_idx = ex_sess_idx(s_i);
    example_data = data{sess_idx};
    pca_input = [example_data.left, example_data.right];
    pca_mean = mean(pca_input, 2);
    pca_input = pca_input - pca_mean;
    [eigvecs] = pca_egvecs(pca_input, NumComponents);
    ex_pc_idx = [1, 2, 3];
    titles = {'1st PC', '2nd PC', '3rd PC'};
%     titles = {'4th PC', '5th PC', '6th PC'};
    for ev_i = 1:length(ex_pc_idx)
        pc_idx = ex_pc_idx(ev_i);
        proj_x = pca_project(pca_input, eigvecs(:, pc_idx));
        recon_x = eigvecs(:, pc_idx) * proj_x + pca_mean;
        % Plot reconstrcuted PCs
        subplot(2, 3, (s_i-1)*3 + ev_i)
        imagesc(recon_x)
        colorbar;
        set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 20);
        ylabel('neuron');
        if s_i == 1
            title(titles{ev_i});
        end
    end
end

%% FR across time/locations (raw and normalized) for each session
data = TC;

dt = {1, 1};
w_len = size(data{1}.left, 2);
exp_cond = {'left', 'right'};

dy = {1, 0.5};
ylim = {[0, 3], [-0.5, 1.5]};
ylab = {'FR', 'Z-score'};

FR_data = {TC, TC_norm_Z};
for s_i = 1:length(FR_data{1}(:))
    figure;
    for data_i = 1:length(FR_data)
        FR = [FR_data{data_i}{s_i}.left, FR_data{data_i}{s_i}.right] / dt{data_i};
        subplot(3, 2, data_i);
        imagesc(FR); colorbar;
        for exp_i = 1:length(exp_cond)
            FR_exp = FR_data{data_i}{s_i}.(exp_cond{exp_i}) / dt{data_i};

            mean_across_w = mean(FR_exp, 1);
            std_across_w = std(FR_exp, 1);

            subplot(3, 2, data_i + 2*exp_i);
            title(exp_cond{exp_i});

            x = 1:length(mean_across_w);
            xpad = 1;

            h = plot(x, mean_across_w, 'b');
            hold on;
            set(gca, 'XTick', [], 'YTick', [ylim{data_i}(1):dy{data_i}:ylim{data_i}(2)], 'XLim', [x(1)-1 x(end)+1], ...
            'YLim', [ylim{data_i}(1) ylim{data_i}(2)], 'FontSize', 12, 'LineWidth', 1, 'TickDir', 'out');
            box off;
            xlabel('Time'); ylabel(ylab{data_i});
            title(exp_cond{exp_i});
        end
    end
    saveas(gcf, sprintf('TC_%d.jpg', s_i));
    close;
end

%% FR across time/locations (raw and normalized) combined across sessions
data = TC;

dt = {1, 1};
w_len = size(data{1}.left, 2);
exp_cond = {'left', 'right'};

dy = {1, 0.5};
ylim = {[0, 3], [-0.5, 1.5]};
ylab = {'FR', 'Z-score'};

FR_data = {TC, TC_norm_Z};

figure;
for data_i = 1:length(FR_data)
    for exp_i = 1:length(exp_cond)
        subplot(2, 2, data_i + 2*(exp_i-1));
            
        FR_acr_sess = [];
        for s_i = 1:length(FR_data{1}(:))
            FR_exp = FR_data{data_i}{s_i}.(exp_cond{exp_i}) / dt{data_i};
            FR_acr_sess = [FR_acr_sess; FR_exp];
        end
        mean_across_w = mean(FR_acr_sess, 1);
        
        x = 1:length(mean_across_w);
        xpad = 1;

        h = plot(x, mean_across_w, 'b');
        hold on;
        set(gca, 'XTick', [], 'YTick', [ylim{data_i}(1):dy{data_i}:ylim{data_i}(2)], 'XLim', [x(1)-1 x(end)+1], ...
        'YLim', [ylim{data_i}(1) ylim{data_i}(2)], 'FontSize', 12, 'LineWidth', 1, 'TickDir', 'out');
        box off;
        xlabel('time'); ylabel(ylab{data_i});
        title(exp_cond{exp_i});
    end
end

%% Test: Prediction error as a function of scaling factor
data = Q;

scaling_factors = 0.1:0.1:2;
err_acr_scale = zeros(2, length(scaling_factors));
% mean_err_acr_scale = zeros(1, length(scaling_factors));
% std_err_acr_scale = zeros(1, length(scaling_factors));
for i = 1:length(scaling_factors)
    cfg_pre = [];
    cfg_pre.predict_target = 'Q';
    cfg_pre.scaling_factor = scaling_factors(i);
    [actual_dists_mat] = predict_with_L_R(cfg_pre, data);
%     out_actual_dists_mat = set_withsubj_nan([], actual_dists_mat);
%     mean_err_acr_scale(i) = nanmean(out_actual_dists_mat(:));
%     std_err_acr_scale(i) = nanstd(out_actual_dists_mat(:));
    err_acr_scale(1, i) = actual_dists_mat(1, 6);
    err_acr_scale(2, i) = actual_dists_mat(6, 1);
end

dy = 25000;
x = 1:length(scaling_factors);
xpad = 1;
ylim = [0, 100000];

% h = shadedErrorBar(x, mean_err_acr_scale, std_err_acr_scale);
% set(h.mainLine, 'LineWidth', 1);
for i = 1:2
    subplot(2, 1, i);
    h = plot(x, err_acr_scale(i, :), 'b');
    hold on;
    set(gca, 'XTick', x, 'YTick', [ylim(1):dy:ylim(2)], 'XLim', [x(1) x(end)], ...
        'YLim', [ylim(1) ylim(2)], 'FontSize', 12, 'LineWidth', 1, 'TickDir', 'out');
    box off;
    xticklabels(scaling_factors);
    xlabel('Scale'); ylabel('Error in Q space')
end

%% Test: FR left actual, right (actual, predicted and differences) for each session
data = Q;
dt = 0.05;

for i = 1:length(data)
    % Make data (Q) into Hz first
    data{i}.left = data{i}.left / dt;
    data{i}.right = data{i}.right / dt;
    
    FR_acr_sess.left{i} = data{i}.left;
    FR_acr_sess.right{i} = data{i}.right;
end

w_len = size(data{1}.left, 2);

[~, ~, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);

exp_cond = {'L (actual)', 'R (actual)'};
FR_data_plots = {FR_acr_sess.left, FR_acr_sess.right};
ylabs = {'FR', 'FR'};
dy = 1;
ylims = {[0, 4], [0, 4]};

FR_acr_sess.predicted = [];
FR_data = out_predicted_Q_mat;
for d_i = 1:length(FR_data)
    figure;
    set(gcf, 'Position', [560 80 1020 868]);
    for exp_i = 1:length(exp_cond)
        mean_across_w = mean(FR_data_plots{exp_i}{d_i}, 1);
        
        subplot(2, 2, exp_i);
        
        x = 1:length(mean_across_w);
        xpad = 1;
        ylim = ylims{exp_i};
        yt = ylim(1):dy:ylim(2);
        ytl = {ylim(1), '', (ylim(1) + ylim(2)) / 2, '', ylim(2)};
        
        h1 = plot(x, mean_across_w, '-k', 'LineWidth', 1);
        
        set(gca, 'XTick', [], 'YTick', yt, 'YTickLabel', ytl, ...
            'XLim', [x(1) x(end)], 'YLim', [ylim(1) ylim(2)], 'FontSize', 12, 'LineWidth', 1,...
            'TickDir', 'out', 'FontSize', 24);
        box off;
        xlabel('Time'); ylabel(ylabs{exp_i});
        title(exp_cond{exp_i});
    end
    
    subplot(2, 2, 4);
    target_FR = FR_data(:, d_i);
    for t_i = 1:length(target_FR)
        if ~isnan(target_FR{t_i})
            FR_predicted = target_FR{t_i}(:, w_len+1:end);
            h1 = plot(x, mean(FR_predicted, 1), 'LineStyle', '--', 'LineWidth', 1);
            hold on;
            h2 = plot(x, mean(FR_acr_sess.right{d_i}, 1), '-k', 'LineWidth', 1);
            hold on;
        end
    end
    set(gca, 'XTick', [], 'YTick', yt, 'YTickLabel', ytl, ...
        'XLim', [x(1) x(end)], 'YLim', [ylim(1) ylim(2)], 'FontSize', 12, 'LineWidth', 1,...
        'TickDir', 'out', 'FontSize', 24);
    box off;
    xlabel('Time'); ylabel('FR');
    title('R (predicted)');
    
    subplot(2, 2, 3);
    target_FR = FR_data(:, d_i);
    for t_i = 1:length(target_FR)
        if ~isnan(target_FR{t_i})
            FR_predicted = target_FR{t_i}(:, w_len+1:end);
            FR_diff = FR_predicted - FR_acr_sess.right{d_i};
            h1 = plot(x, mean(FR_diff, 1), 'LineStyle', '--', 'LineWidth', 1);
            hold on;
            h2 = plot([x(1)-xpad x(end)+xpad], [0 0], '-k', 'LineWidth', 0.75, 'Color', [0.7 0.7 0.7]);
            hold on;
        end
    end
    ylim = [-2, 2];
    yt = ylim(1):dy:ylim(2);
    ytl = {ylim(1), '', (ylim(1) + ylim(2)) / 2, '', ylim(2)};
    
    set(gca, 'XTick', [], 'YTick', yt, 'YTickLabel', ytl, ...
        'XLim', [x(1) x(end)], 'YLim', [ylim(1) ylim(2)], 'FontSize', 12, 'LineWidth', 1,...
        'TickDir', 'out', 'FontSize', 24);
    box off;
    xlabel('Time'); ylabel('Difference');
    title('R (actual vs. predicted)');
    
    saveas(gcf, sprintf('Q_%d.jpg', d_i));
    close;
end

%% Plot running speed between left and right
data = SPD;
exp_cond = {'left', 'right'};

for exp_i = 1:length(exp_cond)
    exp_spd{exp_i} = [];
    for d_i = 1:length(SPD)
        exp_spd{exp_i} = [exp_spd{exp_i}, SPD{d_i}.(exp_cond{exp_i})];
    end
end

cfg_cell_plot = [];
cfg_cell_plot.num_subjs = [length(sub_ids.start.carey), length(sub_ids.start.carey)];
cfg_cell_plot.ylim = [50, 150];
cfg_cell_plot.dy = 25;

[mean_spds, sem_spds] = plot_cell_by_cell(cfg_cell_plot, exp_spd, exp_cond);

%% Compare putative independent case (from Carey) with Carey
rng(mean('putative-independent'));
colors = get_hyper_colors();

sub_ids = get_sub_ids_start_end();
sub_ids_start = sub_ids.start.carey;
sub_ids_end = sub_ids.end.carey;
n_subjs = length(sub_ids_start);

%% Create putatively independent Q
Q_puta_int = cell(1, length(Q));
n_units = cellfun(@(x) size(x.left, 1), Q);
win_len = 48;

all_neurons_concat = cell(1, n_subjs);
for s_i = 1:n_subjs
    out_subj_Q = Q;
    out_subj_Q(sub_ids_start(s_i):sub_ids_end(s_i)) = [];
    all_neurons = cellfun(@(x) [x.left; x.right], out_subj_Q, 'UniformOutput', false);
    all_neurons_concat{s_i} = vertcat(all_neurons{:});
end

% Shuffle Q indices so that session 1 doesn't always pick neuorns first, etc.
shuffle_Q_idx = randperm(length(Q));
for i = 1:length(Q)
    Q_idx = shuffle_Q_idx(i);
    for s_i = 1:n_subjs
        if Q_idx >= sub_ids_start(s_i) && Q_idx <= sub_ids_end(s_i)
            rand_sample_idx = randsample(length(all_neurons_concat{s_i}), n_units(Q_idx));
            Q_puta_int{Q_idx}.left = all_neurons_concat{s_i}(rand_sample_idx, :);
            % Shift shuffles
            for l_i = 1:length(Q_puta_int{Q_idx}.left)
                if rand() <= 0.5
                    [shuffle_indices] = shift_shuffle(win_len);
                    L_row = Q_puta_int{Q_idx}.left(l_i, :);
                    Q_puta_int{Q_idx}.left(l_i, :) = L_row(shuffle_indices);
                end
            end
            
            Q_puta_int{Q_idx}.right = Q{Q_idx}.right;
            % sampling without replacement, if neurons were picked then
            % moved out, avoid repetiion.
            all_neurons_concat{s_i}(rand_sample_idx, :) = [];
        end
    end
end

imagesc([Q_puta_int{1}.left, Q_puta_int{1}.right])

%%
datas = {Q, Q_puta_int};
themes = {'raw', 'resampled ind.'};

%% Hyperalignment procedure
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
end

%% Hypertransform in Putative Int.
x_limits = [-6.5, 6.5];
x_tick = -6:6;
xtick_labels = {-6, 6};
binsizes = 1;

cfg_plot = [];
cfg_plot.hist_colors = {[198/255 113/255 113/255]};
cfg_plot.fit_colors = {[198/255 113/255 113/255]};

cfg_metric = [];
cfg_metric.use_adr_data = 0;
[z_score, mean_shuffles, proportion] = calculate_common_metrics(cfg_metric, ...
    actual_dists_mat{2}, id_dists_mat{2}, sf_dists_mat{2});

this_ax = subplot(2, 3, 1);
matrix_obj = {z_score.out_zscore_mat};

cfg_plot.xlim = x_limits;
cfg_plot.xtick = x_tick;
cfg_plot.xtick_label = xtick_labels;
cfg_plot.binsize = binsizes;
cfg_plot.ax = this_ax;
cfg_plot.insert_zero = 1; % plot zero xtick
cfg_plot.plot_vert_zero = 1;
cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)

plot_hist2(cfg_plot, matrix_obj); % ht, then pca
ylabel('count');

set(gcf, 'Position', [316 253 1160 653]);

%% HT prediction in Carey vs. Putative Int. in Carey.
x_limits = [-5e4, 5e4];
x_tick = -5e4:5000:5e4;
xtick_labels = {sprintf('-5\\times10^{%d}', 4), sprintf('-5\\times10^{%d}', 4)};
binsizes = 7500;

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.hist};


cfg_metric = [];
cfg_metric.use_adr_data = 0;
out_actual_dists = set_withsubj_nan(cfg_metric, actual_dists_mat{1});
out_actual_dists_ind = set_withsubj_nan(cfg_metric, actual_dists_mat{2});

matrix_obj = {out_actual_dists - out_actual_dists_ind};
bino_ps = calculate_bino_p(sum(sum(out_actual_dists <= out_actual_dists_ind)), sum(sum(~isnan(out_actual_dists))), 0.5);;
signrank_ps = signrank(out_actual_dists(:),  out_actual_dists_ind(:));
this_ax = subplot(2, 3, 2);

cfg_plot.xlim = x_limits;
cfg_plot.xtick = x_tick;
cfg_plot.xtick_label = xtick_labels;
cfg_plot.binsize = binsizes;
cfg_plot.ax = this_ax;
cfg_plot.insert_zero = 1; % plot zero xtick
cfg_plot.plot_vert_zero = 1;
cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)

plot_hist2(cfg_plot, matrix_obj); % ht, then pca
ylabel('count');

%% Cell-by-cell correlation across subjects
for d_i = 1:length(datas)
    cell_coefs{d_i} = cell2mat(calculate_cell_coefs(datas{d_i}));
end

cfg_cell_plot = [];
cfg_cell_plot.ax = subplot(2, 3, 3);
cfg_cell_plot.num_subjs = [length(sub_ids.start.carey), length(sub_ids.start.adr)];
cfg_cell_plot.ylim = [-0.2, 0.6];

[mean_coefs, sem_coefs_types] = plot_cell_by_cell(cfg_cell_plot, cell_coefs, themes);

% Wilcoxon rank sum test for Carey and Putative Int.
ranksum(cell_coefs{1}, cell_coefs{2})

% Wilcoxon signed rank test for Carey vs 0
signrank(cell_coefs{1})
%% Population Vector analysis
for d_i = 1:length(datas)
    data = datas{d_i};
    PV_coefs{d_i} = calculate_PV_coefs(data);
end

%% Plot Population Vector correlation coefficents matrix
cfg_pv_plot = [];
cfg_pv_plot.clim = [-0.2 1];
for d_i = 1:length(datas)
    cfg_pv_plot.ax = subplot(2, 3, 3 + d_i);
    plot_PV(cfg_pv_plot, PV_coefs{d_i});
end

%% Plot off-diagonal of Population Vector correlation
cfg_off_pv_plot = [];
cfg_off_pv_plot.ax = subplot(2, 3, 6);
cfg_off_pv_plot.num_subjs = [length(sub_ids.start.carey), length(sub_ids.start.adr)];
cfg_off_pv_plot.ylim = [-0.3, 0.5];

for d_i = 1:length(datas)
    off_diag_PV_coefs{d_i} = get_off_dig_PV(PV_coefs{d_i});
end
[mean_coefs, sem_coefs_types] = plot_off_diag_PV(cfg_off_pv_plot, off_diag_PV_coefs, themes);

% Wilcoxon signed rank test for Carey and Putative Int. off-diagonal
ranksum(off_diag_PV_coefs{1}(:), off_diag_PV_coefs{2}(:))

%% Compare shift shuffles and raw shuffles
data = Q;

shuffle_methods = {'shift', 'row'};
for d_i = 1:length(shuffle_methods)
    cfg_shuffle.shuffle_method = shuffle_methods{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles(cfg_shuffle, data, @predict_with_L_R);
end

%% Stats
mean_sf = mean(sf_dists_mat{1}, 3) - mean(sf_dists_mat{2}, 3);
out_mean_sf = set_withsubj_nan([], mean_sf);

% Mean and SEM
n_subjs = length(sub_ids.start.carey);
out_mean_sf_mean = nanmean(out_mean_sf(:));
out_mean_sf_sem = nanstd(out_mean_sf(:)) / sqrt(n_subjs * (n_subjs - 1));

% Signed rank test vs. 0 (two tailed)
out_mean_sf_sign_rank_p = signrank(out_mean_sf(:));
out_mean_sf_bino_p = calculate_bino_p(sum(sum(out_mean_sf <= 0)), sum(sum(~isnan(out_mean_sf))), 0.5);

%% Split data into half and use one half to do hypertransfrom and other half as comparison
datas = {Q, adr_Q};
datas_split = {Q_split, adr_Q_split};
%% Hyperalignment procedure
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R_withhold);
end

%% Use the preserved half as control and compare to ground truth
for d_i = 1:length(datas)
    data = datas{d_i};
    data_split = datas_split{d_i};
    for sr_i = 1:length(data)
        for tar_i = 1:length(data)
            ground_truth = data{tar_i}.right;
            if sr_i ~= tar_i
                actual_dist = calculate_dist('all', data_split{tar_i}.right_c, ground_truth);
                actual_dists_mat_c{d_i}(tar_i) = actual_dist;
            else
                actual_dists_mat_c{d_i}(sr_i, tar_i) = NaN;
            end
        end
    end
end

%% Plot
x_limits = {[0, 2.05e5]}; % two rows, three columns in figure
x_tick = {0:20000:2*1e5};
xtick_labels = {{0, sprintf('2\\times10^{%d}', 5)}};
binsizes = [10000]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.fit};

for d_i = 1:length(datas)
    cfg_metric = [];
    cfg_metric.use_adr_data = 0;
    if d_i == 2
        cfg_metric.use_adr_data = 1;
    end
    out_dists_mat{d_i} = set_withsubj_nan(cfg_metric, actual_dists_mat{d_i});
    out_dists_mat_c{d_i} = set_withsubj_nan(cfg_metric, actual_dists_mat_c{d_i});

    matrix_obj = {out_dists_mat{d_i}};
%     this_ax = subplot(1, 2, d_i);

    cfg_plot.xlim = x_limits{1};
    cfg_plot.xtick = x_tick{1};
    cfg_plot.xtick_label = xtick_labels{1};
    cfg_plot.binsize = binsizes(1);
%     cfg_plot.ax = this_ax;
%     cfg_plot.insert_zero = 1; % plot zero xtick
%     cfg_plot.plot_vert_zero = 1;
    cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)

    plot_hist2(cfg_plot, matrix_obj);
end