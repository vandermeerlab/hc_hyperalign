function set_hyper_path(varargin)
% function set_hyper_path(varargin)
%
% sets path for hc-hyperalign project @ MIND 2018, and returns location of
% data folders to analyze
%
% WARNING: restores default path
%
% INPUTS
%
% (optional cfg struct fields, values below are defaults)
%   cfg_def.vandermeerlab = 1; % add vandermeerlab codebase
%
% OUTPUTS
%
% (none)

cfg.vandermeerlab = 1;

if nargin == 1
    cfg = varargin{1};
elseif nargin > 1
    error('SetHyperPath() requires 0 or 1 input arguments.');
end
restoredefaultpath;

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

% get base file path where repo lives
switch machinename

    case {'ODYSSEUS'} % add case for your machine
        base_fp = 'C:\Users\mvdm\Documents\GitHub\hc_hyperalign';
    case {'mac'}
        base_fp = '/Users/mac/Projects/hc_hyperalign';
    case {'NILSDATOR'}
        base_fp = 'C:\Users\Nils\Desktop\Resa\Git_hyper\hc_hyperalign';
    case {'Justin-Shins-MacBook-Pro.local'}
        base_fp = '/Users/justinshin/Desktop/hc_hyperalign';

end

% add to path
addpath(genpath(cat(2,base_fp,filesep,'scripts')));
addpath(genpath(cat(2,base_fp,filesep,'utils')));
addpath(genpath(cat(2,base_fp,filesep,'hypertools_matlab_toolbox')));

if cfg.vandermeerlab
   addpath(genpath(cat(2,'..',filesep,'vandermeerlab',filesep,'code-matlab',filesep,'shared')));
%    addpath(genpath(cat(2,'..',filesep,'vandermeerlab',filesep,'code-matlab',filesep,'tasks',filesep,'Alyssa_Tmaze'))); % To get getTmazeDataPath
end
