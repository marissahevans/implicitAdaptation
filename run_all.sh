#!/usr/bin/env bash
# Runs the whole analysis from the raw data. Takes roughly 30-60 min (permutation tests and simulations).
# Data location: ./data, or set IAC_DATA=/path/to/data
set -e
cd "$(dirname "$0")"
mkdir -p results/logs
for s in 01_load_data 02_localization_fit 03_fourier_permutation 04_kinematics 05_confidence_cues \
         06_group_and_cross_task 07_simulation_and_group_tests 08_additional_analyses 09_tables \
         11_manuscript_numbers 10_figures; do
  echo "== $s"; python3 $s.py | tee results/logs/$s.txt
done
