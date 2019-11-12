function colors = get_hyper_colors()
% colors = get_hyper_colors()
% Generates a struct with rgb values for plotting hyperalignment figures.
    colors.HT.fit = [0 100/255 0];  % dark green
    colors.HT.hist = [143/255 188/255 143/255];  % lighter green
    colors.pca.fit = [54/255 100/255 139/255];  % dark blue
    colors.pca.hist = [176/255 196/255 222/255];  % lighter blue
    colors.wh.fit = [105/255 105/255 105/255];  % dark grey
    colors.wh.hist = [211/255 211/255 211/255];  % lighter grey
    colors.ID.fit =  [104/255 34/255 139/255];  % dark purple
    colors.ID.hist =  [216/255 191/255 216/255];  % lighter purple

    % [198/255 113/255 113/255];  % dark salmon
    % [238/255 213/255 210/255];  % lighter salmon/dusty pink
end

