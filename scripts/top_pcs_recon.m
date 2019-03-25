%% Get Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
[Q] = prepare_all_Q(cfg_data);

%% Get TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
[TC] = prepare_all_TC(cfg_data);

%% Extract top pcs and reconstruct them in Q/TC space.
data = Q;
NumComponents = 10;
for p_i = 1:length(data)
    cd 'C:\Users\mvdmlab\Desktop\top_pcs_recon\ind_Q';
    folder_name = sprintf('Q_%d', p_i);
    mkdir(folder_name);
    cd(folder_name);
    % Project [L, R] to PCA space.
    data_norm{p_i} = normalize_Q('ind', data{p_i});
    pca_input = [data_norm{p_i}.left, data_norm{p_i}.right];
    pca_mean = mean(pca_input, 2);
    pca_input = pca_input - pca_mean;
    [eigvecs] = pca_egvecs(pca_input, NumComponents);
    for ev_i = 1:NumComponents
        proj_x = pca_project(pca_input, eigvecs(:, ev_i));
        recon_x = eigvecs(:, ev_i) * proj_x + pca_mean;
        % Plot reconstrcuted PCs
        imagesc(recon_x)
        colorbar;
        ylabel('Neurons');
        xlabel('L & R');
        saveas(gcf, sprintf('PC_%d.jpg', ev_i));
    end
end