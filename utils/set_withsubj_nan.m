function mat_output = set_withsubj_nan(mat_input)
    mat_output = mat_input;
    mat_output(1:5, 1:5) = NaN;
    mat_output(6:7, 6:7) = NaN;
    mat_output(8:13, 8:13) = NaN;
    mat_output(14:end, 14:end) = NaN;
end
