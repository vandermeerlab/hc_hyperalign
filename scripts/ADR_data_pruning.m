rats = {'R149', 'R152', 'R156', 'R159', 'R169'};

for i = 1:length(rats)
    cd(rats{i});
    data_folders = dir('.');
    data_folders = {data_folders(4:end).name};
    rat_folder = pwd;
    for j = 1:length(data_folders)
        cd(data_folders{j});
        delete *.Nvt
        cd(rat_folder)
    end
    cd('/Users/mac/Desktop/Gupta_data_in_Chen_2021_wo_ncs_nvt')
end