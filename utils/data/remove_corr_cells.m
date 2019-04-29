function [Q_out] = remove_corr_cells(cfg_in, Q_in)
    % Remove cells that are either significantly positive or negative (or both) correlations between L and R.
    % One of the options: 'none', 'pos_and_neg', 'pos', 'neg'.
    cfg_def.removeCorrelations = 'pos_and_neg';
    cfg_def.removeNaNFiring = true;
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);

    Q_out = Q_in;
    for q_i = 1:length(Q_in)
        remove_idx = [];
        for c_i = 1:size(Q_in{q_i}.left, 1)
            [coef, p] = corrcoef(Q_in{q_i}.left(c_i, :), Q_in{q_i}.right(c_i, :));
            if cfg.removeNaNFiring && isnan(p(1, 2))
                remove_idx = [remove_idx, c_i];
            end
            if ~strcmp(cfg.removeCorrelations, 'none') && p(1, 2) < 0.05
                if strcmp(cfg.removeCorrelations, 'pos_and_neg')
                    remove_idx = [remove_idx, c_i];
                elseif strcmp(cfg.removeCorrelations, 'pos')
                    if coef(1, 2) > 0
                        remove_idx = [remove_idx, c_i];
                    end
                elseif strcmp(cfg.removeCorrelations, 'neg')
                    if coef(1, 2) < 0
                        remove_idx = [remove_idx, c_i];
                    end
                end
            end
        end
        if ~isempty(remove_idx)
            Q_out{q_i}.left(remove_idx, :) = [];
            Q_out{q_i}.right(remove_idx, :) = [];
        end
    end
end
