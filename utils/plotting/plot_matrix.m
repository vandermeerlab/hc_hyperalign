function plot_matrix(cfg_in, data)
% plots data matrices in first row of figure

    cfg_def = [];
    cfg_def.title = [];
    cfg_def.fs = 12;
    cfg_def.ax = []; % handle to axes to plot in, e.g. ax = subplot(221)
    cfg_def.clim = [];

    cfg = ProcessConfig(cfg_def, cfg_in);

    if ~isempty(cfg.ax)
        axes(cfg.ax);
    else
        cfg.ax = gca;
    end

    imagesc(data, 'AlphaData', ~isnan(data));

    if ~isempty(cfg.clim)
        caxis(cfg.clim);
    end

    cb = colorbar;
    cb.Box = 'off';
    cb.Ticks = [];

    ylabel('source');
    xlabel('target');

    set(cfg.ax, 'xticklabel', [], 'yticklabel', [], 'FontSize', cfg.fs, 'LineWidth', 1, 'TickDir', 'out');
    axis(cfg.ax, 'off'); cfg.ax.XLabel.Visible = 'on'; cfg.ax.YLabel.Visible = 'on';

    title(cfg.title);

end % of function
