x_max = 290; x_min = 210; y_min = 250; y_max = 560;

for i = 1:length(TSE_L)
stem_time_L{i,:} = time((time > TSE_L(i,1) & time < TSE_L(i,2)) & ...
    ((pos_data_x > x_min & pos_data_x < x_max) & (pos_data_y > y_min ...
    & pos_data_y < y_max)));
stem_time_R{i,:} = time((time > TSE_L(i,1) & time < TSE_L(i,2)) & ...
    ((pos_data_x > x_min & pos_data_x < x_max) & (pos_data_y > y_min ...
    & pos_data_y < y_max)));
end