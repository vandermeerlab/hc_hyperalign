rng(mean('hyperalignment'));
A = [2 0 0; 0 2 0; 1 0 0; 0 1 0];
B = [0 0 2; 2 0 0; 0 1 0; 0 0 1];

shuffle_idx = randperm(size(A, 1));
C = A(shuffle_idx, :);
D = B(shuffle_idx, :);

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
set(gcf, 'Position', [288 173 1355 784]);
for i = 1:length(Q)
    subplot(2, 3, 3*i-2);
    imagesc(data{i}.left); colorbar;
    ylabel('neuron');
    xlabel('location');
    set(gca, 'xticklabel', {'A', 'B', 'C'}, 'yticklabel', {'1', '2', '3', '4'}, 'FontSize', 18);
    title(['Subject ', num2str(i), ' L']);

    subplot(2, 3, 3*i-1);
    imagesc(data{i}.right); colorbar;
    ylabel('neuron');
    xlabel('location');
    set(gca, 'xticklabel', {'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3', '4'}, 'FontSize', 18);
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
set(gca, 'xticklabel', {'D', 'E', 'F'}, 'yticklabel', {'1', '2', '3', '4'}, 'FontSize', 18);
title('Predicted R');