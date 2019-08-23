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
