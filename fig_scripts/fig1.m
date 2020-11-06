%% Plot example sessions for procedure
rng(mean('hyperalignment'));

% Pair of 2 and 9 is the highest z-score asymmetry pair.
sr_i = 2;
tar_i = 6;
idx = {sr_i, tar_i};
data = Q;

% Project [L, R] to PCA space.
NumComponents = 10;
for p_i = 1:length(data)
    [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(data{p_i}, NumComponents);
end

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
    imagesc([data{idx{i}}.left, data{idx{i}}.right]);
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
w_len = size(aligned_left{2}, 2);
pro_pca_left = project_back_pca(:, 1:w_len);
pro_pca_right = project_back_pca(:, w_len+1:end);
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

subplot(1, 2, 2);
imagesc(pro_Q_right);
ylabel('neuron');
xlabel('time');
set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 24);