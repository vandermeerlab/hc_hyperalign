function [restrictionLabels] = get_restriction_types(session_paths)
    restrictionLabels = cell(1, length(session_paths));
    for s_i = 1:length(session_paths)
        cd(session_paths{s_i});
        LoadExpKeys();
        restrictionLabels{s_i} = ExpKeys.RestrictionType; % loop over sessions
    end
end
