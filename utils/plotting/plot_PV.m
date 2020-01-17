function [mean_coefs] = plot_PV(cfg_in, coefs)
    % Plot Population Vector analysis
    cfg_def = [];
    cfg_def.fs = 12;
    cfg_def.ax = []; % handle to axes to plot in, e.g. ax = subplot(221)
    cfg_def.clim = [];

    cfg = ProcessConfig(cfg_def, cfg_in);

    if ~isempty(cfg.ax)
        axes(cfg.ax);
    else
        cfg.ax = gca;
    end

    mean_coefs = mean(cat(3, coefs{:}), 3);
    imagesc(mean_coefs);
    colorbar;
    if ~isempty(cfg.clim)
        caxis(cfg.clim);
    end

    cb = colorbar;
    cb.Box = 'off';
    cb.Ticks = cfg.clim;
    set(cfg.ax, 'xticklabel', [], 'yticklabel', [], 'FontSize', cfg.fs, 'LineWidth', 1, 'TickDir', 'out');
    axis(cfg.ax, 'off'); cfg.ax.XLabel.Visible = 'on'; cfg.ax.YLabel.Visible = 'on';

end
