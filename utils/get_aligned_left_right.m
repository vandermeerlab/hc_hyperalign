function [aligned_left, aligned_right, transforms, T_left, T_right] = get_aligned_left_right(pre_aligned)
    % Hyperalignment
    for i = 1:length(pre_aligned)
        hyper_input{i} = [pre_aligned{i}.left, pre_aligned{i}.right];
    end
    [aligned, transforms, template] = hyperalign(hyper_input{:});
    w_len = size(pre_aligned{1}.left, 2);
    aligned_left = cellfun(@(x) x(:, 1:w_len), aligned, 'UniformOutput', false);
    aligned_right = cellfun(@(x) x(:, w_len+1:end), aligned, 'UniformOutput', false);
    
    T_left = template(:, 1:w_len);
    T_right = template(:, w_len+1:end);
end
