rng(mean('hyperalignment'));

exp_cond = {'left', 'right'};
sub_ids = get_sub_ids_start_end();

%% Sorting neurons by the temporal (spatial) order of fields
data = Q;
[actual_dists_mat, id_dists_mat, predicted_Q_mat] = predict_with_L_R([], data);

w_len = size(data{1}.left, 2);
for i = 1:length(data)
    max_time = zeros(w_len, w_len);
    for j = 1:length(data)
        if i ~= j
            predicted = predicted_Q_mat{j, i};
            for neu_i = 1:size(predicted, 1)
                if ~all(predicted(neu_i) == 0)
                    [~, max_L] = max(predicted(neu_i, 1:w_len));
                    [~, max_R] = max(predicted(neu_i, w_len+1:end));
                    max_time(max_L, max_R) = max_time(max_L, max_R) + 1;
                end
            end
        end
    end
   imagesc(max_time); colorbar;
    set(gca,'YDir','normal');
    xlabel('Left');
    ylabel('Right');
    saveas(gcf, sprintf('Target_%d.jpg', i));
    close;
end

%% Plotting source and target (ordered by L of source)
for i = 1:length(data)
    target_sname = ['/Users/mac/Desktop/hyperalign_revision/sorted_TC/predicted/', sprintf('TC_%d', i)];
    mkdir(target_sname);
    cd(target_sname);
    [~, max_idx] = max(data{i}.left, [], 2);
    [~, sorted_idx] = sort(max_idx);
    for j = 1:length(data)
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

%% FR across time/locations (normalized or not; before or after hypertransform)
data = Q_norm_l2;
[actual_dists_mat, id_dists_mat, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);

w_len = size(data{1}.left, 2);
FR_data = out_predicted_Q_mat;
for exp_i = 1:length(exp_cond)
    FR_acr_sess.(exp_cond{exp_i}) = [];
    if exp_i == 1
        keep_idx = 1:w_len;
    else
        keep_idx = w_len+1:w_len*2;
    end
    for d_i = 1:length(FR_data(:))
        if ~isnan(FR_data{d_i})
            FR = FR_data{d_i}(:, keep_idx);
            FR_acr_sess.(exp_cond{exp_i}) = [FR_acr_sess.(exp_cond{exp_i}); FR];
        end
    end
end

%% Plot FR across time/locations
figure;

for exp_i = 1:length(exp_cond)
    mean_across_w = mean(FR_acr_sess.(exp_cond{exp_i}), 1);
    std_across_w = std(FR_acr_sess.(exp_cond{exp_i}), 1);
    
    subplot(1, 2, exp_i);
    title(exp_cond{exp_i});

    dy = 0.5;
    x = 1:length(mean_across_w);
    xpad = 1;
    ylim = [-0.5, 0.5];

    h = shadedErrorBar(x, mean_across_w, std_across_w);
    set(h.mainLine, 'LineWidth', 1);
    hold on;
    set(gca, 'XTick', [], 'YTick', [ylim(1):dy:ylim(2)], 'XLim', [x(1) x(end)], ...
    'YLim', [ylim(1) ylim(2)], 'FontSize', 12, 'LineWidth', 1, 'TickDir', 'out');
    box off;
    xlabel('Time'); ylabel('FR')
end
saveas(gcf, 'Q_norm_l2.jpg');

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