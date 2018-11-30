tic;
dists = zeros(100, 100);
for i = 1:100
    x = toeplitz(1:100);
    mean_x = mean(x, 2);
    pca_input = x - mean_x;
    for NumComponents = 1:size(x, 1)
        [eigvecs] = pca_egvecs(pca_input, NumComponents);
        proj_x = pca_project(pca_input, eigvecs);
        recon_x = eigvecs * proj_x + mean_x;
        dists(i, NumComponents) = calculate_dist(x, recon_x);
    end
end

average = mean(dists);
c_interval = quantile(dists, [0.025, 0.975]);
errorbar(average, (c_interval(2, :) - c_interval(1, :)) / 2);
title("Erros between reconstructed and original");
toc;