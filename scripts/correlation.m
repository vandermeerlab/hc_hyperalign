%% Get Q inputs
cfg_data = [];
cfg_data.use_adr_data = 0;
[Q] = prepare_all_Q(cfg_data);

%% Get TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
[TC] = prepare_all_TC(cfg_data);

%% Cell-by-cell correlation
data = Q;
mean_coefs = zeros(1, length(data));
std_coefs = zeros(1, length(data));

for i = 1:length(data)
    cell_coefs = zeros(size(data{i}.left, 1), 1);
    for j = 1:size(data{i}.left, 1)
        [coef] = corrcoef(data{i}.left(j, :), data{i}.right(j, :));
        cell_coefs(j) = coef(1, 2);
    end
    mean_coefs(i) = mean(cell_coefs, 'omitnan');
    std_coefs(i) = std(cell_coefs, 'omitnan');
end

errorbar(1:length(mean_coefs), mean_coefs, std_coefs);
title('Cell-by-cell correlation coefficients (averaged) in each session');

%% Location-by-location (time-by-time) analysis
data = Q;
data = cellfun(@(x) [x.left, x.right], data, 'UniformOutput', false);
coefs = cell(1, length(data));

w_len = size(data{1}, 2);
for i = 1:length(data)
    w_coefs = zeros(w_len, w_len);
    for j = 1:w_len
        for k = 1:w_len
            [coef] = corrcoef(data{i}(:, j), data{i}(:, k));
            w_coefs(j, k) = coef(1, 2);
        end
    end
    coefs{i} = w_coefs;
end

mean_coefs = mean(cat(3, coefs{:}), 3);
imagesc(mean_coefs);
colorbar;
title('Time-by-time correlation coefficients (from L to R)')

%% Create figures for each session
for p_i = 1:length(data)
    imagesc(coefs{p_i});
    colorbar;
    saveas(gcf, sprintf('time_by_time_%d.jpg', p_i));
end
