library(pscl)
library(dplyr)

# Define functions
rmse <- function(y_true, y_pred) sqrt(mean((y_true - y_pred)^2))

coverage <- function(y, pi) {		
  mean(y >= pi[,1] & y <= pi[,2])		
}	

# Read in training data

train_data <- vroom(
  "./data/train.csv",
  col_types = c(
    quarter = "f",
    down = "f",
    gameId = "d",
    playId = "d",
    offenseFormation = "f",
    numberOfPassRushers = "d",
    defendersInTheBox = "d",#not sure to make it f or d
    typeDropback = "c"
  ),
  col_select = c(playId, gameId, quarter, down, yardsToGo, possessionTeam, 
                 yardlineNumber, offenseFormation, defendersInTheBox,
                 numberOfPassRushers, typeDropback, preSnapVisitorScore,
                 preSnapHomeScore,
                 offensePlayResult,  LB_dist_scrimage,
                 DB_mean_age, LB_mean_age, DB_mean_wgt, LB_mean_wgt,  
                 DB_mean_hgt, LB_mean_hgt, D_var_x, D_var_y, D_cov_xy)
)
  
test_data <-  vroom(
  "./data/test.csv",
  col_types = c(
    quarter = "f",
    down = "f",
    gameId = "d",
    playId = "d",
    offenseFormation = "f",
    numberOfPassRushers = "d",
    defendersInTheBox = "d",#not sure to make it f or d
    typeDropback = "c"
  ),
  col_select = c(playId, gameId, quarter, down, yardsToGo, possessionTeam, 
                 yardlineNumber, offenseFormation, defendersInTheBox,
                 numberOfPassRushers, typeDropback, preSnapVisitorScore,
                 preSnapHomeScore,
                 offensePlayResult,  LB_dist_scrimage,
                 DB_mean_age, LB_mean_age, DB_mean_wgt, LB_mean_wgt,  
                 DB_mean_hgt, LB_mean_hgt, D_var_x, D_var_y, D_cov_xy)
) %>% 
  na.omit()

# standard poisson model
mod_pois <- glm(offensePlayResult ~ . -playId -gameId, 
                data = train_data, 
                family = "poisson")

# zero inflated poisson
mod_zinfl <- zeroinfl(offensePlayResult ~ . -playId -gameId, 
                      dist = 'poisson',
                      data = train_data)


# zero inflated negative binomial
mod_zinfl_nb <- zeroinfl(offensePlayResult ~ . -playId -gameId ,
                      dist = 'negbin',
                      data = train_data)

summary(mod_pois)
summary(mod_zinfl)


# Predictions
true_yards <-test_data$offensePlayResult


y_pred_pois <- predict(mod_zinfl, test_data)
y_pred_nb <- predict(mod_zinfl_nb, test_data)
y_pred <- predict(mod_pois, test_data)


test_data[which(is.na(y_pred_pois)), ]

# Evaluate each model
rmse(true_yards, y_pred)
rmse(true_yards, y_pred_pois)
rmse(true_yards, y_pred_nb)

# Coverage
# Needs to be implemented