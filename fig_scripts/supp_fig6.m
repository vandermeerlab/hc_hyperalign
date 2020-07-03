rng(mean('hyperalignment'));

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
    example_data = data{sess_idx};
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
data = Q;
[~, ~, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);
w_len = size(data{1}.left, 2);

figure;
set(gcf, 'Position', [537 71 533 884]);
datas = {Q, out_predicted_Q_mat};
exp_cond = {'actual', 'predicted'};
for d_i = 1:length(datas)
    data = datas{d_i};
    max_fields = zeros(w_len, w_len);
    neu_w_fields_idx = cell(size(data));
    left_only_count = 0;
    right_only_count = 0;
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
                elseif L_max_v > FR_thres && ~all(FR_left_same)
                    left_only_count = left_only_count + 1;
                elseif R_max_v > FR_thres && ~all(FR_right_same)
                    right_only_count = right_only_count + 1;
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
    xlabel('L');
    ylabel('R');
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