function plot_cell_by_cell(cfg_in, datas, themes)
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

    mean_coefs_types = zeros(length(datas), 1);
    % sem_coefs_types = zeros(length(datas), 1);
    sd_coefs_types = zeros(length(datas), 1);

    for d_i = 1:length(datas)
        data = datas{d_i};
        sub_ids_start = cfg.sub_ids_starts{d_i};
        sub_ids_end = cfg.sub_ids_ends{d_i};
        mean_coefs = zeros(1, length(sub_ids_start));

        for s_i = 1:length(sub_ids_start)
            cell_coefs = [];
            for w_i = sub_ids_start(s_i):sub_ids_end(s_i)
                whiten_left = data{w_i}.left + 0.00001 * rand(size(data{w_i}.left));
                whiten_right = data{w_i}.right + 0.00001 * rand(size(data{w_i}.right));

                for c_i = 1:size(data{w_i}.left, 1)
                    [coef] = corrcoef(whiten_left(c_i, :), whiten_right(c_i, :));
                    cell_coefs = [cell_coefs, coef(1, 2)];
                end
            end
            mean_coefs(s_i) = mean(cell_coefs, 'omitnan');
        end
        mean_coefs_types(d_i) = mean(mean_coefs);
        % sem_coefs_types(d_i) = std(mean_coefs) / sqrt(length(mean_coefs));
        sd_coefs_types(d_i) = std(mean_coefs);
    end

    dx = 0.1;
    x = dx * (1:length(datas));
    xpad = 0.05;
    h = errorbar(x, mean_coefs_types, sd_coefs_types, 'LineStyle', 'none', 'LineWidth', 2);
    set(h, 'Color', 'k');
    hold on;
    plot(x, mean_coefs_types, '.k', 'MarkerSize', 20);
    set(gca, 'XTick', x, 'YTick', [cfg.ylim(1):0.1:cfg.ylim(2)], 'XTickLabel', themes, ...
        'XLim', [x(1)-xpad x(end)+xpad], 'YLim', [cfg.ylim(1) cfg.ylim(2)], 'FontSize', cfg.fs, ...
        'LineWidth', 1, 'TickDir', 'out');
    box off;
    plot([x(1)-xpad x(end)+xpad], [0 0], '--k', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);

end
