function plot_2d_histogram(data, labels, bins, path)
    % arguments structure:
        % data.
        %   x 
        %   y
        % labels.
        %   title
        %   x (x-axis label)
        %   y
        %   color (colorbar label) 
        % bins (1 x 2 array holding the histogram dimensions)
        % path.
        %   folder (absolute path to the folder)
        %   filename (name of the file
    hist3([data.x data.y], 'nbins', bins, 'CdataMode', 'auto');
    view(2);
    h = colorbar;
    title(h, labels.color);

    title(labels.title);
    xlabel(labels.x);
    ylabel(labels.y);
    set(gcf, 'InvertHardcopy', 'off');
    full_name = strcat(path.folder, path.filename);
    print(gcf,'-dpng','-r300', full_name);
    
    fprintf("Created %s.\n", path.filename);