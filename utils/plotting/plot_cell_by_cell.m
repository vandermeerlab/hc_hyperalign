function [mean_coefs_types, sem_coefs_types, all_coefs_types] = plot_cell_by_cell(cfg_in, datas, themes)
    % Plot cell-by-cell correlation across subjects
    cfg_def = [];
    cfg_def.fs = 12;
    cfg_def.ax = []; % handle to axes to plot in, e.g. ax = subplot(221)

    cfg = ProcessConfig(cfg_def, cfg_in);

    if ~isempty(cfg.ax)
        axes(cfg.ax);
    else
        cfg.ax = gca;
    end
    
    rng(mean('hyperalignment'));
    mean_coefs_types = zeros(length(datas), 1);
    sem_coefs_types = zeros(length(datas), 1);
    all_coefs_types = cell(length(datas), 1);

    for d_i = 1:length(datas)
        data = datas{d_i};
        
        cell_coefs = [];
        for i = 1:length(data)
            whiten_left = data{i}.left + 0.00001 * rand(size(data{i}.left));
            whiten_right = data{i}.right + 0.00001 * rand(size(data{i}.right));

            for j = 1:size(whiten_left, 1)
                [coef] = corrcoef(whiten_left(j, :), whiten_right(j, :));
                cell_coefs = [cell_coefs, coef(1, 2)];
            end
        end

        mean_coefs_types(d_i) = nanmean(cell_coefs);
        sem_coefs_types(d_i) = nanstd(cell_coefs) / sqrt(cfg.num_subjs(d_i));
        all_coefs_types{d_i} = cell_coefs;
    end

    dx = 0.1;
    x = dx * (1:length(datas));
    xpad = 0.05;
    h = errorbar(x, mean_coefs_types, sem_coefs_types, 'LineStyle', 'none', 'LineWidth', 2);
    set(h, 'Color', 'k');
    hold on;
    plot(x, mean_coefs_types, '.k', 'MarkerSize', 20);
    set(gca, 'XTick', x, 'YTick', [cfg.ylim(1):dx:cfg.ylim(2)], 'XTickLabel', themes, ...
        'XLim', [x(1)-xpad x(end)+xpad], 'YLim', [cfg.ylim(1) cfg.ylim(2)], 'FontSize', cfg.fs, ...
        'LineWidth', 1, 'TickDir', 'out');
    box off;
    plot([x(1)-xpad x(end)+xpad], [0 0], '--k', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);

end
