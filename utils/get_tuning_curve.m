function [TC] = get_tuning_curve(session_name)
    % Adapted from https://github.com/vandermeerlab/vandermeerlab/blob/master/code-matlab/example_workflows/WORKFLOW_PlotOrderedRaster.m
    % Get the data
    hc_hyperalign_path = '/Users/mac/Projects/hc_hyperalign';
    load([hc_hyperalign_path '/Data' session_name 'metadata.mat'])
    load([hc_hyperalign_path '/Data' session_name 'ExpKeys.mat'])
    load([hc_hyperalign_path '/Data' session_name 'Spikes.mat'])
    load([hc_hyperalign_path '/Data' session_name 'pos.mat'])

    %% set up data structs for 2 experimental conditions -- see lab wiki for this task at:
    % http://ctnsrv.uwaterloo.ca/vandermeerlab/doku.php?id=analysis:task:motivationalt
    clear expCond;

    expCond(1).label = 'left'; % this is a T-maze, we are interested in 'left' and 'right' trials
    expCond(2).label = 'right'; % these are just labels we can make up here to keep track of which condition means what

    expCond(1).t = metadata.taskvars.trial_iv_L; % previously stored trial start and end times for left trials
    expCond(2).t = metadata.taskvars.trial_iv_R;

    expCond(1).coord = metadata.coord.coordL; % previously user input idealized linear track
    expCond(2).coord = metadata.coord.coordR; % note, this is in units of "camera pixels", not cm

    expCond(1).S = S;
    expCond(2).S = S;

    %% linearize paths (snap x,y position samples to nearest point on experimenter-drawn idealized track)
    nCond = length(expCond);
    for iCond = 1:nCond

        this_coord.coord = expCond(iCond).coord; this_coord.units = 'px'; this_coord.standardized = 0;
        expCond(iCond).linpos = LinearizePos([],pos,this_coord);
        % Compute the coordinate that the choice point corresponds
        chp = tsd(0,metadata.coord.chp_cm,{'x','y'});
        chp.units = 'cm';
        chp.cfg.ExpKeys.convFact = ExpKeys.convFact;
        expCond(iCond).cp = LinearizePos([],chp,this_coord);
    end

    %% find intervals where rat is running
    spd = getLinSpd([],pos); % get speed (in "camera pixels per second")

    cfg_spd = []; cfg_spd.method = 'raw'; cfg_spd.threshold = 10;
    run_iv = TSDtoIV(cfg_spd,spd); % intervals with speed above 10 pix/s

    %% restrict (linearized) position data and spike data to desired intervals
    for iCond = 1:nCond

        fh = @(x) restrict(x,run_iv); % restrict S and linpos to run times only
        expCond(iCond) = structfunS(fh,expCond(iCond),{'S','linpos'});

        fh = @(x) restrict(x,expCond(iCond).t); % restrict S and linpos to specific trials (left/right)
        expCond(iCond) = structfunS(fh,expCond(iCond),{'S','linpos'});

    end

    %% get tuning curves, see lab wiki at:
    % http://ctnsrv.uwaterloo.ca/vandermeerlab/doku.php?id=analysis:nsb2015:week12
    for iCond = 1:nCond

        cfg_tc = [];
        expCond(iCond).tc = TuningCurves(cfg_tc,expCond(iCond).S,expCond(iCond).linpos);
        [~,expCond(iCond).cp_bin] = histc(expCond(iCond).cp.data, expCond(iCond).tc.usr.binEdges);

    end

    TC.left.tc = zscore(expCond(1).tc.tc, 0, 2);
    TC.right.tc = zscore(expCond(2).tc.tc, 0, 2);
    TC.left.cp_bin = expCond(1).cp_bin;
    TC.right.cp_bin = expCond(2).cp_bin;
end
