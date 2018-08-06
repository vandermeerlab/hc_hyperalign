%Iterates through outbound traj files and compiles into one file. For ER1,
%use y values >40 and x values between 80 and 120. For JS15, use y values
%>30 and x values between 65 and 95

%to do: need to restrict positions to central stem

clear;

dir = '/Users/justinshin/Desktop/MIND18_data/ER1_direct/'
animalprefix = 'ER1'

%extract all outboung trajectory times and concatenate 

for epoch = 2:2:16;
    r = 1;
    load(sprintf('%s%slinpos_tri_out01-Ep%02d.mat',dir,animalprefix,epoch));
    for l = 1:length(lefttraj_linear);
        if ~isempty(lefttraj_linear(r));
            lefttrajtimes{epoch}{l}(1,:) = lefttraj_linear{l}.pos.data(:,1)';
        else
            continue
        end
        r = r+1;
    end
    r = 1;
    for ll = 1:length(righttraj_linear);   
        righttrajtimes{epoch}{ll}(1,:) = righttraj_linear{ll}.pos.data(:,1)';
        r = r+1;
    end
end

