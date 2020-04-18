rng(mean('hyperalignment'));

sub_ids = get_sub_ids_start_end();

%% Sorting neurons by the temporal (spatial) order of fields
data = Q;
[~, ~, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);
w_len = size(data{1}.left, 2);

datas = {Q, out_predicted_Q_mat};
exp_cond = {'actual', 'predicted'};

for d_i = 1:length(datas)
    data = datas{d_i};
    max_fields = zeros(w_len, w_len);
    for sess_i = 1:length(data(:))
        if d_i == 1
            Q_sess = [data{sess_i}.left, data{sess_i}.right];
        else
            Q_sess = out_predicted_Q_mat{sess_i};
        end
        if ~isnan(Q_sess)
            for neu_i = 1:size(Q_sess, 1)
                FR_left_same = abs(Q_sess(neu_i, 1:w_len) - Q_sess(neu_i, 1)) < 1e-4;
                FR_right_same = abs(Q_sess(neu_i, w_len+1:end) - Q_sess(neu_i, w_len+1)) < 1e-4;
                if ~all(FR_left_same) && ~all(FR_right_same)
                    [~, max_L] = max(Q_sess(neu_i, 1:w_len));
                    [~, max_R] = max(Q_sess(neu_i, w_len+1:end));
                    max_fields(max_L, max_R) = max_fields(max_L, max_R) + 1;
                end
            end
        end
    end
    max_fields = max_fields / sum(sum(max_fields));
    
    subplot(2, 2, d_i);
    imagesc(max_fields); colorbar;
    set(gca,'YDir','normal');
    xlabel('Left');
    ylabel('Right');
    title(exp_cond{d_i});
    
    subplot(2, 2, d_i + 2);
    plot(1:length(max_fields), sum(max_fields, 1));
end

%% Plot left vs. right fields for both actual and predicted data


%% Plotting source and target (ordered by L of source)
data = TC;
[~, ~, predicted_Q_mat] = predict_with_L_R([], data);

for i = 1:length(data)
    target_sname = ['/Users/mac/Desktop/hyperalign_revision/sorted_TC/predicted/source/', sprintf('TC_%d', i)];
    mkdir(target_sname);
    cd(target_sname);
    for j = 1:length(data)
        [~, max_idx] = max(data{j}.left, [], 2);
        [~, sorted_idx] = sort(max_idx);
        if i ~= j
            figure;
            imagesc(predicted_Q_mat{i, j}(sorted_idx, :)); colorbar;
            saveas(gcf, sprintf('S_%d_T_%d.jpg', i, j));
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

%% FR across time/locations (normalized or not; before or after hypertransform)
data = Q;
% [~, ~, predicted_Q_mat] = predict_with_L_R([], data);
% out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);

dt = {0.05, 1};
w_len = size(data{1}.left, 2);
exp_cond = {'left', 'right'};

dy = {1, 0.5};
ylim = {[0, 3], [-0.5, 1.5]};
ylab = {'FR', 'Z-score'};

FR_data = {Q, Q_norm_Z};
% for data_i = 1:length(FR_data)
%     for exp_i = 1:length(exp_cond)
%         FR_acr_sess{data_i}.(exp_cond{exp_i}) = [];
    %     if exp_i == 1
    %         keep_idx = 1:w_len;
    %     else
    %         keep_idx = w_len+1:w_len*2;
    %     end
for s_i = 1:length(FR_data{1}(:))
    figure;
    for data_i = 1:length(FR_data)
        FR = [FR_data{data_i}{s_i}.left, FR_data{data_i}{s_i}.left] / dt{data_i};
        subplot(3, 2, data_i);
        imagesc(FR); colorbar;
        for exp_i = 1:length(exp_cond)
    %         if ~isnan(FR_data{d_i})
    %           FR = FR_data{d_i}(:, keep_idx);
            FR_exp = FR_data{data_i}{s_i}.(exp_cond{exp_i}) / dt{data_i};
%                 FR_acr_sess{data_i}.(exp_cond{exp_i}) = [FR_acr_sess{data_i}.(exp_cond{exp_i}); FR];
    %         end
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
%     saveas(gcf, sprintf('Q_%d.jpg', s_i));
%     close;
end

%% FR left actual, right (actual, predicted and differences)
data = Q;
dt = 0.05;

FR_acr_sess.left = [];
FR_acr_sess.right = [];
for i = 1:length(data)
    FR_acr_sess.left = [FR_acr_sess.left; data{i}.left / dt];
    FR_acr_sess.right = [FR_acr_sess.right; data{i}.right / dt];
end

[~, ~, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);

w_len = size(data{1}.left, 2);
FR_data = out_predicted_Q_mat;

FR_acr_sess.predicted = [];
for d_i = 1:length(data)
    target_FR = FR_data(:, d_i);
    target_FR_predicted = [];
    for t_i = 1:length(target_FR)
        if ~isnan(target_FR{t_i})
            FR_predicted = target_FR{t_i}(:, w_len+1:end) / dt;
            % Note that sometimes predicted data can have negative FR.
            FR_predicted = FR_predicted + min(FR_predicted, [], 2);
            target_FR_predicted = cat(3, target_FR_predicted, FR_predicted);
        end
    end
    FR_acr_sess.predicted = [FR_acr_sess.predicted; mean(target_FR_predicted, 3)];
end

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

%% Plot FR differences between sessions
dt = 0.05;
for i = 1:length(Q)
    mean_FR{i} = mean([Q{i}.left, Q{i}.right], 'all') / dt;
end

FR_diff = zeros(length(Q));
for sr_i = 1:length(Q)
    for tar_i = 1:length(Q)
       if sr_i ~= tar_i
           FR_diff(sr_i, tar_i) = abs(mean_FR{sr_i} - mean_FR{tar_i});
       end
    end
end
out_FR_diff = set_withsubj_nan([], FR_diff);

plot_matrix([], out_FR_diff);

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

%% Plot running speed differences between sessions
for i = 1:length(SPD)
    mean_SPD{i} = mean([SPD{i}.left, SPD{i}.right], 'all');
end

SPD_diff = zeros(length(SPD));
for sr_i = 1:length(SPD)
    for tar_i = 1:length(SPD)
       if sr_i ~= tar_i
           SPD_diff(sr_i, tar_i) = abs(mean_SPD{sr_i} - mean_SPD{tar_i});
       end
    end
end
out_SPD_diff = set_withsubj_nan([], SPD_diff);

plot_matrix([], out_SPD_diff);
