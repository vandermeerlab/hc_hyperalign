%% Two conditions of 1d gaussian tuning curves with fixed sigma and number of neurons
w_len = 50;
n_units = 50;
X = zeros(n_units, w_len);
Y = zeros(n_units, w_len);

p_has_field = 0.5;

for n_i = 1:n_units
    mu_1 = rand() * w_len;
    mu_2 = rand() * w_len;
    peak = 1;
    sig = w_len/8;
    if rand() <= p_has_field
        X(n_i, :) = gaussian_1d(w_len, peak, mu_1, sig);
    end
    if rand() <= p_has_field
        Y(n_i, :) = gaussian_1d(w_len, peak, mu_2, sig);
    end
end

figure;
subplot(1, 3, 1); imagesc(X); colorbar;
xlabel('locations'); ylabel('neurons'); title('X');
set(gca, 'FontSize', 18);

subplot(1, 3, 2); imagesc(Y); colorbar;
xlabel('locations'); ylabel('neurons'); title('Y');
set(gca, 'FontSize', 18);

%% (Hyper/procrustes)-aligen two inputs
[d, Z, transform] = procrustes(X, Y, 'scaling', false);
RMSE_neuron_avg = mean(sqrt(mean((X - Z).^2, 2)));
subplot(1, 3, 3); imagesc(Z); colorbar;
xlabel('locations'); ylabel('neurons'); title('Prediction of X');
set(gca, 'FontSize', 18);
% imagesc(transform.b * Y * transform.T + transform.c); colorbar;

%% Two conditions of 1d gaussian tuning curves with varying sigma and number of neurons
w_len = 50;
n_units_list = 50:5:150;
sigmas_list = 1:0.5:12.5;
p_has_field = 0.5;

RMSE_mat = zeros(length(n_units_list), length(sigmas_list));

for u_i = 1:length(n_units_list)
    n_units = n_units_list(u_i);
    X = zeros(n_units, w_len);
    Y = zeros(n_units, w_len);
    for s_i = 1:length(sigmas_list)
        sigma = sigmas_list(s_i);
        for n_i = 1:n_units
            mu_1 = rand() * w_len;
            mu_2 = rand() * w_len;
            peak = 1;
            if rand() <= p_has_field
                X(n_i, :) = gaussian_1d(w_len, peak, mu_1, sigma);
            end
            if rand() <= p_has_field
                Y(n_i, :) = gaussian_1d(w_len, peak, mu_2, sigma);
            end
        end
        [d, Z, transform] = procrustes(X, Y, 'scaling', false);
        RMSE_neuron_avg = mean(sqrt(mean((X - Z).^2, 2)));
        RMSE_mat(u_i, s_i) = RMSE_neuron_avg;
    end
end

figure; imagesc(RMSE_mat); colorbar;
xlabel('sigma'); ylabel('# of neurons');
xticks(1:2:length(sigmas_list)); xticklabels(1:12);
yticks(1:2:length(n_units_list)); yticklabels(50:10:150);
set(gca, 'FontSize', 18)