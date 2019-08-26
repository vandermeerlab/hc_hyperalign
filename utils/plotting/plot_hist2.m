function plot_hist2(cfg_in, data)
    % plots dual histograms

    cfg_def = [];
    cfg_def.fs = 12;
    cfg_def.ax = []; % handle to axes to plot in, e.g. ax = subplot(221)
    cfg_def.indicate_zero = 1;

    cfg = ProcessConfig(cfg_def, cfg_in);

    if ~isempty(cfg.ax)
        axes(cfg.ax);
    else
        cfg.ax = gca;
    end

    hist_xe = cfg.xlim(1):cfg.binsize:cfg.xlim(2); % edges for histogram
    hist_xc = hist_xe(1:end-1) + cfg.binsize / 2; % centers

    for iData = 1:length(data)
        hist_y{iData} = histc(data{iData}(:), hist_xe); hist_y{iData} = hist_y{iData}(1:end-1);
    end

    if length(data) == 1
        hdl = bar(hist_xc, hist_y{1}, 'FaceColor', cfg.hist_colors{1}, 'FaceAlpha', 0.8, 'EdgeColor', 'none');
    else
        hdl = bar(hist_xc, [hist_y{1} hist_y{2}], 'grouped');
        set(hdl(1), 'FaceColor', cfg.hist_colors{1}, 'EdgeColor', 'none');
        set(hdl(2), 'FaceColor', cfg.hist_colors{2}, 'EdgeColor', 'none');
    end

    hold on;

    % do some curve/kernel fitting
    df = 0.001;
    fit_x = cfg.xlim(1):df:cfg.xlim(2);
    what = {'HT', 'pca'};
    for iData = 1:length(data)

        this_data = data{iData}(:);
        area = length(this_data) * cfg.binsize;
        xm = nanmean(this_data); xs = nanstd(this_data);

        switch cfg.fit
            case 'gauss'
                f = normpdf(fit_x, xm, xs);
                plot(fit_x, area*f, 'Color', cfg.fit_colors{iData});

                ym = interp1(fit_x, area*f, xm);
                plot(xm, ym, '.', 'MarkerSize', 10, 'Color', cfg.fit_colors{iData});

            case 'kernel'
                f = ksdensity(this_data, fit_x);
                plot(fit_x, area*f, 'Color', cfg.fit_colors{iData});

            case 'vline'
                vh = vline(xm, '-'); set(vh, 'Color', cfg.fit_colors{iData});
        end

        if cfg.indicate_zero
            vh = vline(0, 'k--');
        end

    end

    % global plot settings
    box off;
    set(gca, 'FontSize', cfg.fs, 'TickDir', 'out', 'YTick', [], 'XTick', cfg.xtick, 'XLim', [cfg.xlim(1) cfg.xlim(2)]);
    xtl = make_ticklabels(cfg, cfg.xtick);
    set(gca, 'XTickLabel', xtl);

end
