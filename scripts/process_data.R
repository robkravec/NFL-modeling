### ADD DESCRIPTION OF SCRIPT

# Load libraries
library(tidyverse)
library(vroom)

# Unzip .zip file downloaded directly from Kaggle site
unzip(zipfile = "data/nfl-big-data-bowl-2021.zip", exdir = "data/")
