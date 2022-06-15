######################
# Libraries
######################

import pandas as pd
import numpy as np
import os
import itertools

######################
# Config file and sample sheets
######################

configfile: "config/config.yaml"

# Read in samples file
samples_df = pd.read_csv(config["samples_file"], comment = '#')

# Set variables

SAMPLES = samples_df["sample"]
ASSAYS = ["open_field", "novel_object"]
QUADRANTS = ["q1", "q2", "q3", "q4"]

# Remove faulty videos from sample list

# Read in videos to be excluded
excl_df = pd.read_csv(config["excluded_videos"], comment = "#")

## Create list of variable lists
full_list = [SAMPLES, ASSAYS, QUADRANTS]
## Create list of tuple combinations
combos = list(itertools.product(*full_list))

# Remove unavailable combinations
excl_df = excl_df.reset_index()
for index, row in excl_df.iterrows():
    combos.remove((row['sample'], row['assay'], row['quadrant']))

# Create new lists of variables
SAMPLES = [i[0] for i in combos]
ASSAYS = [i[1] for i in combos]
QUADRANTS = [i[2] for i in combos]

# Get samples with over 85% tracking success

## Create data frame with all
zip_df = pd.DataFrame(
    {
        'sample': SAMPLES,
        'assay': ASSAYS,
        'quadrant' : QUADRANTS
    }
)
## Read in .csv
ts_df = pd.read_csv('config/tracking_success.csv')
## Filter for samples with < 85% tracking success
ts_df = ts_df.loc[ts_df['prop_success'] < 0.85]
## Remove samples with 
for i, row in ts_df.iterrows():
    target_assay = row['assay']
    target_sample = row['sample']
    target_quadrant = row['quadrant']
    zip_df.drop(
        zip_df[
            (zip_df['sample'] == target_sample) & \
            (zip_df['assay'] == target_assay) & \
            (zip_df['quadrant'] == target_quadrant)
            ].index,
            inplace = True
    )
## Get filtered samples and assays
SAMPLES_ZIP_TRK = zip_df['sample']
ASSAYS_ZIP_TRK = zip_df['assay']
QUADRANTS_ZIP_TRK = zip_df['quadrant']
## Multiply lists for combinations with `seconds_interval`
n_intervals = len(config["seconds_interval"])
SAMPLES_ZIP_TRK_INT = list(SAMPLES_ZIP_TRK.values) * n_intervals
ASSAYS_ZIP_TRK_INT = list(ASSAYS_ZIP_TRK.values) * n_intervals
QUADRANTS_ZIP_TRK_INT = list(QUADRANTS_ZIP_TRK.values) * n_intervals
## Multiply each element of `seconds_intervals` by length of original SAMPLES list
INTERVALS_ZIP_TRK_INT = np.repeat(config["seconds_interval"], len(SAMPLES_ZIP_TRK_INT))
