### ADD DESCRIPTION OF SCRIPT

# Load libraries
library(tidyverse)
library(vroom)

# Unzip .zip file downloaded directly from Kaggle site
unzip(zipfile = "data/nfl-big-data-bowl-2021.zip", exdir = "data/")

# Read in game and play data
games <- vroom("data/games.csv")
plays <- vroom("data/plays.csv",
  col_types = c(
    quarter = "f",
    down = "f",
    gameId = "d",
    playId = "d",
    playResult = "d",
    playType = "f",
    passResult = "f",
    isDefensivePI = "l",
    offenseFormation = "f",
    numberOfPassRushers = "f",
    personnelO = "f" ,
    personnelD = "f",
    defendersInTheBox = "f",#not sure to make it f or d
    typeDropback = "f",
    penaltyCodes = "f",
    penaltyJerseyNumbers = "f",
    yardlineSide = "f",
    possessionTeam = "f"
  )
)

# Join game and play data
play_game <- left_join(x = games, y = plays,
                       by = "gameId")

# Add feature denoting which team is on defense
play_game <- play_game %>% 
  mutate(defense_team = ifelse(possessionTeam == homeTeamAbbr, visitorTeamAbbr,
                               homeTeamAbbr),
         not_competitive = case_when(
           abs(preSnapHomeScore - preSnapVisitorScore) >= 21 ~ 1,
           abs(preSnapHomeScore - preSnapVisitorScore) > 14 & quarter == 4 ~ 1,
           TRUE ~ 0),
         penalty_flag = ifelse(offensePlayResult != playResult, 1, 0)
         ) %>% 
  filter(penalty_flag == 0 
         #,not_competitive == 0
         ,passResult != "S"
         #,offenseFormation!="JUMBO"
         #,offenseFormation!="WILDCAT"
         #,typeDropback!="UNKNOWN"
         )

