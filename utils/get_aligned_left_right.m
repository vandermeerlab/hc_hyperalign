function [aligned_left, aligned_right, transforms] = get_aligned_left_right(pre_aligned)
    % Hyperalignment
    for i = 1:length(pre_aligned.left)
        hyper_input{i} = [pre_aligned.left{i}, pre_aligned.right{i}];
    end
    [aligned, transforms] = hyperalign(hyper_input{:});
    w_len = size(pre_aligned.left{1}, 2);
    aligned_left = cellfun(@(x) x(:, 1:w_len), aligned, 'UniformOutput', false);
    aligned_right = cellfun(@(x) x(:, w_len+1:end), aligned, 'UniformOutput', false);
end
