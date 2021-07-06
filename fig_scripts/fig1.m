rng(mean('hyperalignment'));
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
%%
% Project [L, R] to PCA space.
NumComponents = 2;
for p_i = 1:length(data)
    [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(data{p_i}, NumComponents);
end

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

    subplot(2, 3, 3*i-1);
    imagesc(data{i}.right); colorbar;
    ylabel('neuron');
    xlabel('location');
    set(gca, 'xticklabel', {'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3', '4', '5', '6'}, 'FontSize', 18);
    title(['Subject ', num2str(i), ' R']);
end

%% Common space
% hyper_input = {proj_Q{1}, proj_Q{2}};
hyper_input = {data{1}, data{2}};

[aligned_left, aligned_right, transforms] = get_aligned_left_right(hyper_input);
[~, ~, M] = procrustes(aligned_right{1}', aligned_left{1}', 'scaling', false);
predicted_aligned = p_transform(M, aligned_left{2});

%%
w_len = size(aligned_left{2}, 2);

% project_back_pca = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);
% project_back_Q = eigvecs{2} * project_back_pca + pca_mean{2};

project_back_Q = inv_p_transform(transforms{2}, [aligned_left{2}, predicted_aligned]);

pro_Q_right = project_back_Q(:, w_len+1:end);

subplot(2, 3, 6);
imagesc(pro_Q_right); colorbar;
caxis([0, 2]);
ylabel('neuron');
xlabel('location');
set(gca, 'xticklabel', {'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3', '4', '5', '6'}, 'FontSize', 18);
title('Predicted R');

%% cell-by-cell and PV correlations
cell_coefs = calculate_cell_coefs(Q);
PV_coefs = calculate_PV_coefs(Q);
off_diag_PV_coef = get_off_dig_PV(PV_coefs);