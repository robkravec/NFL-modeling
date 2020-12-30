### ADD DESCRIPTION OF SCRIPT

# Load libraries
library(tidyverse)
library(vroom)

# Unzip .zip file downloaded directly from Kaggle site

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
    yardlineSide = "c",
    possessionTeam = "c"
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
         penalty_flag = ifelse(offensePlayResult != playResult, 1, 0),
         yards_to_endzone = case_when(
                    yardlineNumber == 50 ~ 50,
                    possessionTeam == yardlineSide ~ 100 -yardlineNumber,
                    TRUE  ~ yardlineNumber)
         ) %>% 
  filter(penalty_flag == 0 ,
         offensePlayResult >= 0,
         #,not_competitive == 0
         passResult != "S"
         #,offenseFormation!="JUMBO"
         #,offenseFormation!="WILDCAT"
         #,typeDropback!="UNKNOWN"
         )


# Read tracking features 
tracking_feat <- read_csv("data/ballsnap_features.csv")


# Join data 
play_game <- inner_join(play_game, 
                        tracking_feat,
                        on =  c("gameId", "playId", "week"))

# train test split 
n <- nrow(play_game)
train = sample(1:n, size = round(.8*n))
test = -1*train

write_csv(play_game[train, ], "./data/train.csv")
write_csv(play_game[test, ], "./data/test.csv")
