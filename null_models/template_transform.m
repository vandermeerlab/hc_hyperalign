%%
rng(mean('hyperalignment'));

%%
subjects = 1:4;
sub_ids = get_sub_ids_start_end();
sub_ids_starts = sub_ids.start.carey;
sub_ids_ends = sub_ids.end.carey;

% data = TC;
% data = TC_norm_Z;
data = Q;
% data = Q_norm_Z;

%%
% Project [L, R] to PCA space.
cfg.NumComponents = 10;
for p_i = 1:length(data)
    pca_input = data{p_i};
    [proj_data{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(pca_input, cfg.NumComponents);
end

%% Derive a transformation f (L -> R) from the template obtained by alignment of N - 1 subjects.
w_len = size(data{1}.left, 2);
opt_dist_diffs  = cell(1, length(data));
actual_dist_zscores = cell(1, length(data));

num_iters = 100;

actual_dist_iters = zeros(length(data), num_iters);

for val_sub_i = subjects
    align_subjects = setdiff(subjects, val_sub_i);
    align_sessions = [];
    for align_subs_i = align_subjects
        align_sessions = [align_sessions, sub_ids_starts(align_subs_i):sub_ids_ends(align_subs_i)];
    end
    for val_sess_i = sub_ids_starts(val_sub_i):sub_ids_ends(val_sub_i)
        H = proj_data{val_sess_i};
        % Withhold R of validate session
        ex_data = data;
        ex_data{val_sess_i}.right = zeros(size(data{val_sess_i}.right));
        ex_proj_data = proj_data;
        ex_eigvecs = eigvecs;
        ex_pca_mean = pca_mean;
        [ex_proj_data{val_sess_i}, ex_eigvecs{val_sess_i}, ex_pca_mean{val_sess_i}] = perform_pca(ex_data{val_sess_i}, cfg.NumComponents);
        ex_H = ex_proj_data{val_sess_i};
        
%         for align_i = sub_ids_starts(align_subjects(1)):sub_ids_ends(align_subjects(1))
%             for align_j = sub_ids_starts(align_subjects(2)):sub_ids_ends(align_subjects(2))
%                 for align_k = sub_ids_starts(align_subjects(3)):sub_ids_ends(align_subjects(3))
                    % Compare prediction to the ground truth
                    ground_truth = data{val_sess_i}.right;
                    
                    % Optimal H_right prediction
                    [~, ~, M_opt] = procrustes(H.right', H.left', 'scaling', false);
                    predicted_opt = p_transform(M_opt, H.left);
                    
                    % Project back to DATA space.
                    p_target_opt = eigvecs{val_sess_i} * predicted_opt + pca_mean{val_sess_i};
                    p_target_opt_ex = ex_eigvecs{val_sess_i} * predicted_opt + ex_pca_mean{val_sess_i};
                    
                    cfg.dist_dim = 'all';
                    actual_dist_opt = calculate_dist(cfg.dist_dim, p_target_opt, ground_truth);
                    
%                     [X, Y, Z] = proj_data{[align_i, align_j, align_k]};
%                     hyper_input = {X, Y, Z};
                    hyper_input = {proj_data{align_sessions}};
                    [aligned_left, aligned_right, transforms, T_left, T_right] = get_aligned_left_right(hyper_input);
                    template.left = T_left;
                    template.right = T_right;

                    [actual_dist, predicted_aligned] = predict_with_template_align(template, ex_H, ex_eigvecs{val_sess_i}, ex_pca_mean{val_sess_i}, ground_truth);
                    
                    for iter_i = 1:num_iters
                        ex_H = ex_proj_data{val_sess_i};
                        ex_H.right = predicted_aligned;
                        [actual_dist, p_target] = predict_with_template_align(template, ex_H, ex_eigvecs{val_sess_i}, ex_pca_mean{val_sess_i}, ground_truth);
                        
                        actual_dist_iters(val_sess_i, iter_i) = actual_dist;
                    end
                    
                    opt_dist_diffs{val_sess_i} = [opt_dist_diffs{val_sess_i}, actual_dist_opt - actual_dist];
                    
                    % Shuffle templates and get shuffled control predictions
%                     cfg.n_shuffles = 1000;
%                     sf_dists = zeros(1, cfg.n_shuffles);
%                     for sf_i = 1:cfg.n_shuffles
%                         s_template.left = template.left;
%                         shuffle_indices_R = randperm(size(template.right, 1));
%                         s_template.right = template.right(shuffle_indices_R, :);
%                         
%                         [sf_dists(sf_i)] = predict_with_template_align(s_template, ex_H, ex_eigvecs{val_sess_i}, ex_pca_mean{val_sess_i}, ground_truth);
%                     end
%                     zs = zscore([sf_dists, actual_dist]);
%                     actual_dist_zscores{val_sess_i} = [actual_dist_zscores{val_sess_i}, zs(end)];
%                 end
%             end
%         end
    end
end

%% Pairwise difference between H2* and H2^

opt_dist_diffs_m = zeros(1, length(data));
opt_dist_diffs_sem = zeros(1, length(data));

for i = 1:length(data)
    opt_dist_diffs_m(i) = nanmean(opt_dist_diffs{i});
    opt_dist_diffs_sem(i) = nanstd(opt_dist_diffs{i}) / sqrt(length(opt_dist_diffs{i}));
end

x = 1:length(opt_dist_diffs);
xpad = 0.5;
h = errorbar(x, opt_dist_diffs_m, opt_dist_diffs_sem, 'LineWidth', 1.5); hold on;
set(h, 'Color', 'k');

hold on;
plot(x, opt_dist_diffs_m, '.k', 'MarkerSize', 20);
set(gca, 'XTick', x, 'XLim', [x(1)-xpad x(end)+xpad], 'YLim', [-2e5, 1e5], 'FontSize', 18, ...
    'LineWidth', 1, 'TickDir', 'out');
box off;
plot([x(1)-xpad x(end)+xpad], [0 0], '--k', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);

xlabel('Sessions')
ylabel('$\hat{H_2}^*$ - $\hat{H_2}$ (pairwise)', 'Interpreter','latex')

%% Z-scores of H2^ compared to H2~

dist_zscores_m = zeros(1, length(data));
dist_zscores_sem = zeros(1, length(data));

for i = 1:length(data)
    dist_zscores_m(i) = nanmean(actual_dist_zscores{i});
    dist_zscores_sem(i) = nanstd(actual_dist_zscores{i}) / sqrt(length(actual_dist_zscores{i}));
end

x = 1:length(actual_dist_zscores);
xpad = 0.5;
h = errorbar(x, dist_zscores_m, dist_zscores_sem, 'LineWidth', 1.5); hold on;
set(h, 'Color', 'k');

hold on;
plot(x, dist_zscores_m, '.k', 'MarkerSize', 20);
set(gca, 'XTick', x, ...
    'XLim', [x(1)-xpad x(end)+xpad], 'YLim', [-3.5, 2], 'FontSize', 18, ...
    'LineWidth', 1, 'TickDir', 'out');
box off;
plot([x(1)-xpad x(end)+xpad], [0 0], '--k', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);

xlabel('Sessions')
ylabel('Z-scores of $\hat{H}_2$ compared to $\widetilde{H}_2$', 'Interpreter','latex')
