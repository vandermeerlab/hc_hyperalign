function remove_idx = get_interneuron_idx(cfg_in)
% get_interneuron_idx - Returns a cell array in which each cell contains interneruon indices of that sessions.
%
% Syntax: remove_idx = get_interneuron_idx()
    cfg_def.use_adr_data = 0;
    
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);
    
    if cfg.use_adr_data
        remove_idx = cell(1, 14);
        remove_idx{6} = [45];
        remove_idx{10} = [2, 19];
        remove_idx{11} = [11, 24, 55];
        remove_idx{12} = [58];
        remove_idx{13} = [47, 83];
        remove_idx{14} = [8];
    else
        remove_idx = cell(1, 19);
        remove_idx{1} = [5, 17, 55, 68];
        remove_idx{2} = [70];
        remove_idx{3} = [6, 27, 47, 52];
        remove_idx{4} = [2, 15, 48, 68];
        remove_idx{5} = [1, 21, 40, 58];
        remove_idx{6} = [24, 33];
        remove_idx{7} = [26, 34];
        remove_idx{8} = [58];
        remove_idx{9} = [66, 87];
        remove_idx{11} = [3, 4];
        remove_idx{14} = [18, 83, 104];
        remove_idx{15} = [20, 27, 121, 134];
        remove_idx{16} = [20, 21, 106];
        remove_idx{17} = [16, 162];
        remove_idx{18} = [30, 44, 57, 155];
        remove_idx{19} = [13, 22, 26, 59, 139];
    end
end
