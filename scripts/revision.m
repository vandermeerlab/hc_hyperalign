rng(mean('hyperalignment'));

colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();

%% Plot some example data L and R with predicitons (ordered by L of source).
data = Q;

[~, ~, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);
w_len = size(data{1}.left, 2);

figure;
set(gcf, 'Position', [540 71 1139 884]);

ex_sess_idx = [2, 5];
for s_i = 1:length(ex_sess_idx)
    sess_idx = ex_sess_idx(s_i);
    example_data = Q{sess_idx};
    example_data.predict = [out_predicted_Q_mat{6, sess_idx}(:, w_len+1:end), ...
        out_predicted_Q_mat{9, sess_idx}(:, w_len+1:end), ...
        out_predicted_Q_mat{15, sess_idx}(:, w_len+1:end)];
    
    [~, max_idx] = max(example_data.left, [], 2);
    [~, sorted_idx] = sort(max_idx);
    
    subplot(2, 1, s_i)
    imagesc([example_data.left(sorted_idx, :), example_data.right(sorted_idx, :), example_data.predict(sorted_idx, :)]);
    colorbar;
    caxis([0, 50]);
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 20);
    ylabel('neuron');
end

%% Plot left vs. right fields for both actual and predicted data
figure;
set(gcf, 'Position', [537 71 533 884]);
datas = {Q, out_predicted_Q_mat};
exp_cond = {'actual', 'predicted'};
for d_i = 1:length(datas)
    data = datas{d_i};
    max_fields = zeros(w_len, w_len);
    neu_w_fields_idx = cell(size(data));
    for sess_i = 1:length(data(:))
        if d_i == 1
            Q_sess = [data{sess_i}.left, data{sess_i}.right];
        else
            Q_sess = out_predicted_Q_mat{sess_i};
        end
        if ~isnan(Q_sess)
            for neu_i = 1:size(Q_sess, 1)
                FR_thres = 5;
                [L_max_v, max_L_idx] = max(Q_sess(neu_i, 1:w_len));
                [R_max_v, max_R_idx] = max(Q_sess(neu_i, w_len+1:end));

                FR_left_same = abs(Q_sess(neu_i, 1:w_len) - L_max_v) < 1;
                FR_right_same = abs(Q_sess(neu_i, w_len+1:end) - R_max_v) < 1;

                if L_max_v > FR_thres && R_max_v > FR_thres && ~all(FR_left_same) && ~all(FR_right_same)
                    max_fields(max_L_idx, max_R_idx) = max_fields(max_L_idx, max_R_idx) + 1;
                    neu_w_fields_idx{sess_i} = [neu_w_fields_idx{sess_i}, neu_i];
                end
            end
        end
    end
    
    max_fields = max_fields / sum(sum(max_fields));
    cfg_plot = [];
    cfg_plot.ax = subplot(2, 1, d_i);
    cfg_plot.fs = 20;
    plot_matrix(cfg_plot, max_fields);
    title(exp_cond{d_i});
    
%     imagesc(max_fields); colorbar;
    set(gca,'YDir','normal');
    xlabel('Left');
    ylabel('Right');
end

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

%% FR left actual, right (actual, predicted and differences)
data = Q;

FR_acr_sess.left = [];
FR_acr_sess.right = [];
for i = 1:length(data)
    % Make data (Q) into Hz first
    data{i}.left = data{i}.left;
    data{i}.right = data{i}.right;
    
    FR_acr_sess.left = [FR_acr_sess.left; data{i}.left];
    FR_acr_sess.right = [FR_acr_sess.right; data{i}.right];
end

w_len = size(data{1}.left, 2);

[~, ~, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);

FR_acr_sess.predicted = [];
FR_data = out_predicted_Q_mat;
for d_i = 1:length(FR_data)
    target_FR = FR_data(:, d_i);
    target_FR_predicted = [];
    for t_i = 1:length(target_FR)
        if ~isnan(target_FR{t_i})
            FR_predicted = target_FR{t_i}(:, w_len+1:end);
%             % Note that sometimes predicted data can have negative FR.
%             % Workaround here is rescale the prediction as in actual data.
%             FR_pre_scale = zeros(size(FR_predicted));
%             min_predict = min(FR_predicted, [], 2);
%             max_predict = max(FR_predicted, [], 2);
%             min_actual = min(data{d_i}.right, [], 2);
%             max_actual = max(data{d_i}.right, [], 2);
%             for n_i = 1:size(FR_predicted, 1)
%                 if min_actual(n_i) == 0 && max_actual(n_i) == 0
%                     FR_pre_scale(n_i, :) = zeros(size(FR_pre_scale(n_i, :)));
%                 else
%                     FR_pre_scale(n_i, :) = rescale(FR_predicted(n_i, :), min_actual(n_i), max_actual(n_i));
%                 end
%             end
            target_FR_predicted = cat(3, target_FR_predicted, FR_predicted);
        end
    end
    FR_acr_sess.predicted = [FR_acr_sess.predicted; mean(target_FR_predicted, 3)];
end
    
% FR_acr_sess.predicted = avg_acr_predictions(out_predicted_Q_mat, w_len);
% 
% [~, ~, ~, sf_Q_mat] = predict_with_shuffles([], data, @predict_with_L_R);
% n_shuffles = size(sf_Q_mat, 3);
% FR_acr_sess.sf_predicted = zeros([size(FR_acr_sess.predicted), n_shuffles]);
% for s_i = 1:n_shuffles
%     out_sf_Q_mat(:, :, s_i) = set_withsubj_nan([], sf_Q_mat(:, :, s_i));c
%     FR_acr_sess.sf_predicted(:, :, s_i) = avg_acr_predictions(out_sf_Q_mat(:, :, s_i), w_len);
% end
% FR_acr_sess.sf_predicted = mean(FR_acr_sess.sf_predicted, 3);

%% Plot FR (diff) across time/locations
exp_cond = {'L (actual)', 'R (actual)', 'R (actual vs. predicted)', 'R (predicted)'};
FR_data_plots = {FR_acr_sess.left, FR_acr_sess.right, FR_acr_sess.predicted - FR_acr_sess.right, ...
    FR_acr_sess.predicted};
ylabs = {'FR', 'FR', 'Difference', 'FR'};
dy = 0.5;
ylims = {[0, 2], [0, 2], [-1, 1], [0, 2]};

set(gcf, 'Position', [560 80 1020 868]);

for d_i = 1:length(FR_data_plots)
    mean_across_w = mean(FR_data_plots{d_i}, 1);
%     std_across_w = std(FR_data_plots{d_i}, 1);

    subplot(2, 2, d_i);

    x = 1:length(mean_across_w);
    xpad = 1;
    ylim = ylims{d_i};

    if d_i == 3
        h1 = plot(x, mean_across_w, 'k--', 'LineWidth', 1);
    elseif d_i == 4
        h1 = plot(x, mean_across_w, 'Color', [198/255 113/255 113/255], ...
            'LineStyle', '--', 'LineWidth', 1);
    else
        h1 = plot(x, mean_across_w, '-k', 'LineWidth', 1);
    end
    if d_i == 3
        hold on;
        plot([x(1)-xpad x(end)+xpad], [0 0], '-k', 'LineWidth', 0.75, 'Color', [0.7 0.7 0.7]);
    elseif d_i == 4
        hold on;
        h2 = plot(x, mean(FR_data_plots{2}, 1), '-k', 'LineWidth', 1);
        lgd = legend('R predicted','R actual');
        lgd.FontSize = 16;
    end
    hold on;
    yt = ylim(1):dy:ylim(2);
    ytl = {ylim(1), '', (ylim(1) + ylim(2)) / 2, '', ylim(2)};

    set(gca, 'XTick', [], 'YTick', yt, 'YTickLabel', ytl, ...
    'XLim', [x(1) x(end)], 'YLim', [ylim(1) ylim(2)], 'FontSize', 12, 'LineWidth', 1,...
    'TickDir', 'out', 'FontSize', 24);
    box off;
    xlabel('Time'); ylabel(ylabs{d_i});
    title(exp_cond{d_i});
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

%% Plot SPD/FR between left and right for each subject
data = SPD;
exp_cond = {'left', 'right'};

sub_ids_start = sub_ids.start.carey;
sub_ids_end = sub_ids.end.carey;
sub_colors = {colors.HT.hist, colors.pca.hist, colors.wh.hist, colors.ID.hist};

figure;
set(gcf, 'Position', [548 366 430 562]);

for sub_i = 1:length(sub_ids_start)
    for exp_i = 1:length(exp_cond)
        exp_data{sub_i}.(exp_cond{exp_i}) = [];
        sub_sessions = sub_ids_start(sub_i):sub_ids_end(sub_i);
        for sess_i = sub_sessions
            if size(data{sess_i}.(exp_cond{exp_i}), 1) == 1
                exp_data{sub_i}.(exp_cond{exp_i}) = [exp_data{sub_i}.(exp_cond{exp_i}), data{sess_i}.(exp_cond{exp_i})];
            else
                exp_data{sub_i}.(exp_cond{exp_i}) = [exp_data{sub_i}.(exp_cond{exp_i}); data{sess_i}.(exp_cond{exp_i})];
            end
        end
        mean_exp_spd.(exp_cond{exp_i}) = nanmean(exp_data{sub_i}.(exp_cond{exp_i})(:));
        std_exp_spd.(exp_cond{exp_i}) = nanstd(exp_data{sub_i}.(exp_cond{exp_i})(:)) / sqrt(length(sub_sessions));
    end
    x = 1:length(exp_cond);
    y = [mean_exp_spd.left, mean_exp_spd.right];
    err = [std_exp_spd.left, std_exp_spd.right];
%     h = errorbar(x, y, err, 'LineWidth', 2);
    h = plot(x, y, '.-', 'MarkerSize', 20, 'LineWidth', 2);
    set(h, 'Color', sub_colors{sub_i});
    hold on;
end

xpad = 0.25;

% ypad = 0.5;
% ylim = [0, 2];

ypad = 15;
ylim = [10, 70];

yt = ylim(1):ypad:ylim(2);
ytl = {ylim(1), '', (ylim(1) + ylim(2)) / 2, '', ylim(2)};

set(gca, 'XTick', x, 'YTick', yt, 'YTickLabel', ytl, ...
    'XTickLabel', exp_cond, 'XLim', [x(1)-xpad x(end)+xpad], 'YLim', ylim, ...
    'FontSize', 20,'LineWidth', 1, 'TickDir', 'out');
box off;

% ylabel('firing rate');
ylabel('cm / s');

%% Two-way (subjects and left/right) anova on SPD/FR
exp_data_vector = [];
exp_vector = [];
subj_vector = [];

for sub_i = 1:length(sub_ids_start)
    for exp_i = 1:length(exp_cond)
        exp_data_flat = exp_data{sub_i}.(exp_cond{exp_i})(:)';
        exp_data_vector = [exp_data_vector, exp_data_flat];
        exp_vector = [exp_vector, repmat(exp_i, size(exp_data_flat))];
        subj_vector = [subj_vector, repmat(sub_i, size(exp_data_flat))];
    end
end

p = anovan(exp_data_vector, {exp_vector subj_vector}, ...
    'model', 'interaction', 'varnames', {'left/right','subjects'});

%% Plot SPD/FR differences between left and right (across different sessions) or between sessions

figure;
set(gcf, 'Position', [204 377 1368 524]);

data = Q;
for type_i = 1:2
    for sess_i = 1:length(data)
        if type_i == 1
                data_concat = [data{sess_i}.left, data{sess_i}.right];
                mean_data{type_i}{sess_i} = mean(data_concat(:));
        else
            mean_data{type_i}{sess_i} = (mean(data{sess_i}.right(:)) - mean(data{sess_i}.left(:)));
        end
    end
    
    data_diff{type_i} = zeros(length(data));
    for sr_i = 1:length(data)
        for tar_i = 1:length(data)
            if sr_i ~= tar_i
                data_diff{type_i}(sr_i, tar_i) = abs(mean_data{type_i}{sr_i} - mean_data{type_i}{tar_i});
            end
        end
    end
    out_data_diff{type_i} = set_withsubj_nan([], data_diff{type_i});
    
    cfg_plot = [];
    cfg_plot.ax = subplot(1, 2, type_i);
    cfg_plot.fs = 20;
    plot_matrix(cfg_plot, out_data_diff{type_i});
end

%% Compute hypertransform z-score
data = Q;
[actual_dists_mat, id_dists_mat, sf_dists_mat] = predict_with_shuffles([], data, @predict_with_L_R);
[z_score_m] = calculate_common_metrics([], actual_dists_mat, id_dists_mat, sf_dists_mat);

%% Compute correlation coefficent with hypertransform z-score matrix
type_i = 2;
keep_idx = ~isnan(out_data_diff{type_i});
[R, P] = corrcoef(out_data_diff{type_i}(keep_idx), z_score_m.out_zscore_mat(keep_idx))

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