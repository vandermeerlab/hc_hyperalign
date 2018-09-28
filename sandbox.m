for i = 1:3
    x.left{i} = eye(3);
    x.right{i} = eye(3);
end

[aligned, transforms] = hyperalign(x.left{1:3}, x.right{1:3});

aligned_left = aligned(1:3);
aligned_right = aligned(4:6);

for i = 1:3
    dist{i} = calculate_dist(aligned_left{i}, aligned_right{i});
end

rand_dists  = cell(1, 3);
for i = 1:100
    for j = 1:3
        shuffle_indices{j} = randperm(3);
        shuffle_right{j} = x.right{j}(shuffle_indices{j}, :);
    end
    [s_aligned, s_transforms] = hyperalign(x.left{1:3}, shuffle_right{1:3});
    s_aligned_left = s_aligned(1:3);
    s_aligned_right = s_aligned(4:6);
    for k = 1:3
        rand_dists{k} = [rand_dists{k}, calculate_dist(s_aligned_left{k}, s_aligned_right{k})];
    end
end

for i = 1:3
    subplot(3, 1, i)
    histogram(rand_dists{i})
    line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r');
end