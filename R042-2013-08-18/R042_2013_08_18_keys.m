%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%                              ExpKeys                                %%%
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ExpKeys.experimenter = {'MvdM','aacarey'};
ExpKeys.species = 'Rat';
ExpKeys.behavior = 'MotivationalT';
ExpKeys.target = {'dCA1'};
ExpKeys.hemisphere = {'right'};

ExpKeys.day = 3;

ExpKeys.RestrictionType = 'water'; % 'food' % note, this is what was *withheld*, so rat is motivated to get this

ExpKeys.Session = 'standard'; % 'pit', 'reversal’
ExpKeys.Layout = 'foodLeft'; % 'foodRight'
ExpKeys.Pedestal = 'R'; % 'L'

ExpKeys.nPellets = 5;
ExpKeys.waterVolume = [];

ExpKeys.nTrials = 18;
ExpKeys.forcedTrials = []; % none forced today % IDs of trials with block at choice point
ExpKeys.nonConsumptionTrials = []; %all consumed
ExpKeys.badTrials = []; % IDs of trials where rat was somehow interfered with (e.g. unplanned block)

ExpKeys.pathlength = 257; % in cm; distance from start to finish (center arm to reward L or R). Note: start platform length was divided by two, because rat often landed on midpoint
ExpKeys.patharms = 254; % in cm; distance from reward to reward (L arm to R arm)
ExpKeys.realTrackDims = [139 185]; % x width and y width (according to camera axes) *** for R042 the start platform didn't exist yet, so the central arm is shorter
ExpKeys.convFact = [2.9176 2.3794]; % x conversion factor and y conversion factor for loading position data in cm

ExpKeys.TimeOnTrack = 3240;
ExpKeys.TimeOffTrack = 5645;
ExpKeys.prerecord = [2126.64553 3214.07253]; % timestamps for prerecord
ExpKeys.task = [3238.67853 5645.16153]; % timestamps for task 
ExpKeys.postrecord = [5656.35353 6563.46453]; % timestamps for postrecord

ExpKeys.goodSWR = {'R042-2013-08-18-CSC11a.ncs' 'R042-2013-08-18-CSC12a.ncs'}; % list CSCs (at most one per TT) with good SWRs, first best
ExpKeys.goodTheta = {'R042-2013-08-18-CSC07a.ncs'}; % list CSCs (at most one per TT) with good theta, first best


