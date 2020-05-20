function [FR_acr_sess_predicted] = avg_acr_predictions(FR_data, w_len)
    FR_acr_sess_predicted = [];
    for d_i = 1:length(FR_data)
        target_FR = FR_data(:, d_i);
        target_FR_predicted = [];
        for t_i = 1:length(target_FR)
            if ~isnan(target_FR{t_i})
                FR_predicted = target_FR{t_i}(:, w_len+1:end);
                target_FR_predicted = cat(3, target_FR_predicted, FR_predicted);
            end
        end
        FR_acr_sess_predicted = [FR_acr_sess_predicted; mean(target_FR_predicted, 3)];
    end
end