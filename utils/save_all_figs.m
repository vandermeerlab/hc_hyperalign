function save_all_figs(save_dir, fname)
    save_as_eps(save_dir, fname);
    print(gcf, '-dpng', '-r300', cat(2, save_dir, '/', fname, '.png'));
end
