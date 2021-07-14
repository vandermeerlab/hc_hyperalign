rng(mean('hyperalignment'));

%% Example in Fig. 1B
A = [2 0 0; 0 2 0; 1 0 0; 0 1 0; 0 0 1; 1 0 0];
low_shift_idx_A = randsample(3:6, 2)
B = [0 0 2; 2 0 0; 0 1 0; 0 1 0; 0 0 1; 0 1 0];

% Initialized subject 2 Left randomly
C = zeros(size(A));
for i = 1:length(A)
    prob = rand();
    if prob < 1/3
        C(i, :) = [1 0 0];
    elseif prob < 2/3
        C(i, :) = [0 1 0];
    else
        C(i, :) = [0 0 1];
    end
end

% Make the first two rows high-firing
C(1:2, :) = C(1:2, :) * 2;
% Randomly choose two low-firing-rate cells to shift left in D
low_shift_idx = randsample(3:6, 2);

D = C;
% High-firing-rate cells shift left, chosen low-firing ones shift right
D(1, :) = circshift(D(1, :), -1);
D(2, :) = circshift(D(2, :), -1);
D(low_shift_idx(1), :) = circshift(D(low_shift_idx(1), :), 1);
D(low_shift_idx(2), :) = circshift(D(low_shift_idx(2), :), 1);

shuffle_idx = randperm(size(C, 1));
C = C(shuffle_idx, :);
D = D(shuffle_idx, :);

Q{1}.left = A; Q{1}.right = B;
Q{2}.left = C; Q{2}.right = D;

data = Q;

%% Co-firing example

A = [2 0 0
    0 1 0
    1 0 0];

B = [2 0 0
    0 1 0
    0 1 0];

C = [0 1 0
    0 2 0
    0 0 1];

D = [0 0 1
    0 2 0
    0 0 1];

Q{1}.left = A; Q{1}.right = B;
Q{2}.left = C; Q{2}.right = D;

data = Q;

%% Random example

% Initialized subject 1 and 2's Left and Right randomly
Q{1}.left = create_random_input(6);
Q{1}.right = create_random_input(6);
Q{2}.left = create_random_input(6);
Q{2}.right = create_random_input(6);

data = Q;

%% Input
figure;
set(gcf, 'Position', [466 61 1082 935]);
for i = 1:length(Q)
    subplot(2, 3, 3*i-2);
    imagesc(data{i}.left); colorbar;
    ylabel('neuron');
    xlabel('location');
    set(gca, 'xticklabel', {'A', 'B', 'C'}, 'yticklabel', {'1', '2', '3', '4', '5', '6'}, 'FontSize', 18);
    title(['Subject ', num2str(i), ' L']);
    caxis([0, 2]);

    subplot(2, 3, 3*i-1);
    imagesc(data{i}.right); colorbar;
    ylabel('neuron');
    xlabel('location');
    set(gca, 'xticklabel', {'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3', '4', '5', '6'}, 'FontSize', 18);
    title(['Subject ', num2str(i), ' R']);
    caxis([0, 2]);
end

%%
% Project [L, R] to PCA space.
NumComponents = 3;
for p_i = 1:length(data)
    [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(data{p_i}, NumComponents);
end

%% PCA space
figure;
set(gcf, 'Position', [630 383 875 564]);
for i = 1:length(Q)
    subplot(2, 3, 3*i-2);
    imagesc(proj_Q{i}.left); colorbar;
    ylabel('PC');
    xlabel('location');
    set(gca, 'xticklabel', {'A', 'B', 'C'}, 'yticklabel', {'1', '2', '3'}, 'FontSize', 18);
    title(['Subject ', num2str(i), ' L']);
    caxis([0, 2]);

    subplot(2, 3, 3*i-1);
    imagesc(proj_Q{i}.right); colorbar;
    ylabel('PC');
    xlabel('location');
    set(gca, 'xticklabel', {'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3'}, 'FontSize', 18);
    title(['Subject ', num2str(i), ' R']);
    caxis([0, 2]);
end

%% Common space
% hyper_input = {proj_Q{1}, proj_Q{2}};
hyper_input = {data{1}, data{2}};

% data_R_wh = data{2};
% data_R_wh.right = zeros(size(data_R_wh.right));
% hyper_input = {data{1}, data_R_wh};

% hyper_input = {data{1}.left, data{2}.left};
[aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);

% w_len = size(data{1}.left, 2);
% [~, aligned{2}, transforms{2}] = procrustes([data{1}.left, data{1}.right]', [data_R_wh.left, data_R_wh.right]', 'scaling', false);
% aligned{2} = aligned{2}';
% aligned_left{1} = data{1}.left;
% aligned_right{1} = data{1}.right;
% aligned_left{2} = aligned{2}(:, 1:w_len);
% aligned_right{2} = aligned{2}(:, w_len+1:end);

% Aligning only left
% aligned_left_only{1} = data{1}.left;
% [~, aligned_left_only{2}, transform] = procrustes(data{1}.left', data{2}.left', 'scaling', false);
% aligned_left_only{2} = aligned_left_only{2}';
% [aligned_left_only, transforms] = hyperalign(hyper_input{:});

% aligned_left_sr = data{1}.left;
% aligned_right_sr = data{1}.right;

% aligned_left_sr = aligned_left_only{1};
% aligned_right_sr = p_transform(transforms{1}, data{1}.right);

[~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
% [~, ~, M] = procrustes(aligned_right_sr', aligned_left_sr', 'scaling', false);

predicted_aligned = p_transform(M, aligned_left{2});
% predicted_aligned = p_transform(M, aligned_left_only{2});

figure;
set(gcf, 'Position', [630 383 875 564]);
for i = 1:length(Q)
    subplot(2, 3, 3*i-2);
%     imagesc(aligned_left_only{i}); colorbar;
    imagesc(aligned_left{i}); colorbar;
    ylabel('neuron');
    xlabel('location');
    set(gca, 'xticklabel', {'A', 'B', 'C'}, 'yticklabel', {'1', '2', '3'}, 'FontSize', 18);
    title(['Subject ', num2str(i), ' Common L']);
    caxis([0, 2]);

    subplot(2, 3, 3*i-1);
%     if i == 1
%         imagesc(aligned_right_sr); colorbar;
%     else
%         imagesc(zeros(size(predicted_aligned))); colorbar;
%     end
    imagesc(aligned_right{i}); colorbar;
    ylabel('neuron');
    xlabel('location');
    set(gca, 'xticklabel', {'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3'}, 'FontSize', 18);
    title(['Subject ', num2str(i), ' Common R']);
    caxis([0, 2]);
end

subplot(2, 3, 6);
imagesc(predicted_aligned); colorbar;
caxis([0, 2]);
ylabel('neuron');
xlabel('location');
set(gca, 'xticklabel', {'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3', '4'}, 'FontSize', 18);
title('Common Predicted R');

%%
w_len = size(aligned_left{2}, 2);

% project_back_pca = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);
% project_back_Q = eigvecs{2} * project_back_pca + pca_mean{2};

project_back_Q = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);

pro_Q_right = project_back_Q(:, w_len+1:end);

% pro_Q_right = inv_p_transform(transforms{2}, predicted_aligned);

subplot(2, 3, 6);
imagesc(pro_Q_right); colorbar;
caxis([0, 2]);
ylabel('neuron');
xlabel('location');
set(gca, 'xticklabel', {'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3', '4', '5', '6'}, 'FontSize', 18);
title('Predicted R');

%% Check mapping of subject 2's transform matrix
figure;
set(gcf, 'Position', [560 1 1121 946]);
for i = 1:size(data{2}.left, 1)
    data_concat = [data{2}.left, data{2}.right];
    neuron_checked = zeros(size(data_concat));
    neuron_checked(i, :) = data_concat(i, :);
    neuron_aligned = p_transform(transforms{2}, neuron_checked);
    
    subplot(3, 4, 2*i-1)
    imagesc(neuron_checked);
    caxis([0, 2]);
    ylabel('neuron');
    xlabel('location');
    set(gca, 'xticklabel', {'A', 'B', 'C', 'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3', '4', '5', '6'});
    title(['Neuron ', num2str(i), ' Raw']);

    subplot(3, 4, 2*i)
    imagesc(neuron_aligned);
    caxis([0, 2]);
    set(gca, 'xticklabel', {'A', 'B', 'C', 'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3', '4', '5', '6'});
    title(['Neuron ', num2str(i), ' Common']);
end

%% cell-by-cell and PV correlations
cell_coefs = calculate_cell_coefs(Q);
PV_coefs = calculate_PV_coefs(Q);
off_diag_PV_coef = get_off_dig_PV(PV_coefs);

%%
function random_matrix = create_random_input(n_cells)
random_matrix = zeros(n_cells, 3);
for i = 1:n_cells
    prob = rand();
    if prob < 1/3
        random_matrix(i, :) = [1 0 0];
    elseif prob < 2/3
        random_matrix(i, :) = [0 1 0];
    else
        random_matrix(i, :) = [0 0 1];
    end
end
end