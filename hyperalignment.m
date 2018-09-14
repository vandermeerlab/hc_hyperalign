% Perform hyperalignment and plot the result

% Add Path
hc_hyperalign_path = '/Users/mac/Projects/hc_hyperalign';
addpath([hc_hyperalign_path '/utils'])
addpath([hc_hyperalign_path '/hypertools_matlab_toolbox'])

load sub42_new.mat
lMats{1}=all_left;

load sub44_new.mat
lMats{2}=all_left;

load sub64_new.mat
lMats{3}=all_left;

load sub42_new.mat
lMats{4}=all_right;

load sub44_new.mat
lMats{5}=all_right;

load sub64_new.mat
lMats{6}=all_right;

[aligned_left, transforms] = hyperalign(lMats{1:3});

aligned_right{1} = p_transform(transforms{1},lMats{4});
aligned_right{2} = p_transform(transforms{2},lMats{5});
aligned_right{3} = p_transform(transforms{3},lMats{6});

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
    rand_dists_42_64 = [rand_dists_42_44, calculate_dist(shuffled_aligned_42, aligned_right{3})];
    rand_dists_44_64 = [rand_dists_42_44, calculate_dist(aligned_right{2}, aligned_right{3})];
end

for 

% % Plot trajectory
% % left
% trajectory_plotter(1, aligned_left{1}, aligned_left{2}, aligned_left{3});
% title('hyperaligned left trials');
% 
% % right
% trajectory_plotter(1, aligned_right{1}, aligned_right{2}, aligned_right{3});
% title('hyperaligned right trials');
% 
% % non-aligned right trials
% trajectory_plotter(1, lMats{4}, lMats{5}, lMats{6});
% title('non-aligned right trials');
