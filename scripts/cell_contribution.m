rng(mean('hyperalignment'));

colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();
n_subjs = length(sub_ids.start.carey);
%% Comparing low-firing neurons excluded first vs. high-firing.
cross_subjs_pairs = set_withsubj_nan([], zeros(length(Q), length(Q)));
% ascending: low-firing neurons excluded first
percent_cells = 0.05:0.05:1;
low_first_error = zeros(1, length(percent_cells));
% descending: high-firing neurons excluded first
high_first_error = zeros(1, length(percent_cells));

for sr_i = 1:length(Q)
    keep_idx = mean([Q{sr_i}.left, Q{sr_i}.right], 2) >= 0.01;
    Q_sr.left = Q{sr_i}.left(keep_idx, :); Q_sr.right = Q{sr_i}.right(keep_idx, :);
    [~, sorted_idx] = sort(mean([Q_sr.left, Q_sr.right], 2));
    ascend_idx = sorted_idx;
    descend_idx = sorted_idx(end:-1:1);
    max_excluded_cells = size(Q_sr.left, 1) - 10;
    
    for tar_i = 1:length(Q)
        if ~isnan(cross_subjs_pairs(sr_i, tar_i))
            delta_error = zeros(2, length(percent_cells));
            [actual_dists_mat] = predict_with_L_R([], {Q_sr, Q{tar_i}});
            actual_error = actual_dists_mat(1, 2);
            
            for pc_i = 1:length(percent_cells)
                n_ex_cells = round(percent_cells(pc_i) * max_excluded_cells);
                for or_i = 1:2
                    if or_i == 1
                        ex_idx = ascend_idx;
                    else
                        ex_idx = descend_idx;
                    end
                    Q_ex.left = Q_sr.left(ex_idx(n_ex_cells+1:end), :);
                    Q_ex.right = Q_sr.right(ex_idx(n_ex_cells+1:end), :);
                    Q_pair = {Q_ex, Q{tar_i}};
                    [actual_dists_mat_ex] = predict_with_L_R([], Q_pair);
                    delta_error(or_i, pc_i) = (actual_dists_mat_ex(1, 2) - actual_error) / actual_error;
                end
            end
            low_first_error = [low_first_error; delta_error(1, :)];
            high_first_error = [high_first_error; delta_error(2, :)];
        end
    end
end

%% Plotting
lf_error_percent = low_first_error * 100;
hf_error_percent = high_first_error * 100;
errorbar(percent_cells * 100, nanmean(lf_error_percent, 1), nanstd(lf_error_percent, 1) / sqrt(n_subjs*(n_subjs-1)));
hold on;
errorbar(percent_cells * 100, nanmean(hf_error_percent, 1), nanstd(hf_error_percent, 1) / sqrt(n_subjs*(n_subjs-1)));
xlabel('Percentage of cells excluded'); ylabel('Delta prediction error (pencentage)');
legend({'Low-firing neurons excluded first', 'High-firing neurons excluded first'});
set(gca, 'FontSize', 16, 'XLim', [0, 105]);

%% Comparing low-firing neurons excluded first vs. high-firing (precentage of cells).
cross_subjs_pairs = set_withsubj_nan([], zeros(length(Q), length(Q)));
% ascending: low-firing neurons excluded first
percent_cells = 0.05:0.05:1;
low_first_error = zeros(1, length(percent_cells));
% descending: high-firing neurons excluded first
high_first_error = zeros(1, length(percent_cells));

for sr_i = 1:length(Q)
    keep_idx = mean([Q{sr_i}.left, Q{sr_i}.right], 2) >= 0.01;
    Q_sr.left = Q{sr_i}.left(keep_idx, :); Q_sr.right = Q{sr_i}.right(keep_idx, :);
    [~, sorted_idx] = sort(mean([Q_sr.left, Q_sr.right], 2));
    ascend_idx = sorted_idx;
    descend_idx = sorted_idx(end:-1:1);
    max_excluded_cells = size(Q_sr.left, 1) - 10;
    
    for tar_i = 1:length(Q)
        if ~isnan(cross_subjs_pairs(sr_i, tar_i))
            delta_error = zeros(2, length(percent_cells));
            [actual_dists_mat] = predict_with_L_R([], {Q_sr, Q{tar_i}});
            actual_error = actual_dists_mat(1, 2);
            
            for pc_i = 1:length(percent_cells)
                n_ex_cells = round(percent_cells(pc_i) * max_excluded_cells);
                for or_i = 1:2
                    if or_i == 1
                        ex_idx = ascend_idx;
                    else
                        ex_idx = descend_idx;
                    end
                    Q_ex.left = Q_sr.left(ex_idx(n_ex_cells+1:end), :);
                    Q_ex.right = Q_sr.right(ex_idx(n_ex_cells+1:end), :);
                    Q_pair = {Q_ex, Q{tar_i}};
                    [actual_dists_mat_ex] = predict_with_L_R([], Q_pair);
                    delta_error(or_i, pc_i) = (actual_dists_mat_ex(1, 2) - actual_error) / actual_error;
                end
            end
            low_first_error = [low_first_error; delta_error(1, :)];
            high_first_error = [high_first_error; delta_error(2, :)];
        end
    end
end

%% Plotting (precentage of cells)
lf_error_percent = low_first_error * 100;
hf_error_percent = high_first_error * 100;
errorbar(percent_cells * 100, nanmean(lf_error_percent, 1), nanstd(lf_error_percent, 1) / sqrt(n_subjs*(n_subjs-1)));
hold on;
errorbar(percent_cells * 100, nanmean(hf_error_percent, 1), nanstd(hf_error_percent, 1) / sqrt(n_subjs*(n_subjs-1)));
xlabel('Percentage of cells excluded'); ylabel('Delta prediction error (pencentage)');
legend({'Low-firing neurons excluded first', 'High-firing neurons excluded first'});
set(gca, 'FontSize', 16, 'XLim', [0, 105]);
