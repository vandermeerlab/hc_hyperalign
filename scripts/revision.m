rng(mean('hyperalignment'));

%% Sorting neurons by the temporal (spatial) order of fields
data = TC;
[actual_dists_mat, id_dists_mat, predicted_Q_mat] = predict_with_L_R([], data);

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
data = Q;

exp_cond = {'left', 'right'};

for d_i = 1:length(data)
    figure;
    for exp_i = 1:length(exp_cond)
        FR = data{d_i}.(exp_cond{exp_i});
        mean_across_w = mean(FR, 1);
        std_across_w = std(FR, 1);

        subplot(1, 2, exp_i);
        title(exp_cond{exp_i});

        dy = 1;
        x = 1:length(mean_across_w);
        xpad = 1;
        ylim = [-2, 2];

        h = shadedErrorBar(x, mean_across_w, std_across_w);
        set(h.mainLine, 'LineWidth', 1);
        hold on;
        set(gca, 'XTick', [], 'YTick', [ylim(1):dy:ylim(2)], 'XLim', [x(1) x(end)], ...
        'YLim', [ylim(1) ylim(2)], 'FontSize', 12, 'LineWidth', 1, 'TickDir', 'out');
        box off;
        xlabel('Time'); ylabel('FR')
    end
    saveas(gcf, sprintf('Q_%d.jpg', d_i));
end