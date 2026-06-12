#!/bin/bash

# Starting 2026-06-11, Ky forked the original repo to make this one.
# The details of changes to this file (and all other files in this repository), including when the changes were made, can be found in the Git metadata of this repository.
# If you receive a version of this repository that is lacking the Git metadata, you may contact Ky and they will provide that metadata to you free of charge: FreeAltTab@KyNorthstar.me

profileFile="/tmp/profile_$(date +%Y%m%d_%H%M%S)"

xcrun xctrace record \
  --instrument 'Time Profiler' \
  --time-limit 20s \
  --no-prompt --quiet \
  --output "$profileFile".trace \
  --launch -- \
    DerivedData/Build/Products/Debug/FreeAltTab.app --benchmark showUi 3

xcrun xctrace export \
  --input "$profileFile".trace \
  --xpath '/trace-toc/run[@number="1"]/data/table[@schema="time-profile"]' \
  --output "$profileFile".xml
