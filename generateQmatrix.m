function [Qmat_data] = generateQmatrix(reg_trials, spikes, concatenate)

%function to compile spiking data into left and right Q matrices for
%subsequent PCA analysis. 

%Load time periods for left and right trajectories for each session.
%May have to modify a bit to make compatible with different data formats.

%This function pulls out spiking data for each cell for each
%trial/trajectory and creates NxT matrices.

%%%% may include options %%%

%option - concatenate
    %if concatenate = 1, concatenate all left and right trials separately
    %into one large Q matrix.

%get spikes for left trials
for l = 1:length(reg_trials.left(:,1));
    for ii = 1:length(spikes.t);
        allspikes = spikes.t(ii)';
        cellspikes = allspikes{1}(allspikes{1}>reg_trials.left(l,1)...
        & allspikes{1}<reg_trials.left(l,2));
        spikesforQ_left{l}{ii} = cellspikes;
        clear allspikes;
        clear cellspikes;
    end
end

%get spikes for right trials
for l = 1:length(reg_trials.right(:,1))
    
    for ii = 1:length(spikes.t);
        allspikes = spikes.t(ii)';
        cellspikes = allspikes{1}(allspikes{1}>reg_trials.right(l,1)...
        & allspikes{1}<reg_trials.right(l,2));
        spikesforQ_right{l}{ii} = cellspikes;
        clear allspikes;
        clear cellspikes;
    end
end


%Get Q Matrices
for r = 1:length(spikesforQ_left)
    if sum(~cellfun(@isempty, spikesforQ_left{r})) > 0
        Q = MakeQfromS([], spikesforQ_left{r});
        Qmat_data.left{r}.Q = Q.data;
        Qmat_data.left{r}.time = Q.tvec;
    end
end
index = cellfun(@isempty, Qmat_data.left) == 0;
Qmat_data.left = Qmat_data.left(index)


for r = 1:length(spikesforQ_right)
    if sum(~cellfun(@isempty, spikesforQ_right{r})) > 0
        Q = MakeQfromS([], spikesforQ_right{r});
        Qmat_data.right{r}.Q = Q.data;
        Qmat_data.right{r}.time = Q.tvec;
    end
end
index = cellfun(@isempty, Qmat_data.right) == 0;
Qmat_data.right = Qmat_data.right(index)




%concatenate everything if you want to
if concatenate == 1;
    Qmat_data.leftconcat = [];
    Qmat_data.leftconcat = Qmat_data.left{1}.Q;
    for s = 2:numel(Qmat_data.left)
        Qmat_data.leftconcat = [Qmat_data.leftconcat Qmat_data.left{s}.Q];
    end
    Qmat_data.rightconcat = [];
    Qmat_data.rightconcat = Qmat_data.right{1}.Q
    for s = 2:numel(Qmat_data.right)
        Qmat_data.rightconcat = [Qmat_data.rightconcat Qmat_data.right{s}.Q];
    end
end 

