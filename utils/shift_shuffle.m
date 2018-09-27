function [shuffle_indices] = shift_shuffle(win_len)
    % Pick a random number from 1 to length of time window
    shift_n = randi(win_len);
    % Make the indices within each observation shift
    shuffle_indices = (1:win_len) + shift_n;
    % Stupid way to make the shift
    for i = 1:win_len
        if shuffle_indices(i) > win_len
            shuffle_indices(i) = shuffle_indices(i) - win_len;
        end
    end
end
