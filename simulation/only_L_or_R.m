% Last 2.4 second, dt = 50ms
w_len = 48;
% Number of neurons
N = 48;
left_Q = zeros(N, w_len);
for i = 1:N
    left_Q(i, :) = gaussian_1d(w_len, 5, i, 5);
end
