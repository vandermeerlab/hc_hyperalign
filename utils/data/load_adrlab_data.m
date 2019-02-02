LoadExpKeys;

evt = LoadEvents([]);

% keep only hippocampus cells
hc_tt = find(strcmp(ExpKeys.Target, 'Hippocampus'));
hc_tt = find(ExpKeys.TetrodeTargets == hc_tt);

please = []; please.load_questionable_cells = 1; please.getTTnumbers = 1;
S = LoadSpikes(please);

keep_idx = ismember(S.usr.tt_num, hc_tt);
S = SelectTS([], S, keep_idx);

%% find left/right (rewarded) trial times
%keep = ~cellfun('isempty',evt.label); evt = SelectTS([],evt,keep); % may fail with current codebase master, works with striatal-spike-rhythms repo

min_trial_len = 1; % in seconds, used to remove multiple feeder fires
if isfield(ExpKeys,'FeederL1') % feeder IDs defined, use them

    feeders = cat(2, ExpKeys.FeederL1, ExpKeys.FeederR1);
    feeder_labels = {'L', 'R'};
    reward_t = [];
    ll = @(x) x(end); % function to get last character of input
    for iF = 1:length(feeders)

        keep_idx = find(num2str(feeders(iF)) == cellfun(ll, evt.label));
        reward_t.(feeder_labels{iF}) = evt.t{keep_idx};

        % remove multiple feeder fires
        ifi = cat(2, Inf, diff(reward_t.(feeder_labels{iF})));
        reward_t.(feeder_labels{iF}) = reward_t.(feeder_labels{iF})(ifi >= min_trial_len);

    end

else
    error('no left/right feeder IDs defined');
end

%% find the trial order to look like MotivationalT metadata
nL = length(reward_t.L); nR = length(reward_t.R);
left_labels = repmat({'L'}, [1 nL]); right_labels = repmat({'R'}, [1 nR]);
all_labels = cat(2, left_labels, right_labels);
all_times = cat(2, reward_t.L, reward_t.R);

[sorted_reward_times, sort_idx] = sort(all_times, 'ascend');
sequence = all_labels(sort_idx);

%% convert reward times into trial ivs
trial_len = 2.4;

trial_iv_L = iv(reward_t.L - trial_len, reward_t.L);
trial_iv_R = iv(reward_t.R - trial_len, reward_t.R);

trial_iv = iv(all_times - trial_len, all_times);

%% should now be able to use GetMatchedTrials()
metadata = [];
metadata.taskvars.trial_iv = trial_iv;
metadata.taskvars.trial_iv_L = trial_iv_L;
metadata.taskvars.trial_iv_R = trial_iv_R;
metadata.taskvars.sequence = sequence;

ExpKeys.badTrials = [];
[left,right] = GetMatchedTrials([], metadata, ExpKeys);
