colors = get_hyper_colors();

%% Hyperalignment procedure
% Carey: 1, ADR: 2;
datas = {Q, adr_Q};
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
    [actual_dists_mat_pca{d_i}, id_dists_mat_pca{d_i}, sf_dists_mat_pca{d_i}] = predict_with_shuffles([], data, @predict_with_L_R_pca);
end

%% Source-target figures in Carey
[z_score, mean_shuffles, proportion] = calculate_common_metrics([], actual_dists_mat{1}, ...
    id_dists_mat{1}, sf_dists_mat{1});

titles = {'HT z-score vs. shuffle', 'HT distance - shuffled dist.', 'p(HT dist. > shuffled dist.)'};

cfg_plot = [];
clims = {[-6 6], [-1000 1000], [0 1]};

matrix_obj = {z_score.out_zscore_mat, mean_shuffles.out_actual_mean_sf, proportion.out_actual_sf_mat};
for m_i = 1:length(matrix_obj)
    this_ax = subplot(3, 3, m_i);
    
    cfg_plot.ax = this_ax;
    cfg_plot.clim = clims{m_i};
    cfg_plot.title = titles{m_i};
    
    plot_matrix(cfg_plot, matrix_obj{m_i});
    
end
set(gcf, 'Position', [316 185 898 721]);

%% Hypertransform and PCA-only in Carey and ADR
% themes = {'Carey', 'ADR'};
x_limits = {[-6.5, 6.5], [-1050, 1050], [0, 1], [-6.5, 6.5], [-1050, 1050], [0, 1]}; % two rows, three columns in figure
x_tick = {-6:6, -1000:250:1000, 0:0.2:1, -6:6, -1000:250:1000, 0:0.2:1};
binsizes = [1, 150, 0.1]; % for histograms

cfg_plot = [];
cfg_plot.colors = colors;

for d_i = 1:length(datas) % one row each for Carey, ADR
    [z_score, mean_shuffles, proportion] = calculate_common_metrics([], actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});
    [z_score_pca, mean_shuffles_pca, proportion_pca] = calculate_common_metrics([], actual_dists_mat_pca{d_i}, ...
        id_dists_mat_pca{d_i}, sf_dists_mat_pca{d_i});

    matrix_objs = {{z_score.out_zscore_mat, z_score_pca.out_zscore_mat}, ...
        {mean_shuffles.out_actual_mean_sf, mean_shuffles_pca.out_actual_mean_sf}, ...
        {proportion.out_actual_sf_mat, proportion_pca.out_actual_sf_mat}};

    for m_i = 1:length(matrix_objs) % loop over columns
        this_ax = subplot(3, 3, (3 * d_i) + m_i);
        p_i = (d_i - 1)*3 + m_i; % plot index to access x_limits etc defined above
        matrix_obj = matrix_objs{m_i};

        cfg_plot.xlim = x_limits{p_i};
        cfg_plot.xtick = x_tick{p_i};
        cfg_plot.binsize = binsizes(m_i);
        cfg_plot.ax = this_ax;
        cfg_plot.insert_zero = 1; % plot zero xtick
        cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)
        if m_i == 3
            cfg_plot.fit = 'none';
            cfg_plot.insert_zero = 0;
        end
        
        plot_hist2(cfg_plot, matrix_obj); % ht, then pca

    end
end

%%
function plot_hist2(cfg_in, data)
% plots dual histograms

cfg_def = [];
cfg_def.fs = 12;
cfg_def.ax = []; % handle to axes to plot in, e.g. ax = subplot(221)

cfg = ProcessConfig(cfg_def, cfg_in);

if ~isempty(cfg.ax)
    axes(cfg.ax);
else
    cfg.ax = gca;
end

hist_xe = cfg.xlim(1):cfg.binsize:cfg.xlim(2); % edges for histogram
hist_xc = hist_xe(1:end-1) + cfg.binsize / 2; % centers

for iData = 1:2
    hist_y{iData} = histc(data{iData}(:), hist_xe); hist_y{iData} = hist_y{iData}(1:end-1);
end

hdl = bar(hist_xc, [hist_y{1} hist_y{2}], 'grouped');
set(hdl(1), 'FaceColor', cfg.colors.HT.hist, 'EdgeColor', 'none');
set(hdl(2), 'FaceColor', cfg.colors.pca.hist, 'EdgeColor', 'none');

hold on;

% do some curve/kernel fitting
df = 0.001;
fit_x = cfg.xlim(1):df:cfg.xlim(2);
what = {'HT', 'pca'};
for iData = 1:2
    
    this_data = data{iData}(:);
    area = length(this_data) * cfg.binsize;
    xm = nanmean(this_data); xs = nanstd(this_data);
    
    switch cfg.fit
        case 'gauss' 
            f = normpdf(fit_x, xm, xs);
            plot(fit_x, area*f, 'Color', cfg.colors.(what{iData}).fit);
            
            ym = interp1(fit_x, area*f, xm);
            plot(xm, ym, '.', 'MarkerSize', 10, 'Color', cfg.colors.(what{iData}).fit);
            
        case 'kernel'
            f = ksdensity(this_data, fit_x);
            plot(fit_x, area*f, 'Color', cfg.colors.(what{iData}).fit);
            
        case 'vline'
            vh = vline(xm, '-'); set(vh, 'Color', cfg.colors.(what{iData}).fit);
            vh = vline(0, 'k--');
    end
    
end

% global plot settings
box off;
set(gca, 'FontSize', cfg.fs, 'TickDir', 'out', 'YTick', [], 'XTick', cfg.xtick, 'XLim', [cfg.xlim(1) cfg.xlim(2)]);
xtl = make_ticklabels(cfg, cfg.xtick);
set(gca, 'XTickLabel', xtl);

end

function tl = make_ticklabels(cfg_in, ticks)

cfg_def = [];
cfg_def.insert_zero = 0;

cfg = ProcessConfig(cfg_def, cfg_in);

tl = cell(size(ticks));
for iT = 1:length(tl)
   tl{iT} = [];
end
tl{1} = ticks(1); tl{end} = ticks(end);

if cfg.insert_zero
   zero_idx = ceil(length(ticks) / 2);
   tl{zero_idx} = 0;
end

end

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