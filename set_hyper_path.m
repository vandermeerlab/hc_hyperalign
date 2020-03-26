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
% (optional cfg struct fields, values below are defaults)\
%   cfg.vandermeerlab = 1; % add vandermeerlab codebase
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

% if ispc
%     machinename = getenv('COMPUTERNAME');
%     filesep = '\';
% elseif ismac
%     machinename = getenv('USER');
%     filesep = '/';
% else
%     machinename = getenv('HOSTNAME');
%     filesep = '/';
% end

% get base file path where repo lives

base_fp = 'C:\Users\willb\Documents\van der Meer Lab\hc_hyperalign';
% switch machinename
%     case {'mac'} % add case for your machine
%         base_fp = '/Users/mac/Dropbox (Dartmouth College)/Projects/Code/hc_hyperalign';
%     case {'PROMETHEUS'}
%         base_fp = 'C:\Users\mvdmlab\Documents\GitHub\hc_hyperalign';
% end

if cfg.vandermeerlab
    addpath(genpath(cat(2,'..',filesep,'vandermeerlab',filesep,'code-matlab',filesep,'shared')));
    addpath(genpath(cat(2,'..',filesep,'vandermeerlab',filesep,'code-matlab',filesep,'tasks',filesep,'Alyssa_Tmaze')));
end

% add to path
addpath(genpath(cat(2,base_fp,filesep,'scripts')));
addpath(genpath(cat(2,base_fp,filesep,'sandboxs')));
addpath(genpath(cat(2,base_fp,filesep,'simulations')));
addpath(genpath(cat(2,base_fp,filesep,'procedures')));
addpath(genpath(cat(2,base_fp,filesep,'utils')));
addpath(genpath(cat(2,base_fp,filesep,'hypertools_matlab_toolbox')));
