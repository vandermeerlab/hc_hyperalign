%%
cfg.use_adr_data = 0;
int_idx_carey = get_interneuron_idx(cfg);
data_paths_carey = getTmazeDataPath([]);

py_mean_FR_carey = [];
int_mean_FR_carey = [];
for p_i = 1:length(data_paths_carey)
    cd(data_paths_carey{p_i});
    cfg_spikes = {};
    cfg_spikes.load_questionable_cells = 1;
    S = LoadSpikes(cfg_spikes);
    lfp = LoadCSC([]);

    % use LFP to calculate true experiment time -- need this because of
    % possible gaps in recording, so can't just take first and last spike
    lfp_dt = median(diff(lfp.tvec));
    total_exp_time = length(lfp.tvec).*lfp_dt;

    nCells = length(S.t);
    this_fr = zeros(nCells, 1);
    for iC = 1:nCells

        this_t = S.t{iC};
        this_fr(iC) = length(this_t)./total_exp_time;

    end
    py_idx = setdiff(1:nCells, int_idx_carey{p_i});
    py_mean_FR_carey = vertcat(py_mean_FR_carey, this_fr(py_idx));
    int_mean_FR_carey = vertcat(int_mean_FR_carey, this_fr(int_idx_carey{p_i}));
end

pyramidal_mean_FR = [];
inter_mean_FR = [];
for i = 1:length(Q)
    Q_pyramidal = [Q{i}.left, Q{i}.right];
    Q_pyramidal(int_idx_carey{i}, :) = [];
    pyramidal_mean_FR = vertcat(pyramidal_mean_FR, mean(Q_pyramidal, 2));

    Q_inter = [Q{i}.left, Q{i}.right];
    Q_inter = Q_inter(int_idx_carey{i}, :);
    inter_mean_FR = vertcat(inter_mean_FR, mean(Q_inter, 2));
end

subplot(1, 2, 1)
histogram(py_mean_FR_carey, 'BinWidth', 1);
hold on;
histogram(int_mean_FR_carey, 'BinWidth', 1);
set(gca, 'YLim', [0, 100]);
legend('Pyramidal', 'Interneurons');
title('Mean firing rates of (putative) cells in Carey using whole session');

subplot(1, 2, 2)
histogram(pyramidal_mean_FR, 'BinWidth', 0.1);
hold on;
histogram(inter_mean_FR, 'BinWidth', 0.1);
set(gca, 'YLim', [0, 100]);
legend('Pyramidal', 'Interneurons');
title('Mean firing rates of (putative) cells in Carey using Q');

%%
cfg.use_adr_data = 1;
int_idx_adr = get_interneuron_idx(cfg);
data_paths_adr = getAdrDataPath(cfg);

py_mean_FR_adr = [];
int_mean_FR_adr = [];
for p_i = 1:length(data_paths_adr)
    cd(data_paths_adr{p_i});

    S = LoadSpikes([]);

    channels = FindFiles('*.Ncs');
    cfg_lfp = {};
    cfg_lfp.fc = {channels{1}};
    lfp = LoadCSC(cfg_lfp);

    % use LFP to calculate true experiment time -- need this because of
    % possible gaps in recording, so can't just take first and last spike
    lfp_dt = median(diff(lfp.tvec));
    total_exp_time = length(lfp.tvec).*lfp_dt;

    nCells = length(S.t);
    this_fr = zeros(nCells, 1);
    for iC = 1:nCells

        this_t = S.t{iC};
        this_fr(iC) = length(this_t)./total_exp_time;

    end
    py_idx = setdiff(1:nCells, int_idx_adr{p_i});
    py_mean_FR_adr = vertcat(py_mean_FR_adr, this_fr(py_idx));
    int_mean_FR_adr = vertcat(int_mean_FR_adr, this_fr(int_idx_adr{p_i}));
end

pyramidal_mean_FR = [];
inter_mean_FR = [];
for i = 1:length(adr_Q)
    Q_pyramidal = [adr_Q{i}.left, adr_Q{i}.right];
    Q_pyramidal(int_idx_adr{i}, :) = [];
    pyramidal_mean_FR = vertcat(pyramidal_mean_FR, mean(Q_pyramidal, 2));

    Q_inter = [adr_Q{i}.left, adr_Q{i}.right];
    Q_inter = Q_inter(int_idx_adr{i}, :);
    inter_mean_FR = vertcat(inter_mean_FR, mean(Q_inter, 2));
end

subplot(1, 2, 1)
histogram(py_mean_FR_adr, 'BinWidth', 1);
hold on;
histogram(int_mean_FR_adr, 'BinWidth', 1);
set(gca, 'YLim', [0, 100]);
legend('Pyramidal', 'Interneurons');
title('Mean firing rates of (putative) cells in ADR using whole session');

subplot(1, 2, 2)
histogram(pyramidal_mean_FR, 'BinWidth', 0.1);
hold on;
histogram(inter_mean_FR, 'BinWidth', 0.1);
set(gca, 'YLim', [0, 100]);
legend('Pyramidal', 'Interneurons');
title('Mean firing rates of (putative) cells in ADR using Q');
