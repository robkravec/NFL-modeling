# NFL Modeling

## Description

...

## Data

Our data, sourced from the NFL's Big Data Bowl 2021 on Kaggle, contains 4 types of files.
Please note that all information in these files pertains to passing plays in the 2018 NFL season:

- Game data: Logistics about each game, including the time, data, and teams playing
- Play data: One line summary for each play, including context (e.g., location on field, 
time remaining in game, score), team formations, and play outcome (e.g., yardage gained)
- Tracking data: Position (i.e., x and y coordinates) and movement (e.g., speed, acceleration) 
measurements for each player at points in time. Offensive and defensive linemen are largely excluded
- Player data (not used for this project): Identifying information for NFL players

Since the files are quite large, our Makefile contains a script to download the data directly
from Kaggle, and the data is not stored in this repository.

## Results

...

## Potential future work

...

## References

- NFL Big Data Bowl 2021 on [Kaggle](https://www.kaggle.com/c/nfl-big-data-bowl-2021/overview)
