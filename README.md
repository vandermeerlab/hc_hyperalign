# hc_hyperalign

The codebase of the paper: [Between-subject prediction reveals a shared representational geometry in the rodent hippocampus](https://www.biorxiv.org/content/10.1101/2020.01.27.922062v1). The main idea of this paper (which was started at 2018 [MIND](https://summer-mind.github.io/) hackthon) is to reveal a shared relationship in ensemble hippocampal (place) cells activity between different experimental conditions (left and right running trials on a T-maze in this case) across subjects using hyperalignment.

## Entry points

Clone and check out the `hyperalignment` branch of the vandermeerlab main codebase.

Before you try to do anything below, edit `set_hyper_path` for path setup (corresponds to your local path), and `getTmazeDataPath` and `getAdrDataPath` in `utils/data` folder for data setup.

Then execute `set_hyper_path` in your matlab command window.

## Running Scripts

Each figure has a corresponding script in
`fig_scripts` folder and data preparation script used in fig 2, supp. fig 2, fig 3 and supp. fig 3 is located at `scripts/prepare_inputs`.

Note that they might share the common scripts with only different parameter used (for flexibly testing different data input). For example, Q in figure 2 includes interneurons, so `cfg_data.removeInterneurons = 0;`, but figure 3 and so on excludes interneurons (`cfg_data.removeInterneurons = 1;`).

You should adjust the parameters before preparing the data input. (We might finalize the data input used then this is no longer required.)

## Acknowledgement

The following tools/code were used in this paper. We thank all of their contributors.

shadedErrorBar: https://github.com/raacampbell/shadedErrorBar

hypertools: https://github.com/ContextLab/hypertools-matlab
