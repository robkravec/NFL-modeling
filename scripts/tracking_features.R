library(vroom)
library(tidyverse)
library(dplyr)

games <- vroom("data/games.csv")
plays <- vroom(
  "data/plays.csv",
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

# Read in player data
players <- vroom("data/players.csv")

proc_height <- function(elt) {
  if (length(elt) == 2) {
    return(as.numeric(elt[1])*12 + as.numeric(elt[2]))
  } else {
    return(as.numeric(elt[1]))
  }
}

hghts <- str_split(players$height, "-")
players$height_in <- map_dbl(seq_along(hghts), ~ proc_height(hghts[[.]]))

players$age = 2018 - as.numeric(str_extract(players$birthDate, "\\d{4}"))
players <-  players %>% dplyr::select(nflId, weight, height_in, age)

# Function to  process tracking data (at ball snap) for each week
wkly_tracking_summary <- function(week) {
  wk_path <- paste("data/week", week, ".csv", sep = "")
  wk_data <- vroom(wk_path,
                   col_types = c(nflId = "d",
                                 displayName = "f",
                                 jerseyNumber = "f",
                                 position = "f",
                                 team = "f",
                                 event = "f",
                                 gameId = "d",
                                 playId = "d",
                                 playDirection = "c",
                                 route = "f"))
  
  wk_data <- inner_join(wk_data, games, by = c("gameId"))
  skill_O <- c("WR", "TE", "RB", "QB")
  skill_D <- c("CB", "SS" , "MLB" , "OLB" , "FS", "LB", "ILB", "DB" ,"S")
  
  wk_data <- wk_data %>% 
    inner_join(plays[ , c("possessionTeam", 
                          "playId",
                          "yardlineNumber",
                          "absoluteYardlineNumber",
                          "gameId")], by = c("playId", "gameId")) %>% 
    mutate(teamAbrv = ifelse(team=="home", 
                             homeTeamAbbr,
                             visitorTeamAbbr) ,
           # whether team is on offense or defense
           func = if_else(possessionTeam==teamAbrv, 
                          "O",
                          "D"),
           skill_D = position %in% skill_D,
           skill_O = position %in% skill_O,
           position_2 = case_when(
             position %in% c("MLB" ,"OLB" , "ILB") ~ "LB",
             position %in% c("FS" ,"S" , "SS", "CB", "DB") ~ "DB", 
             TRUE ~ as.character(position))
    )
  wk_data <- inner_join(wk_data, players, by = "nflId")
  wk_proc <- wk_data %>% 
    filter(event == "ball_snap") %>%
    mutate(scrimage_line = if_else(as.character(team)=="football",
                                   x,
                                   0)) %>% 
    group_by(week, gameId, playId) %>% 
    mutate(scrimage_line = max(scrimage_line, na.rm = T)) %>% 
    ungroup() %>% 
    mutate(dist_scrimage = abs(scrimage_line - x)) %>% 
    group_by(week, gameId, playId, func) %>% 
    mutate(var_x = var(x, na.rm = T),
           var_y = var(y, na.rm = T),
           cov_xy = cov(x,y)) %>% 
    ungroup() %>% 
    filter(skill_O | skill_D) %>% 
    group_by(week, gameId, playId, func, position_2) %>% 
    summarise(dist_scrimage = mean(dist_scrimage, na.rm = T), 
              mean_age = mean(age),
              mean_hgt = mean(height_in),
              mean_wgt = mean(weight),
              var_x = first(var_x),
              var_y = first(var_y),
              cov_xy = first(cov_xy), .groups = "drop") %>% 
    filter(position_2!="") %>% # retain skilled positions
    pivot_wider(names_from = position_2,
                values_from = c(dist_scrimage, mean_age, mean_hgt, mean_wgt),
                names_glue = "{position_2}_{.value}") %>% 
    pivot_wider(names_from = func,
                values_from = var_x:cov_xy,
                names_glue = "{func}_{.value}") %>% # generates NAs b/c positions are different for 0/D
    dplyr::group_by(week, gameId, playId) %>% 
    summarise_all(~ mean(., na.rm=T)) 
  
  rm(wk_data)
  wk_proc
}

track_feat <- map_df(1:17, wkly_tracking_summary)

write.csv(track_feat, "./data/ballsnap_features.csv", row.names = F)
