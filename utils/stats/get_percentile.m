function percent = get_percentile(x, xs)
    percent = sum(x > xs) / length(xs);
end
