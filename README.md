# hc_hyperalign

This is a project started at 2018 [MIND](https://summer-mind.github.io/) hackthon. The purpose of this project is to investigate correlation in ensemble hippocampal (place) cells neural activity between different experimental conditions using hyperalignment.

## Entry points
Before you try to do anything below. Use `set_hyper_path` and check for path setup, and `getTmazeDataPath` (may need to edit these to add you local path).

### Scripts
`scripts/acr_obs` is the file for analysis for current procedure.

`scripts/acr_obs_withhold` is the file for withholding analysis.

`scripts/acr_obs_only_pca` is the file for analysis without hyperalignment.

### Simulations
`L_R_ind` is for the independent simulation.

`L_xor_R` is for the `x-or` simulation

`same_M_diff_L` is for the generation of hyper-pair.
