rng(mean('hyperalignment'));

%% Plot SPD/FR between left and right for each subject
data = Q;
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

ypad = 0.5;
ylim = [0, 2];

% ypad = 15;
% ylim = [10, 70];

yt = ylim(1):ypad:ylim(2);
ytl = {ylim(1), '', (ylim(1) + ylim(2)) / 2, '', ylim(2)};

set(gca, 'XTick', x, 'YTick', yt, 'YTickLabel', ytl, ...
    'XTickLabel', exp_cond, 'XLim', [x(1)-xpad x(end)+xpad], 'YLim', ylim, ...
    'FontSize', 20,'LineWidth', 1, 'TickDir', 'out');
box off;

ylabel('firing rate');
% ylabel('cm / s');

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
