function fd = getAdrDataPath(cfg_in)
% function fd = getTmazeDataPath(cfg_in)
%
% get list of folders with data to analyze
%
% assumes that data is organized as AllDataFolder > RatFolder >
% SessionFolder, i.e. C:\data\R050\R050-2014-04-03 etc..
%
% CONFIGS
%
% cfg_def.rats = {'R149','R152','R156','R159', 'R169'};
% cfg_def.requireMetadata = 1;
% cfg_def.requireCandidates = 0;
% cfg_def.requireEvents = 0;
% cfg_def.verbose = 1;
% cfg_def.userpath = ''; if specified, uses this path instead of default
%
% OUTPUT
%
% fd: cell array with found data folders
%
% MvdM 2015
% youkitan 2016-11-22 edit: added user input for path

cfg_def.rats = {'R149','R152','R156','R159', 'R169'};
cfg_def.requireMetadata = 1;
cfg_def.requireCandidates = 0;
cfg_def.requireEvents = 0;
cfg_def.verbose = 1;
cfg_def.userpath = '';

mfun = mfilename;
cfg = ProcessConfig(cfg_def,cfg_in,mfun);

if ispc
    machinename = getenv('COMPUTERNAME');
    filesep = '\';
elseif ismac
    machinename = getenv('USER');
    filesep = '/';
else
    machinename = getenv('HOSTNAME');
    filesep = '/';
end

% overide default if user specifies path for data folder
if ~isempty(cfg.userpath)
    machinename = 'USERDEFINED';
end

switch machinename

    case {'ISIDRO','MVDMLAB-PERSEUS','ODYSSEUS', 'PROMETHEUS'}
        base_fp = 'C:\data\Adrlab';
    case {'EQUINOX','BERGKAMP'}
        base_fp = 'D:\data\';
    case 'MVDMLAB-ATHENA'
        base_fp = 'D:\vandermeerlab\';
    case {'MVDMLAB-EUROPA','DIONYSUS'}
        base_fp = 'D:\data\promoted\';
    case 'CALLISTO'
        base_fp = 'E:\data\promoted\';
    case 'mac'
        base_fp = '/Users/mac/Box Sync/Data/Adrlab/';
    case 'USERDEFINED'
        base_fp = cfg.userpath;
end

fd = {};

curr_pwd = pwd;

for iRat = 1:length(cfg.rats)

    cd(base_fp);
    cd(cfg.rats{iRat});

    temp_fd = dir;
    temp_fd = temp_fd(3:end); % remove . and ..
    temp_fd = temp_fd([temp_fd.isdir]); % only consider dirs

    for iFD = 1:length(temp_fd)

        cd(temp_fd(iFD).name);

        if cfg.requireMetadata
           m = FindFiles('*metadata.mat');
           if isempty(m)
               cd ..
               continue;
           end
        end

        if cfg.requireCandidates
           m = FindFiles('*candidates.mat');
           if isempty(m)
               cd ..
               continue;
           end
        end

        if cfg.requireEvents
            m = FindFiles('*.nev');
           if isempty(m)
               cd ..
               continue;
           end
        end
        
        if pass_include_criterion()
            % accept
            fd = cat(1,fd,pwd);
        end
        cd .. % return to rat folder

    end % of session folders

end

cd(curr_pwd) % return to starting folder

end

function [pass] = pass_include_criterion()
    pass = true;
    LoadExpKeys;

    evt = LoadEvents([]);
    % Quick check to remove empty label
    non_empty_idx = ~cellfun(@isempty, evt.label);
    evt.label = evt.label(non_empty_idx);

    % keep only hippocampus cells
    hc_tt = find(strcmp(ExpKeys.Target, 'Hippocampus'));
    if isfield(ExpKeys,'TetrodeTargets')
        hc_tt = find(ExpKeys.TetrodeTargets == hc_tt);
    else
        pass = false;
        fprintf('WARNING: no TetrodeTargets defined\n');
    end

    please = []; please.load_questionable_cells = 1; please.getTTnumbers = 1;
    S = LoadSpikes(please);

    keep_idx = ismember(S.usr.tt_num, hc_tt);
    S = SelectTS([], S, keep_idx);
    
    min_trial_len = 1; % in seconds, used to remove multiple feeder fires
    if isfield(ExpKeys,'FeederL1') % feeder IDs defined, use them

        feeders = cat(2, ExpKeys.FeederL1, ExpKeys.FeederR1);
        feeder_labels = {'L', 'R'};
        reward_t = [];
        ll = @(x) x(end); % function to get last character of input
        for iF = 1:length(feeders)
            keep_idx = find(num2str(feeders(iF)) == cellfun(ll, evt.label));
            % Check if no L or R trial at all.
            if isempty(keep_idx)
                pass = false;
            else
                reward_t.(feeder_labels{iF}) = evt.t{keep_idx};
                % remove multiple feeder fires
                ifi = cat(2, Inf, diff(reward_t.(feeder_labels{iF})));
                reward_t.(feeder_labels{iF}) = reward_t.(feeder_labels{iF})(ifi >= min_trial_len);
                % Exclude current session if # of L or R trials < 5.
                if length(reward_t.(feeder_labels{iF})) < 5
                    pass = false;
                end
                % Exclude current session if # of cells < 40;
                if length(S.t) < 40
                    pass = false;
                end
            end
        end

    else
        error('no left/right feeder IDs defined');
    end
end
