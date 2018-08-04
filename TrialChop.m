function [trial] = TrialChop(time,Start,End)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
trial = time(time > Start & time < End);
end

