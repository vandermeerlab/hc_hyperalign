for i = 1:3
    x.left{i} = eye(3);
    x.right{i} = eye(3);
end

for i = 1:3
    hyper_input{i} = [x.left{i}, x.right{i}];
end
[aligned, transforms] = hyperalign(hyper_input{1:3});

aligned_left = cellfun(@(x) x(1:3), aligned, 'UniformOutput', false);
aligned_right = cellfun(@(x) x(4:6), aligned, 'UniformOutput', false);

[~, ~, M{1}] = procrustes(aligned_right{1}', aligned_left{1}');
predicted_R = cellfun(@(x) p_transform(M{1}, x), aligned_left, 'UniformOutput', false);

for i = 1:3
    dist{i} = calculate_dist(predicted_R{i}, aligned_right{i});
end

rand_dists  = cell(1, 3);
for i = 1:100
    for j = 1:3
        shuffle_indices{j} = randperm(3);
        shuffle_right{j} = x.right{j}(shuffle_indices{j}, :);
    end
    for h_i = 1:3
        s_hyper_input{h_i} = [x.left{h_i}, shuffle_right{h_i}];
    end
    [s_aligned, s_transforms] = hyperalign(s_hyper_input{1:3});

    s_aligned_left = cellfun(@(x) x(1:3), s_aligned, 'UniformOutput', false);
    s_aligned_right = cellfun(@(x) x(4:6), s_aligned, 'UniformOutput', false);
    
    [~, ~, shuffle_M{1}] = procrustes(s_aligned_right{1}', s_aligned_left{1}');
    s_predicted_R = cellfun(@(x) p_transform(shuffle_M{1}, x), s_aligned_left, 'UniformOutput', false);
    
    for k = 1:3
        rand_dists{k} = [rand_dists{k}, calculate_dist(s_predicted_R{k}, s_aligned_right{k})];
    end
end

for i = 1:3
    subplot(3, 1, i)
    histogram(rand_dists{i})
    line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r');
end