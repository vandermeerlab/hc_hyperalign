function plot_PV(cfg_in, data)
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

    data = cellfun(@(x) [x.left, x.right], data, 'UniformOutput', false);
    coefs = cell(1, length(data));
    w_len = size(data{1}, 2);
    for i = 1:length(data)
        w_coefs = zeros(w_len, w_len);
        for j = 1:w_len
            for k = 1:w_len
                [coef] = corrcoef(data{i}(:, j), data{i}(:, k));
                w_coefs(j, k) = coef(1, 2);
            end
        end
        coefs{i} = w_coefs;
    end

    mean_coefs = mean(cat(3, coefs{:}), 3);
    imagesc(mean_coefs);
    colorbar;
    if ~isempty(cfg.clim)
        caxis(cfg.clim);
    end
    
    cb = colorbar;
    cb.Box = 'off';
%     cb.Ticks = [];
    set(cfg.ax, 'xticklabel', [], 'yticklabel', [], 'FontSize', cfg.fs, 'LineWidth', 1, 'TickDir', 'out');
    axis(cfg.ax, 'off'); cfg.ax.XLabel.Visible = 'on'; cfg.ax.YLabel.Visible = 'on';
    
end
