function [norm_dists_mat] = normalize_errors_per_cell(Q, dists_mat)
% Normalize raw errors by number of cells of target sessions.
norm_dists_mat = nan(size(dists_mat));
for tar_i = 1:length(Q)
    tar_n_cells = size(Q{tar_i}.left, 1);
    for sr_i = 1:length(Q)
        if ~isnan(dists_mat(sr_i, tar_i))
            norm_dists_mat(sr_i, tar_i) = dists_mat(sr_i, tar_i) / tar_n_cells;
        end
    end
end

end