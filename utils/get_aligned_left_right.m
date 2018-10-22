function [aligned_left, aligned_right] = get_aligned_left_right(mean_proj)
    % Hyperalignment
    for i = 1:length(mean_proj.left)
        hyper_input{i} = [mean_proj.left{i}, mean_proj.right{i}];
    end
    [aligned, transforms] = hyperalign(hyper_input{:});
    w_len = size(mean_proj.left{1}, 2);
    aligned_left = cellfun(@(x) x(:, 1:w_len), aligned, 'UniformOutput', false);
    aligned_right = cellfun(@(x) x(:, w_len+1:end), aligned, 'UniformOutput', false);
end
