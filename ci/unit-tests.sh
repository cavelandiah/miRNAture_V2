#!/bin/sh
set -eu

prove -l \
  t/config_paths.t \
  t/build_parameters_mirnature.t \
  t/genome_mapping_stream.t \
  t/evaluate_clean_cmsearch.t \
  t/infernal_command_builder.t
python3 -m unittest discover -s t/python -p 'test_*.py'
