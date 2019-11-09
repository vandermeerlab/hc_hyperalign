cfg.use_adr_data = 0;
remove_idx_carey = get_interneuron_idx(cfg);

pyramidal_mean_FR = [];
inter_mean_FR = [];
for i = 1:length(Q)
    Q_pyramidal = [Q{i}.left, Q{i}.right];
    Q_pyramidal(remove_idx_carey{i}, :) = [];
    pyramidal_mean_FR = vertcat(pyramidal_mean_FR, mean(Q_pyramidal, 2));

    Q_inter = [Q{i}.left, Q{i}.right];
    Q_inter = Q_inter(remove_idx_carey{i}, :);
    inter_mean_FR = vertcat(inter_mean_FR, mean(Q_inter, 2));
end

subplot(1, 2, 1)
histogram(pyramidal_mean_FR);
hold on;
histogram(inter_mean_FR);
legend('Pyramidal', 'Interneurons');
title('Mean firing rates of (putative) cells in Carey');

cfg.use_adr_data = 1;
remove_idx_adr = get_interneuron_idx(cfg);

pyramidal_mean_FR = [];
inter_mean_FR = [];
for i = 1:length(adr_Q)
    Q_pyramidal = [adr_Q{i}.left, adr_Q{i}.right];
    Q_pyramidal(remove_idx_adr{i}, :) = [];
    pyramidal_mean_FR = vertcat(pyramidal_mean_FR, mean(Q_pyramidal, 2));

    Q_inter = [adr_Q{i}.left, adr_Q{i}.right];
    Q_inter = Q_inter(remove_idx_adr{i}, :);
    inter_mean_FR = vertcat(inter_mean_FR, mean(Q_inter, 2));
end

subplot(1, 2, 2)
histogram(pyramidal_mean_FR);
hold on;
histogram(inter_mean_FR);
legend('Pyramidal', 'Interneurons');
title('Mean firing rates of (putative) cells in ADR');
