function [m_coefs_types, sem_coefs_types] = plot_off_diag_PV(cfg_in, off_diag_coefs, types)
    % Plot Population Vector analysis
    cfg_def = [];
    cfg_def.fs = 12;
    cfg_def.ax = []; % handle to axes to plot in, e.g. ax = subplot(221)
    cfg_def.dy = 0.1;

    cfg = ProcessConfig(cfg_def, cfg_in);

    if ~isempty(cfg.ax)
        axes(cfg.ax);
    else
        cfg.ax = gca;
    end

    m_coefs_types = zeros(length(off_diag_coefs), 1);
    sem_coefs_types = zeros(length(off_diag_coefs), 1);

    for d_i = 1:length(off_diag_coefs)
        m_coefs_types(d_i) = nanmedian(off_diag_coefs{d_i}(:));
        sem_coefs_types(d_i) = nanstd(off_diag_coefs{d_i}(:)) / sqrt(cfg.num_subjs(d_i));
    end

    dx = 0.1;
    x = dx * (1:length(off_diag_coefs));
    xpad = 0.05;
    h = errorbar(x, m_coefs_types, sem_coefs_types, 'LineStyle', 'none', 'LineWidth', 2);
    set(h, 'Color', 'k');
    hold on;
    plot(x, m_coefs_types, '.k', 'MarkerSize', 20);
    set(gca, 'XTick', x, 'YTick', [cfg.ylim(1):cfg.dy:cfg.ylim(2)], 'XTickLabel', types, ...
        'XLim', [x(1)-xpad x(end)+xpad], 'YLim', [cfg.ylim(1) cfg.ylim(2)], 'FontSize', cfg.fs, ...
        'LineWidth', 1, 'TickDir', 'out');
    box off;
    plot([x(1)-xpad x(end)+xpad], [0 0], '--k', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);

end
