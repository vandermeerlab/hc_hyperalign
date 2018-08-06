pos = LoadPos([]);

time = pos.tvec; pos_data_x = pos.data(1,:); pos_data_x = pos.data(2,:);

y_max = 290; y_min = 210; x_min = 250; x_max = 560;

for i = 1:length(TSE_L)
    
stem_time_L{i,:} = time((time > TSE_L(i,1) & time < TSE_L(i,2)) & ...
    ((pos_data_x > x_min & pos_data_x < x_max) & (pos_data_y > y_min ...
    & pos_data_y < y_max)));

stem_time_R{i,:} = time((time > TSE_L(i,1) & time < TSE_L(i,2)) & ...
    ((pos_data_x > x_min & pos_data_x < x_max) & (pos_data_y > y_min ...
    & pos_data_y < y_max)));

    StemSE_L(i,1) = stem_time_L{i,1}(1,1);
    StemSE_L(i,2) = stem_time_L{i,1}(1,end);
    
    StemSE_R(i,1) = stem_time_R{i,1}(1,1);
    StemSE_R(i,2) = stem_time_R{i,1}(1,end);
end