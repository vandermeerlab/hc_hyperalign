dists = zeros(100, 100);
for i = 1:100
    x = rand(100, 100);
    for NumComponents = 1:size(x, 1)
        [eigvecs] = pca_egvecs(x, NumComponents);
        redu_x = pca_project(x, eigvecs);
        recon_x = eigvecs * redu_x;
        dists(i, NumComponents) = calculate_dist(x, recon_x);
    end
end

average = mean(dists);
c_interval = quantile(dists, [0.025, 0.975]);
errorbar(average, (c_interval(2, :) - c_interval(1, :)) / 2);
title("Erros between reconstructed and original");