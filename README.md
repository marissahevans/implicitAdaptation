# Implicit adaptation's effect on sensorimotor and motor confidence — analysis code

Analysis code for:

> Evans MH, Taylor JA, Landy MS. Implicit adaptation's effect on sensorimotor and motor confidence. *J Neurophysiol* (in revision). Preprint: bioRxiv, doi:10.64898/2025.12.15.694412.

The code goes from the raw per-session `.mat` files to every statistic, table and figure in the revised manuscript. It is written in Python. The experiment itself was run in MATLAB/Psychtoolbox, and that code is not included here.

## Requirements

- Python 3.10 or later (tested with 3.13)
- numpy, scipy, matplotlib, pillow (`pip install -r requirements.txt`; tested with numpy 2.5, scipy 1.18, matplotlib 3.11, pillow 12.3)
- `rsvg-convert` (librsvg), needed only by `fig2.py` to render the Fig. 2 artwork (`brew install librsvg` or `apt install librsvg2-bin`)

## Data

The data are included in `data/` (one folder per participant, named by participant code; P1–P20 in the paper follow the `SUBJ` order in `common.py`). The scripts read:

```
data/
  AS/
    AS_sensorimotor.mat          processed sensorimotor-task file
    AS_motoraware.mat            processed motor-awareness-task file
    AS_sigmaFit.mat              saved localization fit (lab script)
    AS_confPermute.mat           saved confidence permutation results (lab script)
    AS_reportPermute.mat         saved report permutation results (lab script)
    AS_errClamp_exp_S1_<date>_<time>_errresults.mat   raw session file (one or more per session)
    AS_errClamp_exp_S1_<date>_<time>_dispInfo.mat     display and calibration info for that file
    ...
  CK/
  ...
```

Each folder also holds the session calibration files (`*_calibration.mat`, `*_tform.mat`), which the analysis does not need, and a few raw files from restarted or extra sessions that are not part of the 240 analysed trials (`SRC` and `sources()` in `common.py` list exactly which files and trials are used). To use data stored elsewhere, set `IAC_DATA=/path/to/data`. Participant order (P1–P20 in the paper) is the `SUBJ` list in `common.py`.

## Running

```
bash run_all.sh            # or run the numbered scripts in order
```

The full run takes about 30–60 min, mostly the permutation tests (03) and simulations (07). Each script writes its intermediate results to `results/*.pkl` and prints its statistics. `run_all.sh` saves those printouts to `results/logs/`. Figures go to `figures/` as PNG and PDF. Random seeds are fixed, so the permutation p-values reproduce exactly.

| Script | What it does | Where it appears in the manuscript |
|---|---|---|
| `01_load_data.py` | Reads all `.mat` files into `results/all.pkl` | — |
| `02_localization_fit.py` | Fits motor and proprioceptive uncertainty (σm, σp) to the localization task | Results: localization; Fig. 3; Supplemental Figure S1 |
| `03_fourier_permutation.py` | Fourier amplitudes and lags; permutation tests (20,000 shuffles); spectral SNR; rectified-sinusoid fit (Eq. 4, 4,000 shuffles) | Figs. 5–7, 10; Supplemental Table S1 |
| `04_kinematics.py` | Stopping distance, movement time, peak velocity, and direction at 50 mm vs. at the target radius, from the tablet samples | Methods: reach summaries |
| `05_confidence_cues.py` | Regressions of confidence on clamp, hand, mismatch and report cues; AIC model comparison | Figs. 9, 13; Supplemental Table S2; Supplemental Figures S3, S5 |
| `06_group_and_cross_task.py` | FDR classification; cross-task overlap (Fisher's exact test) and correlations; reach amplitude vs. confidence modulation; σp vs. adaptation | Results: group and cross-task comparisons; Figs. 7, 13 |
| `07_simulation_and_group_tests.py` | Group permutation tests; detectability simulation for participants without significant modulation | Results: "could weak adaptation hide modulation?" |
| `08_additional_analyses.py` | Points benchmarks; report weights; bounded state-space model; task order and session halves; starting-arc and confidence-time controls | Figs. 11, 14, 15; Supplemental Figure S6; Supplemental Table S3 |
| `09_tables.py` | Writes Supplemental Tables S1–S3 as CSV | Supplemental Tables S1–S3 |
| `11_manuscript_numbers.py` | Descriptive values quoted in the text: session spacing and duration, reach kinematics, points and hit rates, example SNRs, report amplitudes and lags, arc width vs. best fixed arc | Methods and Results |
| `10_figures.py` | All data figures (main and supplemental); calls `fig1.py` and `fig2.py` | Figs. 1–15; Supplemental Figures S1–S6 |
| `fig1.py`, `fig2.py` | Task schematic (Fig. 1) and prediction schematic (Fig. 2) from the artwork in `assets/` | Figs. 1, 2 |

`common.py` holds shared definitions: participant order, which raw files make up each task's 240 trials, Fourier helpers, Benjamini–Hochberg FDR, and the geometry-based reported direction. `config.py` sets the paths.

## Differences from the lab's original MATLAB analysis

The revised analysis recomputes everything from the raw session files. Where it departs from the lab scripts used for the original submission, the scripts in `diagnostics/` show the difference:

- **Sign of the reported direction** (`report_sign_check.py`). In most processed files the `report` variable has the opposite sign to the on-screen report position. Reports are therefore computed from the on-screen position of the report dot (`geo_report` in `common.py`). This reproduces which trials earned points.
- **Report permutation test** (`fdr_and_rectified_summary.py`). The saved report p-values compared report amplitude with shuffled *confidence*. Here the report is tested against shuffled reports.
- **Localization fit** (`localization_fit_variants.py`). The lab fit underestimated σm and σp by a factor of √2 (corrected/lab ratio 1.416). The revised values are the corrected ones. The variants show that this does not change any conclusion.
- **Multiple comparisons.** Per-participant tests are FDR-corrected (Benjamini–Hochberg, q = .01). Uncorrected results are also printed.
- **Effect sizes.** Correlations are reported as r, not R².
- **Points** are recomputed from the on-screen geometry and the payoff function. The lab-recorded points are also printed for comparison.
- `processed_vs_raw.py` checks the processed per-task files against the raw session files trial by trial. `original_values.py` recomputes the values reported in the original submission.

## License

MIT (see `LICENSE`).
