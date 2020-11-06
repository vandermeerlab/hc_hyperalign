rng(mean('hyperalignment'));

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
ylabs = {'firing rate', 'firing rate', 'difference', 'firing rate'};
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
    'TickDir', 'out', 'FontSize', 20);
    box off;
    xlabel('time'); ylabel(ylabs{d_i});
    title(exp_cond{d_i});
end

%% Calculate errors across locations/time
cfg_pre = [];
cfg_pre.dist_dim = 1;
[actual_dists_mat_err, id_dists_mat_err] = predict_with_L_R(cfg_pre, Q);

cfg.use_adr_data = 0;
out_dists = set_withsubj_nan(cfg, actual_dists_mat_err);
out_keep_idx = cellfun(@(C) any(~isnan(C(:))), out_dists);
out_dists = out_dists(out_keep_idx);
out_dists = cell2mat(out_dists);

% Normalize within session to prevent average dominated by high errors
norm_out_dists = zscore(out_dists, 0, 2);
mean_across_w = mean(norm_out_dists, 1);
std_across_w = std(norm_out_dists, 1);

subplot(2, 1, 1);

dy = 1;
x = 1:length(mean_across_w);
xpad = 1;
ylim = [-2, 2];

h = shadedErrorBar(x, mean_across_w, std_across_w);
set(h.mainLine, 'LineWidth', 1);
hold on;
set(gca, 'XTick', [], 'YTick', [ylim(1):dy:ylim(2)], 'XLim', [x(1) x(end)], ...
    'YLim', [ylim(1) ylim(2)], 'FontSize', 20, 'LineWidth', 1, 'TickDir', 'out');
box off;
xlabel('time'); ylabel('error z-score')

set(gcf, 'Position', [560 121 531 827]);

%% Variance explained as a function of number of PCs
num_pcs = 20;
cum_vars = zeros(length(Q), num_pcs);

for q_i = 1:length(Q)
    % Concatenate Q matrix across left and right trials and perform PCA on it.
    pca_input = [Q{q_i}.left, Q{q_i}.right];
    pca_mean = mean(pca_input, 2);
    pca_input = pca_input - pca_mean;
    [~, ~, ~, ~, explained, ~] = pca(pca_input);
    cum_vars(q_i, :) = cumsum(explained(1:num_pcs));
end

mean_var_pcs = mean(cum_vars, 1);
std_var_pcs = std(cum_vars, 1);

subplot(2, 1, 2);
x = 1:num_pcs;
h = errorbar(x, mean_var_pcs, std_var_pcs, 'LineStyle', '-', 'LineWidth', 1);
hold on;
plot(x, mean_var_pcs, '.', 'MarkerSize', 15, 'Color', [0 0.4470 0.7410]);
set(gca, 'FontSize', 20, 'LineWidth', 1, 'TickDir', 'out');
xlabel('number of PCs'); ylabel('explained variance (%)')
box off;