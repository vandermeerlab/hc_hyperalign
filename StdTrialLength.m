function [outputArg1,outputArg2] = SignalChop(metadata,pos)
% This function truncates the signal based on one of two options; chopping
% the signal based on the start and end point of a traversal through space
% or by modifying the length of the signal in samples (i.e. time)
%   Detailed explanation goes here
%       Inputs
%           position of the start on cartesian x
%           position of the start on cartesian y
%           position of the end on cartesian x
%           position of the end on cartesian y
%       Outputs
%           signal for a given trial between start and end XYs
%           adjusted signal of shortest signal to match longest
%           adjusted signal of longest signal to match shortest
%
outputArg1 = metadata;
outputArg2 = pos;
end

