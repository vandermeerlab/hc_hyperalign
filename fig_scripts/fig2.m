rng(mean('hyperalignment'));
colors = get_hyper_colors();

%% Plot some example data L and R with predicitons (ordered by L of source).
data = Q_ind{1};
[~, ~, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);
w_len = size(data{1}.left, 2);

figure;
set(gcf, 'Position', [540 71 1139 884]);

ex_sess_idx = [2, 1];
for s_i = 1:length(ex_sess_idx)
    sess_idx = ex_sess_idx(s_i);
    example_data = data{sess_idx};
    example_data.predict = [out_predicted_Q_mat{6, sess_idx}(:, w_len+1:end), ...
        out_predicted_Q_mat{9, sess_idx}(:, w_len+1:end), ...
        out_predicted_Q_mat{15, sess_idx}(:, w_len+1:end)];
    
    [~, max_idx] = max(example_data.right, [], 2);
    [~, sorted_idx] = sort(max_idx);
    
    subplot(2, 1, s_i)
    imagesc([example_data.left(sorted_idx, :), example_data.right(sorted_idx, :), example_data.predict(sorted_idx, :)]);
    colorbar;
%     caxis([0, 50]);
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 20);
    ylabel('neuron');
end

%% Example row
colors = get_hyper_colors();

sess_idx = 5;
ex_cell_idx = 52;
datas = {Q{sess_idx}.left(ex_cell_idx, :), Q{sess_idx}.right(ex_cell_idx, :)};
predictions = {out_predicted_Q_mat{6, sess_idx}(ex_cell_idx, w_len+1:end), ...
        out_predicted_Q_mat{9, sess_idx}(ex_cell_idx, w_len+1:end), ...
        out_predicted_Q_mat{15, sess_idx}(ex_cell_idx, w_len+1:end)};

fit_colors = {colors.HT.fit, colors.pca.fit, colors.wh.fit, colors.ID.fit, [198/255 113/255 113/255]};

cfg_plot.fs = 24;
cfg_plot.xlim = [0, 48];
cfg_plot.binsize = 2;
cfg_plot.xtick = 0:12:48;
cfg_plot.xtick_label = {'start', 'end'};
cfg_plot.fit = 'kernel';
cfg_plot.hist_colors = {colors.HT.hist};

for i = 1:2
    cfg_plot.fit_colors = {fit_colors{i}};
    cfg_plot.ax = subplot(1, 2, i);
    plot_hist2(cfg_plot, {datas{i}});
    xlabel('time'); ylabel('firing rate');
    ylim([0, 20]);
    if i == 1
        title('left')
    else
        title('right')
        hold on;
    end
end

for j = 1:3
    cfg_plot.fit_colors = {fit_colors{2+j}};
    cfg_plot.ax = subplot(1, 2, 2);
    hold on;
    plot_hist2(cfg_plot, {predictions{j}});
end