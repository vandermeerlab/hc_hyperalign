function [aligned_left, aligned_right, transforms] = get_aligned_left_right(pre_aligned)
    % Hyperalignment
    for i = 1:length(pre_aligned)
        hyper_input{i} = [pre_aligned{i}.left, pre_aligned{i}.right];
    end
    [aligned, transforms] = hyperalign(hyper_input{:});
    w_len = size(pre_aligned{1}.left, 2);
    aligned_left = cellfun(@(x) x(:, 1:w_len), aligned, 'UniformOutput', false);
    aligned_right = cellfun(@(x) x(:, w_len+1:end), aligned, 'UniformOutput', false);
end
