%% Plot example sessions for procedure
rng(mean('hyperalignment'));

%%
% Pair of 2 and 9 is the highest z-score asymmetry pair.
sr_i = 1;
tar_i = 10;
idx = {sr_i, tar_i};
data = Q;

[~, max_sr_idx] = max(data{sr_i}.left, [], 2);
[~, sorted_sr_idx] = sort(max_sr_idx);

[~, max_tar_idx] = max(data{tar_i}.left, [], 2);
[~, sorted_tar_idx] = sort(max_tar_idx);

sorted_idx = {sorted_sr_idx, sorted_tar_idx};
                
% Project [L, R] to PCA space.
NumComponents = 10;
for p_i = 1:length(data)
    [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(data{p_i}, NumComponents);
end

%% Exclude target to be predicted
ex_Q = Q;
ex_Q{tar_i}.right = zeros(size(Q{tar_i}.right));
% PCA
ex_proj_Q = proj_Q;
ex_eigvecs = eigvecs;
ex_pca_mean = pca_mean;
[ex_proj_Q{tar_i}, ex_eigvecs{tar_i}, ex_pca_mean{tar_i}] = perform_pca(ex_Q{tar_i}, NumComponents);

%% Row shuffles on R activity
s_Q = Q;
for s_i = 1:length(Q)
    shuffle_indices = randperm(size(Q{s_i}.right, 1));
    s_Q{s_i}.right = Q{s_i}.right(shuffle_indices, :);
    s_pca_input = s_Q{s_i};
    [s_proj_Q{s_i}] = perform_pca(s_pca_input, NumComponents);
end

data{sr_i} = s_Q{sr_i};
proj_Q{sr_i} = s_proj_Q{sr_i};

%% Input and PCA
figure;
for i = 1:length(idx)
    subplot(2, 2, 2*i-1);
    imagesc([data{idx{i}}.left(sorted_idx{i}, :), data{idx{i}}.right(sorted_idx{i}, :)]);
    ylabel('neuron');
    xlabel('time');
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 24);

    subplot(2, 2, 2*i);
    plot_L = plot_3d_trajectory(proj_Q{idx{i}}.left);
    plot_L.Color = 'r';
    hold on;
    plot_R = plot_3d_trajectory(proj_Q{idx{i}}.right);
    plot_R.Color = 'b';
    if i == 1
        plot_L.Color(4) = 0.5;
        plot_R.Color(4) = 0.5;
    end
    hold on;
end

%% PCA-only
[~, ~, M] = procrustes(proj_Q{sr_i}.right', proj_Q{sr_i}.left', 'scaling', false);
% Apply M to L of target session to predict.
predicted_aligned = p_transform(M, proj_Q{tar_i}.left);

%% Common space
figure;
hyper_input = {proj_Q{sr_i}, proj_Q{tar_i}};
[aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
[~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
predicted_aligned = p_transform(M, aligned_left{2});

% hyper_input = {proj_Q{sr_i}, ex_proj_Q{tar_i}};
% [aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
% [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
% predicted_aligned = p_transform(M, aligned_left{2});

% hyper_input = {proj_Q{sr_i}.left, ex_proj_Q{tar_i}.left};
% [aligned_left, transforms] = hyperalign(hyper_input{:});
% aligned_right{1} = p_transform(transforms{1}, proj_Q{sr_i}.right);
% aligned_right{2} = p_transform(transforms{2}, ex_proj_Q{sr_i}.right);
% [~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
% predicted_aligned = p_transform(M, aligned_left{2});

s_plot_L = plot_3d_trajectory(aligned_left{1});
s_plot_L.Color = 'r';
s_plot_L.Color(4) = 0.5;
hold on;
s_plot_R = plot_3d_trajectory(aligned_right{1});
s_plot_R.Color = 'b';
s_plot_R.Color(4) = 0.5;
hold on;
t_plot_L = plot_3d_trajectory(aligned_left{2});
t_plot_L.Color = 'r';
hold on;
t_plot_R = plot_3d_trajectory(aligned_right{2});
t_plot_R.Color = 'b';
hold on;
p_plot_R = plot_3d_trajectory(predicted_aligned);
p_plot_R.Color = 'g';

%% Project back to PCA space and input space
figure;
project_back_pca = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);
% project_back_pca = inv_p_transform(transforms{2}, predicted_aligned);

w_len = size(aligned_left{2}, 2);
pro_pca_left = project_back_pca(:, 1:w_len);
pro_pca_right = project_back_pca(:, w_len+1:end);

% pro_pca_right = project_back_pca;

subplot(1, 2, 1);
plot_L = plot_3d_trajectory(pro_pca_left);
plot_L.Color = 'r';
hold on;
plot_R = plot_3d_trajectory(proj_Q{tar_i}.right);
plot_R.Color = 'b';
hold on;
p_plot_R = plot_3d_trajectory(pro_pca_right);
p_plot_R.Color = 'g';
hold on;

project_back_Q = eigvecs{tar_i} * project_back_pca + pca_mean{tar_i};
pro_Q_right = project_back_Q(:, w_len+1:end);

% project_back_Q = ex_eigvecs{tar_i} * project_back_pca + ex_pca_mean{tar_i};
% pro_Q_right = project_back_Q;

subplot(1, 2, 2);
imagesc(pro_Q_right(sorted_idx{2}, :)); caxis([0, max(data{tar_i}.right(:))])
ylabel('neuron');
xlabel('time');
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 24);

%% Fig. 1B
% Source 6 and target 5 for fig. 1B
sr_i = 6;
tar_i = 5;
data = Q;
[~, ~, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);
w_len = size(data{1}.left, 2);

%%
figure;
set(gcf, 'Position', [540 71 1139 884]);

example_data = {Q{tar_i}.left, Q{tar_i}.right, out_predicted_Q_mat{sr_i, tar_i}(:, w_len+1:end)};
[~, max_idx] = max(Q{tar_i}.left, [], 2);
[~, sorted_idx] = sort(max_idx);

for i = 1:3

    sorted_data = example_data{i}(sorted_idx, :);
    
    marker_row = nan(1, w_len);
    marker_row(31) = 50; marker_row(33) = 50;
    marker_row(44) = 50; marker_row(46) = 50;
    
    sorted_data(end+1, :) = marker_row;
    
    subplot(1, 3, i);
    imagesc(sorted_data, 'AlphaData', ~isnan(sorted_data));
    caxis([0, 50]);
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 20);

end

%% Project [L, R] to PCA space.
NumComponents = 10;
for p_i = 1:length(data)
    [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(data{p_i}, NumComponents);
end

figure;
subplot(1, 2, 1);
plot_L = plot_3d_trajectory(proj_Q{tar_i}.left);
plot_L.Color = 'r';
hold on;
plot_R = plot_3d_trajectory(proj_Q{tar_i}.right);
plot_R.Color = 'b';

%% Obtain hypertransform and Project back to PCA space
hyper_input = {proj_Q{sr_i}, proj_Q{tar_i}};
[aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
[~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
predicted_aligned = p_transform(M, aligned_left{2});

project_back_pca = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);
w_len = size(aligned_left{2}, 2);
pro_pca_left = project_back_pca(:, 1:w_len);
pro_pca_right = project_back_pca(:, w_len+1:end);

subplot(1, 2, 2);
plot_L = plot_3d_trajectory(proj_Q{tar_i}.left);
plot_L.Color = 'r';
hold on;
p_plot_R = plot_3d_trajectory(pro_pca_right);
p_plot_R.Color = 'g';