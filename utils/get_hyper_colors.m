function colors = get_hyper_colors()
% colors = get_hyper_colors()
% Generates a struct with rgb values for plotting hyperalignment figures.
    colors.carey.HT.fit = [0 100/255 0];  % dark green
    colors.carey.HT.hist = [143/255 188/255 143/255];  % lighter green
    colors.carey.pca.fit = [54/255 100/255 139/255];  % dark blue
    colors.carey.pca.hist = [176/255 196/255 222/255];  % lighter blue
    colors.adr.HT.fit = [104/255 34/255 139/255];  % dark purple
    colors.adr.HT.hist = [216/255 191/255 216/255];  % lighter purple
    colors.adr.pca.fit = [198/255 113/255 113/255];  % dark salmon
    colors.adr.pca.hist = [238/255 213/255 210/255];  % lighter salmon/dusty pink
    % colors.all.f =  [105/255 105/255 105/255];  % dark grey
    % colors.all.w =  [211/255 211/255 211/255];  % lighter grey
end

