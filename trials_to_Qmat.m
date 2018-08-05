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


tt = 1;
for epoch = 2:2:16;
    for l = 1:length(lefttrajtimes{epoch});
        for ii = 1:cellnum
            cind2 = hpidx(ii,:);
            allspikes = spikes{1}{epoch}{cind2(1)}{cind2(2)}.data(:,1)';
            cellspikes = allspikes(allspikes>lefttrajtimes{epoch}{l}(1)...
            & allspikes<lefttrajtimes{epoch}{l}(end));
            hpc_spikesforQfunction_left{tt}{ii} = cellspikes';
            clear cellspikes;
        end
        tt = tt+1
    end
end


tt = 1;
for epoch = 2:2:16;
    for l = 1:length(righttrajtimes{epoch});
        for ii = 1:cellnum
            cind2 = hpidx(ii,:);
            allspikes = spikes{1}{epoch}{cind2(1)}{cind2(2)}.data(:,1)';
            cellspikes = allspikes(allspikes>righttrajtimes{epoch}{l}(1)...
            & allspikes<righttrajtimes{epoch}{l}(end));
            hpc_spikesforQfunction_right{tt}{ii} = cellspikes';
            clear cellspikes;
        end
        tt = tt+1
    end
end


cellnum_pfc = length(ctxidx(:,1));

tt = 1;
for epoch = 2:2:16;
    for l = 1:length(lefttrajtimes{epoch});
        for ii = 1:cellnum_pfc
            cind2 = ctxidx(ii,:);
            allspikes = spikes{1}{epoch}{cind2(1)}{cind2(2)}.data(:,1)';
            cellspikes = allspikes(allspikes>lefttrajtimes{epoch}{l}(1)...
            & allspikes<lefttrajtimes{epoch}{l}(end));
            pfc_spikesforQfunction_left{tt}{ii} = cellspikes';
            clear cellspikes;
        end
        tt = tt+1
    end
end

tt = 1;
for epoch = 2:2:16;
    for l = 1:length(righttrajtimes{epoch});
        for ii = 1:cellnum_pfc
            cind2 = ctxidx(ii,:);
            allspikes = spikes{1}{epoch}{cind2(1)}{cind2(2)}.data(:,1)';
            cellspikes = allspikes(allspikes>righttrajtimes{epoch}{l}(1)...
            & allspikes<righttrajtimes{epoch}{l}(end));
            pfc_spikesforQfunction_right{tt}{ii} = cellspikes';
            clear cellspikes;
        end
        tt = tt+1
    end
end


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


