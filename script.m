% Decription of purpose
% Users/Owners
% Date of modification

clear all
close all

% Common binning and windowing configurations.
cfg = [];
cfg.dt = 0.05;
cfg.smooth = 'gauss';
cfg.gausswin_size = 1;
cfg.gausswin_sd = 0.02;

% get processed data
Q_42 = get_processed_Q(cfg, '/R042-2013-08-18/');
Q_44 = get_processed_Q(cfg, '/R044-2013-12-21/');
Q_64 = get_processed_Q(cfg, '/R064-2015-04-20/');

% PCA
NumComponents = 10;
proj_Q_42 = perform_pca(Q_42, NumComponents);
proj_Q_44 = perform_pca(Q_44, NumComponents);
proj_Q_64 = perform_pca(Q_64, NumComponents);

% Average across all left (and right) trials
mean_proj_Q.left{1} = mean(cat(3, proj_Q_42.left{:}), 3);
mean_proj_Q.left{2} = mean(cat(3, proj_Q_44.left{:}), 3);
mean_proj_Q.left{3} = mean(cat(3, proj_Q_64.left{:}), 3);

mean_proj_Q.right{1} = mean(cat(3, proj_Q_42.right{:}), 3);
mean_proj_Q.right{2} = mean(cat(3, proj_Q_44.right{:}), 3);
mean_proj_Q.right{3} = mean(cat(3, proj_Q_64.right{:}), 3);
% Hyperalignment
aligned_right = hyperalignment(mean_proj_Q.left, mean_proj_Q.right);

% Calculate distance
dist_42_44 = calculate_dist(aligned_right{1}, aligned_right{2});
dist_42_64 = calculate_dist(aligned_right{1}, aligned_right{3});
dist_44_64 = calculate_dist(aligned_right{2}, aligned_right{3});

% Shuffle aligned Q matrix
rand_dists_42_44 = [];
rand_dists_42_64 = [];
rand_dists_44_64 = [];
for i = 1:100
    shuffle_indices = randperm(size(aligned_right{1}, 1));
    shuffled_aligned_42 = aligned_right{1}(shuffle_indices, :);

    % Calculate distance for 3 pairs of subjects
    rand_dists_42_44 = [rand_dists_42_44, calculate_dist(shuffled_aligned_42, aligned_right{2})];
    rand_dists_42_64 = [rand_dists_42_64, calculate_dist(shuffled_aligned_42, aligned_right{3})];
    rand_dists_44_64 = [rand_dists_44_64, calculate_dist(aligned_right{2}, aligned_right{3})];
end

% Plot shuffle distance histogram and true distance (using aligned-Q matrix)
subplot(3, 1, 1)
histogram(rand_dists_42_44)
line([dist_42_44, dist_42_44], ylim, 'LineWidth', 2, 'Color', 'r');
title('Distance after shuffling aligned-Q matrix between 42 and 44')

subplot(3, 1, 2)
histogram(rand_dists_42_64)
line([dist_42_64, dist_42_64], ylim, 'LineWidth', 2, 'Color', 'r');
title('Distance after shuffling aligned-Q matrix between 42 and 64')

subplot(3, 1, 3)
histogram(rand_dists_44_64)
line([dist_44_64, dist_44_64], ylim, 'LineWidth', 2, 'Color', 'r');
title('Distance after shuffling aligned-Q matrix between 44 and 64')

%% Plot the data
% mat = proj_Q_42;
% figinx = 101;
%
% colors = linspecer(2);
% % need to fix the trial level
% for i = 1: numel(mat.left)
%     Q_left(:,:,i) = mat.left{i};
%     figure(figinx);
%     p1=plot3(Q_left(:,1,i), Q_left(:,2,i), Q_left(:,3,i), '-','color',[0 0 1],'LineWidth',3);
%     p1.Color(4) = 0.1;
%     hold on;
% end
% grid on;
%
% for i = 1:numel(mat.right)
%     Q_right(:,:,i) = mat.right{i};
%     figure(figinx);
%     p1=plot3(Q_right(:,1,i), Q_right(:,2,i), Q_right(:,3,i), '-','color',[1 0 0],'LineWidth',3);
%     p1.Color(4) = 0.1;
%     hold on;
% end
% grid on;

% plot the average
% all_right = mean(Q_right,3);
% figure(figinx);
% p1=plot3(all_right(:,1), all_right(:,2), all_right(:,3), '-','color',[1 0 0],'LineWidth',3);
% p1.Color(4) = 1;
% xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')

% all_left = mean(Q_left,3);
% figure(figinx);hold on
% p1=plot3(all_left(:,1), all_left(:,2), all_left(:,3), '-','color',[0 0 1],'LineWidth',3);
% p1.Color(4) = 1;
% xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')
% title([datatoload ' : Blue - Left, Red - Right'])


% save sub64_new.mat all_right all_left
