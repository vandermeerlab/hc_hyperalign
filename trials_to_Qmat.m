%function [Qmat_left, Qmat_right] = trials_to_Qmat(left_trials, right_trials)
%function to compile spiking data into left and right Q matrices for
%subsequent PCA analysis. 
%% 
clear;
%For Justin's data
animalprefix = 'ER1'
dir = '/Users/justinshin/Desktop/MIND18_data/ER1_direct/'

load(sprintf('%s%shpidx.mat',dir,animalprefix)); %load indices for hpc cells
load(sprintf('%s%sctxidx.mat',dir,animalprefix)); %load indices for pfc cells (if using)
load(sprintf('%s%sspikes01.mat',dir,animalprefix)); %load all spiking data
%Load time periods for left and right trajectories for each epoch (*if
%necessary. David's function should pull out relevant times for L and R
%trials)
load(sprintf('%s%slefttrajtimes.mat',dir,animalprefix));
load(sprintf('%s%srighttrajtimes.mat',dir,animalprefix));

%This pulls out spiking data for each cell that has been tracked throughout
%the entire experiment. Spiking data is organized for left and right
%trajectories in separate structs.

%collect spiking data for hippocampal cells
cellnum = length(hpidx(:,1)); %number of cells to iterate through

%Left trajectories/hippocampal cells
for epoch = 2:2:16;
    ep = epoch;
    for tt = 1:numel(lefttrajtimes{2})+ numel(lefttrajtimes{4})+ ...
        numel(lefttrajtimes{6})+ numel(lefttrajtimes{8})+ ...
        numel(lefttrajtimes{10}) + numel(lefttrajtimes{12}) + ...
        numel(lefttrajtimes{14})+ numel(lefttrajtimes{16})
        for i = 1:length(lefttrajtimes{ep}(:,1));
            for ii = 1:cellnum
                for l = length(lefttrajtimes{ep});
                    cind2 = hpidx(ii,:);
                    allspikes = spikes{1}{ep}{cind2(1)}{cind2(2)}.data(:,1)';
                    cellspikes = allspikes(allspikes>lefttrajtimes{ep}{l}(1)... 
                    & allspikes<lefttrajtimes{ep}{l}(end));
                    hpc_spikesforQfunction_left{tt}{ii} = cellspikes';
                end
            end
        end
    end
end

%Right trajectories/hippocampal cells
for epoch = 2:2:16;
    ep = epoch;
    for tt = 1:numel(righttrajtimes{2})+ numel(righttrajtimes{4})+ ...
        numel(righttrajtimes{6})+ numel(righttrajtimes{8})+ ...
        numel(righttrajtimes{10}) + numel(righttrajtimes{12}) + ...
        numel(righttrajtimes{14})+ numel(righttrajtimes{16})
        for i = 1:length(righttrajtimes{ep}(:,1));
            for ii = 1:cellnum
                for l = length(righttrajtimes{ep});
                    cind2 = hpidx(ii,:);
                    allspikes = spikes{1}{ep}{cind2(1)}{cind2(2)}.data(:,1)';
                    cellspikes = allspikes(allspikes>righttrajtimes{ep}{l}(1)... 
                    & allspikes<righttrajtimes{ep}{l}(end));
                    hpc_spikesforQfunction_right{tt}{ii} = cellspikes';
                end
            end
        end
    end
end

%% 
%Left trajectories/prefrontal cells
cellnum_pfc = length(ctxidx(:,1)); %number of cells to iterate through

for epoch = 2:2:16;
    ep = epoch;
    for tt = 1:numel(lefttrajtimes{2})+ numel(lefttrajtimes{4})+ ...
        numel(lefttrajtimes{6})+ numel(lefttrajtimes{8})+ ...
        numel(lefttrajtimes{10}) + numel(lefttrajtimes{12}) + ...
        numel(lefttrajtimes{14})+ numel(lefttrajtimes{16})
        for i = 1:length(lefttrajtimes{ep}(:,1));
            for ii = 1:cellnum_pfc
                for l = length(lefttrajtimes{ep});
                    cind2 = ctxidx(ii,:);
                    allspikes = spikes{1}{ep}{cind2(1)}{cind2(2)}.data(:,1)';
                    cellspikes = allspikes(allspikes>lefttrajtimes{ep}{l}(1)... 
                    & allspikes<lefttrajtimes{ep}{l}(end));
                    pfc_spikesforQfunction_left{tt}{ii} = cellspikes';
                end
            end
        end
    end
end

%Right trajectories/prefrontal cells
for epoch = 2:2:16;
    ep = epoch;
    for tt = 1:numel(righttrajtimes{2})+ numel(righttrajtimes{4})+ ...
        numel(righttrajtimes{6})+ numel(righttrajtimes{8})+ ...
        numel(righttrajtimes{10}) + numel(righttrajtimes{12}) + ...
        numel(righttrajtimes{14})+ numel(righttrajtimes{16})
        for i = 1:length(righttrajtimes{ep}(:,1));
            for ii = 1:cellnum_pfc
                for l = length(righttrajtimes{ep});
                    cind2 = ctxidx(ii,:);
                    allspikes = spikes{1}{ep}{cind2(1)}{cind2(2)}.data(:,1)';
                    cellspikes = allspikes(allspikes>righttrajtimes{ep}{l}(1)... 
                    & allspikes<righttrajtimes{ep}{l}(end));
                    pfc_spikesforQfunction_right{tt}{ii} = cellspikes';
                end
            end
        end
    end
end
%% 

load(sprintf('%s%sspikesforQmat_hpc_left.mat',dir,animalprefix)); 
load(sprintf('%s%sspikesforQmat_hpc_right.mat',dir,animalprefix)); 
load(sprintf('%s%sspikesforQmat_pfc_left.mat',dir,animalprefix));
load(sprintf('%s%sspikesforQmat_pfc_right.mat',dir,animalprefix)); 

%Get Q Matrices
for r = 1:length(hpc_spikesforQfunction_left)
     Q = MakeQfromS([],hpc_spikesforQfunction_left{r})
     Qhpc_left{r} = Q  
end
for r = 1:length(hpc_spikesforQfunction_right)
     Q = MakeQfromS([],hpc_spikesforQfunction_right{r})
     Qhpc_right{r} = Q  
end
for r = 1:length(pfc_spikesforQfunction_left)
     Q = MakeQfromS([],pfc_spikesforQfunction_left{r})
     Qpfc_left{r} = Q  
end
for r = 1:length(pfc_spikesforQfunction_right)
     Q = MakeQfromS([],pfc_spikesforQfunction_right{r})
     Qpfc_right{r} = Q  
end
    
%% 

%For Matt's data


