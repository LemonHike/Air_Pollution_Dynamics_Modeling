## ----setup, echo=F, message=F-------------------------------------------------
knitr::opts_chunk$set(message = FALSE,
                      results = FALSE,
                      warning = FALSE,
                      echo = TRUE,
                      fig.align = "center")

set.seed(2020)

library(magrittr) # pipes
library(stringr) # str_glue
library(depmixS4)
library(dlm)
library(tidyverse) # dplyr, tidyr, ggplot2




## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=6, fig.show='hold', fig.align='center'----
epa_data <- read.csv('/Users/lemon/Documents/Uni/Magistrale/Semestre 4/Time Series Analysis/Final Project/ts_epa_2020_west_sept_fill.csv')

# Converting to date-time format
epa_data$datetime <- as.POSIXct(epa_data$datetime, format="%Y-%m-%dT%H:%M:%SZ", tz="GMT")

station_data <- epa_data %>% filter(station_id == 47)

head(epa_data)



## ----echo=FALSE, out.width='95%', fig.width=20, fig.height=5, fig.show='hold', fig.align='center'----
# Plot time series for PM2.5
# Load necessary library
library(gridExtra)

# Create individual plots
plot_pm25 <- ggplot(station_data, aes(x=datetime, y=pm25)) +
  geom_line(color="grey40") +
  labs(title="Time Series of PM2.5", x="Datetime", y="PM2.5") +
  theme_bw() +
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_text(size = 18),    # Legend title
    legend.text = element_text(size = 16)
  )

plot_temp <- ggplot(station_data, aes(x=datetime, y=temp)) +
  geom_line(color="grey40") +
  labs(title="Time Series of Temperature", x="Datetime", y="Temperature (Celsius)") +
  theme_bw() +
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_text(size = 18),    # Legend title
    legend.text = element_text(size = 16)
  )

plot_wind <- ggplot(station_data, aes(x=datetime, y=wind)) +
  geom_line(color="grey40") +
  labs(title="Time Series of Wind Speed", x="Datetime", y="Wind Speed (knots/second)") +
  theme_bw() +
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_text(size = 18),    # Legend title
    legend.text = element_text(size = 16)
  )

# Arrange the plots in a grid with 3 columns and 1 row
grid.arrange(plot_pm25, plot_temp, plot_wind, ncol=3)



## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=9, fig.show='hold', fig.align='center'----
pm25_data <- station_data$pm25

# Extract the posterior states
hmm_model_2 <- depmix(pm25 ~ 1, family=gaussian(), nstates=2, data=data.frame(pm25=pm25_data))
hmm_fit_2 <- fit(hmm_model_2)

# Print the summary of the best model
summary(hmm_fit_2)

estStates <- posterior(hmm_fit_2)


# Extract the state means for all states
estMean1 <- hmm_fit_2@response[[1]][[1]]@parameters$coefficients[1]
estMean2 <- hmm_fit_2@response[[2]][[1]]@parameters$coefficients[1]

# Create a vector to hold the estimated means for each time point
estMeans <- numeric(nrow(station_data))

# Assign the estimated means based on the estimated states
estMeans[estStates[, 1] == 1] <- estMean1
estMeans[estStates[, 1] == 2] <- estMean2

station_data$estState <- factor(estStates[, 1], levels = c(1, 2), labels = c("Estimated Mean - State 1", "Estimated Mean - State 2"))

# Create the base plot
ggplot(data = station_data, aes(x = datetime)) +
  geom_point(aes(y = pm25, color = "Observed PM2.5"), size = 0) +    # Plot observed data points
  geom_line(aes(y = pm25, color = "Observed PM2.5")) +               # Plot observed data lines
  geom_point(aes(y = estMeans, color = estState), size = 2) +        # Plot estimated means
  labs(x = 'DateTime', y = 'PM2.5', title = 'Univariate Hidden Markov Model with 2 States', color="") +
  scale_color_manual(values = c("Observed PM2.5" = "grey40", 
                                "Estimated Mean - State 1" = "orange", 
                                "Estimated Mean - State 2" = "red")) +
  theme_bw() +  # Minimal theme for better aesthetics
  theme(plot.title = element_text(hjust = 0.5, size = 25),
        legend.position = c(0.89, 0.89),
        axis.title = element_text(size = 20),      # Axis titles
        axis.text = element_text(size = 20),       # Axis text
        #legend.title = element_text(size = 18),
        legend.title = element_blank(),   
        legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") , 
        legend.text = element_text(size = 16)) +
  guides(color = guide_legend(override.aes = list(size = 3)))  # Adjust legend point size for better visibility





## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=9, fig.show='hold', fig.align='center'----
pm25_data <- station_data$pm25

# Define and fit HMM with 3 states
hmm_model_3 <- depmix(pm25 ~ 1, family=gaussian(), nstates=3, data=data.frame(pm25=pm25_data))
hmm_fit_3 <- fit(hmm_model_3)

summary(hmm_fit_3)


# Extract the posterior states
estStates <- posterior(hmm_fit_3)

# Extract the state means for all states
estMean1 <- hmm_fit_3@response[[1]][[1]]@parameters$coefficients[1]
estMean2 <- hmm_fit_3@response[[2]][[1]]@parameters$coefficients[1]
estMean3 <- hmm_fit_3@response[[3]][[1]]@parameters$coefficients[1]

# Create a vector to hold the estimated means for each time point
estMeans <- numeric(nrow(station_data))

# Assign the estimated means based on the estimated states
estMeans[estStates[, 1] == 1] <- estMean1
estMeans[estStates[, 1] == 2] <- estMean2
estMeans[estStates[, 1] == 3] <- estMean3

station_data$estState <- factor(estStates[, 1], levels = c(1, 2, 3), labels = c("Estimated Mean - State 1", "Estimated Mean - State 2", "Estimated Mean - State 3"))

# Create the base plot
ggplot(data = station_data, aes(x = datetime)) +
  geom_point(aes(y = pm25, color = "Observed PM2.5"), size = 0) +    # Plot observed data points
  geom_line(aes(y = pm25, color = "Observed PM2.5")) +               # Plot observed data lines
  geom_point(aes(y = estMeans, color = estState), size = 2) +        # Plot estimated means
  labs(x = 'DateTime', y = 'PM2.5', title = 'Univariate Hidden Markov Model with 3 States', color="") +
  scale_color_manual(values = c("Observed PM2.5" = "grey40", 
                                "Estimated Mean - State 1" = "orange", 
                                "Estimated Mean - State 2" = "red", 
                                "Estimated Mean - State 3" = "blue")) +
  theme_bw() +  # Minimal theme for better aesthetics
  theme(plot.title = element_text(hjust = 0.5, size = 25),
        legend.position = c(0.89, 0.87),
        axis.title = element_text(size = 20),      # Axis titles
        axis.text = element_text(size = 20),       # Axis text
        #legend.title = element_text(size = 18),
        legend.title = element_blank(),   
        legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") , 
        legend.text = element_text(size = 16)) +
  guides(color = guide_legend(override.aes = list(size = 3)))  # Adjust legend point size for better visibility



## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=9, fig.show='hold', fig.align='center'----
library(depmixS4)

# Prepare data for the extended HMM model
hmm_model_extended <- depmix(pm25 ~ temp + wind, family=gaussian(), nstates=2, data=station_data)

# Fit the extended HMM model
hmm_fit_extended <- fit(hmm_model_extended)

# Print the summary of the extended model
summary(hmm_fit_extended)

# Extract the posterior states
estStates_extended <- posterior(hmm_fit_extended)$state

# Ensure the lengths of the state vector and the dataset match
if (length(estStates_extended) != nrow(station_data)) {
  stop("The length of estStates_extended does not match the number of rows in station_data")
}

# Extract the state means for all states
estMean1_extended <- hmm_fit_extended@response[[1]][[1]]@parameters$coefficients[1]
estMean2_extended <- hmm_fit_extended@response[[2]][[1]]@parameters$coefficients[1]

# Create a vector to hold the estimated means for each time point
estMeans_extended <- rep(estMean1_extended, nrow(station_data))

# Assign the estimated means based on the estimated states
estMeans_extended[estStates_extended == 2] <- estMean2_extended

# Add the estimated state to the station_data
station_data$estState <- factor(estStates_extended, levels = c(1, 2), labels = c("Estimated Mean - State 1", "Estimated Mean - State 2"))

# Create the base plot
ggplot(data = station_data, aes(x = datetime)) +
  geom_point(aes(y = pm25, color = "Observed PM2.5"), size = 0) +    # Plot observed data points
  geom_line(aes(y = pm25, color = "Observed PM2.5")) +               # Plot observed data lines
  geom_point(aes(y = estMeans_extended, color = estState), size = 2) +  # Plot estimated means
  labs(x = 'DateTime', y = 'PM2.5', title = 'Multivariate Hidden Markov Model with 2 States', color="") +
  scale_color_manual(values = c("Observed PM2.5" = "grey40", 
                                "Estimated Mean - State 1" = "orange", 
                                "Estimated Mean - State 2" = "red")) +
  theme_bw() +  # Minimal theme for better aesthetics
  theme(plot.title = element_text(hjust = 0.5, size = 25),
        legend.position = c(0.89, 0.89),
        axis.title = element_text(size = 20),      # Axis titles
        axis.text = element_text(size = 20),       # Axis text
        #legend.title = element_text(size = 18),
        legend.title = element_blank(),   
        legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") , 
        legend.text = element_text(size = 16)) +
  guides(color = guide_legend(override.aes = list(size = 3)))  # Adjust legend point size for better visibility






## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=9, fig.show='hold', fig.align='center'----
library(depmixS4)

# Prepare data for the extended HMM model
hmm_model_extended <- depmix(pm25 ~ temp + wind, family=gaussian(), nstates=3, data=station_data)

# Fit the extended HMM model
hmm_fit_extended <- fit(hmm_model_extended)

# Print the summary of the extended model
summary(hmm_fit_extended)

# Extract the posterior states
estStates_extended <- posterior(hmm_fit_extended)$state

# Ensure the lengths of the state vector and the dataset match
if (length(estStates_extended) != nrow(station_data)) {
  stop("The length of estStates_extended does not match the number of rows in station_data")
}

# Extract the state means for all states
estMean1_extended <- hmm_fit_extended@response[[1]][[1]]@parameters$coefficients[1]
estMean2_extended <- hmm_fit_extended@response[[2]][[1]]@parameters$coefficients[1]
estMean3_extended <- hmm_fit_extended@response[[3]][[1]]@parameters$coefficients[1]

# Create a vector to hold the estimated means for each time point
estMeans_extended <- rep(estMean1_extended, nrow(station_data))

# Assign the estimated means based on the estimated states
estMeans_extended[estStates_extended == 2] <- estMean2_extended
estMeans_extended[estStates_extended == 3] <- estMean3_extended

station_data$estState <- factor(estStates_extended, levels = c(1, 2, 3), labels = c("Estimated Mean - State 1", "Estimated Mean - State 2", "Estimated Mean - State 3"))

# Create the base plot
ggplot(data = station_data, aes(x = datetime)) +
  geom_point(aes(y = pm25, color = "Observed PM2.5"), size = 0) +    # Plot observed data points
  geom_line(aes(y = pm25, color = "Observed PM2.5")) +               # Plot observed data lines
  geom_point(aes(y = estMeans_extended, color = estState), size = 2) +  # Plot estimated means
  labs(x = 'DateTime', y = 'PM2.5', title = 'Multivariate Hidden Markov Model with 3 States', color="") +
  scale_color_manual(values = c("Observed PM2.5" = "grey40", 
                                "Estimated Mean - State 1" = "orange", 
                                "Estimated Mean - State 2" = "red",
                                "Estimated Mean - State 3" = "blue")) +
  theme_bw() +  # Minimal theme for better aesthetics
  theme(plot.title = element_text(hjust = 0.5, size = 25),
        legend.position = c(0.89, 0.87),
        axis.title = element_text(size = 20),      # Axis titles
        axis.text = element_text(size = 20),       # Axis text
        #legend.title = element_text(size = 18),
        legend.title = element_blank(),   
        legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") , 
        legend.text = element_text(size = 16)) +
  guides(color = guide_legend(override.aes = list(size = 3)))  # Adjust legend point size for better visibility





## ----echo=FALSE, out.width='95%', fig.width=20, fig.height=5, fig.show='hold', fig.align='center'----
# Prepare data for HMM
# Transform PM2.5 data to log scale
station_data$log_pm25 <- log(station_data$pm25)

library(zoo)

# Aggregate data to 12-hour averages
station_data_12h <- station_data %>%
  mutate(datetime_12h = as.POSIXct(cut(datetime, breaks="12 hours"))) %>%
  group_by(datetime_12h) %>%
  summarize(log_pm25_avg = mean(log_pm25, na.rm=TRUE))


plot_1 = ggplot(station_data, aes(x=datetime, y=pm25)) +
  geom_line(color="grey40") +
  labs(title="Time Series of PM2.5", x="Datetime", y="PM2.5") +
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_text(size = 18),    # Legend title
    legend.text = element_text(size = 16)
  )

plot_2 = ggplot(station_data_12h, aes(x=datetime_12h, y=log_pm25_avg)) +
  geom_line(color="grey40") +
  geom_point(color="grey40") +
  labs(title="Log-Scaled Time Series of PM2.5", x="Datetime", y="Log(PM2.5) 12-Hour Avg") +
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_text(size = 18),    # Legend title
    legend.text = element_text(size = 16)
  )

grid.arrange(plot_1, plot_2, ncol=2)



## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=6, fig.show='hold', fig.align='center'----

# Load necessary library


# Load necessary library
library(dlm)

# Define the random walk plus noise model
build_dlm <- function(param) {
  dlmModPoly(order = 1, dV = exp(param[1]), dW = exp(param[2]))
}

# Fit the model using maximum likelihood
fit <- dlmMLE(station_data_12h$log_pm25_avg, parm = c(0, 0), build = build_dlm, hessian = TRUE)

AsymCov=solve(fit$hessian) #asymptotic covariance matrix of the MLEs 
sqrt(diag(AsymCov))

# Extract the fitted model
fitted_model <- build_dlm(fit$par)

# Print the estimated parameters
exp(fit$par)


## ----echo=FALSE, out.width='90%', fig.width=18, fig.height=9, fig.show='hold', fig.align='center'----

# Filter the time series with the fitted model
filtered <- dlmFilter(station_data_12h$log_pm25_avg, fitted_model)

n <- nrow(station_data_12h)

one_step_ahead_pred <- filtered$m[n] # Last filtered state estimate

# Add one day to the last date in the series
last_datetime <- station_data_12h$datetime_12h[n]
next_datetime <- last_datetime + 24*60*60 

hwid <- qnorm((1-0.95) / 2) *sqrt(with(filtered, unlist(dlmSvd2var(U.R, D.R))))
smooth <- cbind(filtered$f, as.vector(filtered$f) + hwid %o% c(1,-1)) 
smooth[1,] = smooth[2,] 

# One-step-ahead predictions
predictions <- dlmForecast(filtered, nAhead = 1)$a

colors <- c("Observed" = "grey40", "Future Prediction" = "red", "One-Step Ahead Forecast" = 'orange', '95% Probability Limits' = 'white')
# Add the smooth band to the plot
ggplot(station_data_12h, aes(x = datetime_12h, y = log_pm25_avg)) +
  geom_line(aes(color = "Observed")) +
  geom_point(aes(color = "Observed"), size = 3) +
  geom_line(aes(y = smooth[,1], color = "One-Step Ahead Forecast")) +
  geom_point(aes(y = smooth[,1], color = "One-Step Ahead Forecast"), size = 3) +
  geom_ribbon(aes(ymin = smooth[,2], ymax = smooth[,3], color = '95% Probability Limits'), alpha = 0.2, fill = '95% Probability Limits') + # Adding the ribbon for smoothed confidence interval
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions, color = "Future Prediction"), size = 3) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions, color = "Future Prediction"), shape = 4, size = 5) + 
  labs(title = "Time Series of PM2.5 - Station 47", x = "Datetime", y = "Log(PM2.5) 12-Hour Avg", color = '') +
  scale_color_manual(values = colors) + 
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    legend.position = c(0.12, 0.9),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_blank(),   
    legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") , 
    legend.text = element_text(size = 20)) +
  guides(color = guide_legend(override.aes = list(size = 3)))




## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=6, fig.show='hold', fig.align='center'----

# Load necessary libraries
library(dplyr)
library(zoo)
library(ggplot2)
library(dlm)
library(sp)


# Convert datetime column to POSIXct
epa_data$datetime <- as.POSIXct(epa_data$datetime, format="%Y-%m-%dT%H:%M:%SZ", tz="GMT")

# Filter data for the selected stations
stations <- c(41, 47, 96, 99)
station_data <- epa_data %>% filter(station_id %in% stations)

# Transform PM2.5 data to log scale
station_data$log_pm25 <- log(station_data$pm25)

# Aggregate data to 12-hour averages
station_data_12h <- station_data %>%
  mutate(datetime_12h = as.POSIXct(cut(datetime, breaks="12 hours"))) %>%
  group_by(station_id, datetime_12h) %>%
  summarize(log_pm25_avg = mean(log_pm25, na.rm=TRUE))

# Convert to wide format
station_data_wide <- station_data_12h %>%
  pivot_wider(names_from = station_id, values_from = log_pm25_avg, names_prefix = "station_")

# Display the first few rows of the aggregated data
head(station_data_wide)



## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=6, fig.show='hold', fig.align='center'----

ggplot(station_data_12h, aes(x=datetime_12h, y=log_pm25_avg, color=factor(station_id))) +
  geom_line() +
  geom_point() +
  labs(title="Log-Scaled PM2.5 Time Series for Selected Stations", x="Datetime", y="Log(PM2.5) 12-Hour Avg", color="Station ID") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, size = 25),
        legend.position = c(0.95, 0.84),
        axis.title = element_text(size = 20),      # Axis titles
        axis.text = element_text(size = 20),       # Axis text
        legend.title = element_text(size = 18),    # Legend title
        legend.text = element_text(size = 16),
        legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") )




## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=6, fig.show='hold', fig.align='center'----
# Define the DLM
build_dlm <- function(param) {
  m <- length(stations)
  V <- diag(exp(param[1:m]))  # Diagonal V
  sigma2 <- exp(param[m+1])   # Process variance
  phi <- exp(param[m+2])      # Decay parameter
  
  # Compute the distance matrix D
  coords <- matrix(c(-121.2479, 37.79339,   # Coordinates for station 41
                     -120.836, 37.48832,   # Coordinates for station 47
                     -115.3327, 36.17341, # Coordinates for station 96
                     -115.2383, 36.27059),    # Coordinates for station 99
                   ncol = 2, byrow = TRUE)
  
  D <- spDists(coords, longlat = FALSE)  # Distance matrix
  
  # Exponential covariance function
  W <- sigma2 * exp(-phi * D)
  
  # Define the DLM with random walk
  mod <- dlm::dlm(FF = diag(m), V = V, GG = diag(m), W = W, m0 = rep(0, m), C0 = diag(m))
  return(mod)
}

# Initial parameter values for optimization
init_params <- c(rep(1, length(stations) + 2))

# Fit the model using maximum likelihood
fit <- dlm::dlmMLE(as.matrix(station_data_wide[,-1]), parm = init_params, build = build_dlm, hessian = TRUE)

fitted_model <- build_dlm(fit$par)

# Estimated Parameters




## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=6, fig.show='hold', fig.align='center'----

#Printing the estiamted parameters
exp(fit$par)

# Deriving the Asymptotic Standard Error
AsymCov=solve(fit$hessian) 
sqrt(diag(AsymCov))

# Extract the estimated parameters
V_est <- fitted_model$V
W_est <- fitted_model$W

# Print the estimated parameters
V_est
W_est



## ----echo=FALSE, out.width='90%', fig.width=18, fig.height=9, fig.show='hold', fig.align='center'----


# Filter the time series with the fitted model
filtered <- dlmFilter(as.matrix(station_data_wide[,-1]), fitted_model)

n <- nrow(station_data_wide)
#one_step_ahead_pred <- filtered$m[n] # Last filtered state estimate

# Add one day to the last date in the series
last_datetime <- station_data_wide$datetime_12h[n]
next_datetime <- last_datetime + 24*60*60 

filtered$f[1,] = filtered$f[2,]

# One-step-ahead predictions
predictions <- dlmForecast(filtered, nAhead = 1)$a


colors <- c("Observed" = "grey40", "Future Prediction" = "red", "One-Step Ahead Forecast" = 'orange')

station = 1

ggplot(station_data_wide, aes(x = datetime_12h, y = station_41)) +
  geom_line(aes(color = "Observed")) +
  geom_point(aes(color = "Observed"), size = 3) +
  geom_line(aes(y = filtered$f[,station], color = "One-Step Ahead Forecast")) +
  geom_point(aes(y = filtered$f[,station], color = "One-Step Ahead Forecast"), size = 3) +
  #geom_ribbon(aes(ymin = smooth[,2], ymax = smooth[,3], color = '95% Probability Limits'), alpha = 0.2, fill = '95% Probability Limits') + # Adding the ribbon for smoothed confidence
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[station], color = "Future Prediction"), size = 3) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[station], color = "Future Prediction"), shape = 4, size = 5) + 
  labs(title = "Time Series of PM2.5 - Station 41", x = "Datetime", y = "Log(PM2.5) 12-Hour Avg", color = '') +
  scale_color_manual(values = colors) + 
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    legend.position = c(0.12, 0.91),
    plot.title = element_text(hjust = 0.5, size = 25),
        axis.title = element_text(size = 20),      # Axis titles
        axis.text = element_text(size = 20),       # Axis text
        #legend.title = element_text(size = 18),    # Legend title
        legend.text = element_text(size = 20),
        legend.title = element_blank(),   
        legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") ,
  )


## ----echo=FALSE, out.width='90%', fig.width=18, fig.height=9, fig.show='hold', fig.align='center'----


# Filter the time series with the fitted model
filtered <- dlmFilter(as.matrix(station_data_wide[,-1]), fitted_model)

n <- nrow(station_data_wide)
#one_step_ahead_pred <- filtered$m[n] # Last filtered state estimate

# Add one day to the last date in the series
last_datetime <- station_data_wide$datetime_12h[n]
next_datetime <- last_datetime + 24*60*60 

filtered$f[1,] = filtered$f[2,]

# One-step-ahead predictions
predictions <- dlmForecast(filtered, nAhead = 1)$a


colors <- c("Observed" = "grey40", "Future Prediction" = "red", "One-Step Ahead Forecast" = 'orange')

station = 2

ggplot(station_data_wide, aes(x = datetime_12h, y = station_47)) +
  geom_line(aes(color = "Observed")) +
  geom_point(aes(color = "Observed"), size = 3) +
  geom_line(aes(y = filtered$f[,station], color = "One-Step Ahead Forecast")) +
  geom_point(aes(y = filtered$f[,station], color = "One-Step Ahead Forecast"), size = 3) +
  #geom_ribbon(aes(ymin = smooth[,2], ymax = smooth[,3], color = '95% Probability Limits'), alpha = 0.2, fill = '95% Probability Limits') + # Adding the ribbon for smoothed confidence
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[station], color = "Future Prediction"), size = 3) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[station], color = "Future Prediction"), shape = 4, size = 5) + 
  labs(title = "Time Series of PM2.5 - Station 47", x = "Datetime", y = "Log(PM2.5) 12-Hour Avg", color = '') +
  scale_color_manual(values = colors) + 
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    legend.position = c(0.12, 0.91),
    plot.title = element_text(hjust = 0.5, size = 25),
        axis.title = element_text(size = 20),      # Axis titles
        axis.text = element_text(size = 20),       # Axis text
        #legend.title = element_text(size = 18),    # Legend title
        legend.text = element_text(size = 20),
        legend.title = element_blank(),   
        legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") ,
  )


## ----echo=FALSE, out.width='90%', fig.width=18, fig.height=9, fig.show='hold', fig.align='center'----


# Filter the time series with the fitted model
filtered <- dlmFilter(as.matrix(station_data_wide[,-1]), fitted_model)

n <- nrow(station_data_wide)
#one_step_ahead_pred <- filtered$m[n] # Last filtered state estimate

# Add one day to the last date in the series
last_datetime <- station_data_wide$datetime_12h[n]
next_datetime <- last_datetime + 24*60*60 

filtered$f[1,] = filtered$f[2,]

# One-step-ahead predictions
predictions <- dlmForecast(filtered, nAhead = 1)$a


colors <- c("Observed" = "grey40", "Future Prediction" = "red", "One-Step Ahead Forecast" = 'orange')

station = 3

ggplot(station_data_wide, aes(x = datetime_12h, y = station_96)) +
  geom_line(aes(color = "Observed")) +
  geom_point(aes(color = "Observed"), size = 3) +
  geom_line(aes(y = filtered$f[,station], color = "One-Step Ahead Forecast")) +
  geom_point(aes(y = filtered$f[,station], color = "One-Step Ahead Forecast"), size = 3) +
  #geom_ribbon(aes(ymin = smooth[,2], ymax = smooth[,3], color = '95% Probability Limits'), alpha = 0.2, fill = '95% Probability Limits') + # Adding the ribbon for smoothed confidence
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[station], color = "Future Prediction"), size = 3) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[station], color = "Future Prediction"), shape = 4, size = 5) + 
  labs(title = "Time Series of PM2.5 - Station 96", x = "Datetime", y = "Log(PM2.5) 12-Hour Avg", color = '') +
  scale_color_manual(values = colors) + 
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    legend.position = c(0.12, 0.91),
    plot.title = element_text(hjust = 0.5, size = 25),
        axis.title = element_text(size = 20),      # Axis titles
        axis.text = element_text(size = 20),       # Axis text
        #legend.title = element_text(size = 18),    # Legend title
        legend.text = element_text(size = 20),
        legend.title = element_blank(),   
        legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") ,
  )


## ----echo=FALSE, out.width='90%', fig.width=18, fig.height=9, fig.show='hold', fig.align='center'----


# Filter the time series with the fitted model
filtered <- dlmFilter(as.matrix(station_data_wide[,-1]), fitted_model)

n <- nrow(station_data_wide)
#one_step_ahead_pred <- filtered$m[n] # Last filtered state estimate

# Add one day to the last date in the series
last_datetime <- station_data_wide$datetime_12h[n]
next_datetime <- last_datetime + 24*60*60 

filtered$f[1,] = filtered$f[2,]

# One-step-ahead predictions
predictions <- dlmForecast(filtered, nAhead = 1)$a


colors <- c("Observed" = "grey40", "Future Prediction" = "red", "One-Step Ahead Forecast" = 'orange')

station = 4

ggplot(station_data_wide, aes(x = datetime_12h, y = station_99)) +
  geom_line(aes(color = "Observed")) +
  geom_point(aes(color = "Observed"), size = 3) +
  geom_line(aes(y = filtered$f[,station], color = "One-Step Ahead Forecast")) +
  geom_point(aes(y = filtered$f[,station], color = "One-Step Ahead Forecast"), size = 3) +
  #geom_ribbon(aes(ymin = smooth[,2], ymax = smooth[,3], color = '95% Probability Limits'), alpha = 0.2, fill = '95% Probability Limits') + # Adding the ribbon for smoothed confidence
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[station], color = "Future Prediction"), size = 3) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[station], color = "Future Prediction"), shape = 4, size = 5) + 
  labs(title = "Time Series of PM2.5 - Station 99", x = "Datetime", y = "Log(PM2.5) 12-Hour Avg", color = '') +
  scale_color_manual(values = colors) + 
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    legend.position = c(0.12, 0.91),
    plot.title = element_text(hjust = 0.5, size = 25),
        axis.title = element_text(size = 20),      # Axis titles
        axis.text = element_text(size = 20),       # Axis text
        #legend.title = element_text(size = 18),    # Legend title
        legend.text = element_text(size = 20),
        legend.title = element_blank(),   
        legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") ,
  )


## ----echo=FALSE, out.width='90%', fig.width=15, fig.height=9, fig.show='hold', fig.align='center'----
library(ggplot2)

# Filter the time series with the fitted model
filtered <- dlmFilter(as.matrix(station_data_wide[,-1]), fitted_model)

n <- nrow(station_data_wide)
#one_step_ahead_pred <- filtered$m[n] # Last filtered state estimate

# Add one day to the last date in the series
last_datetime <- station_data_wide$datetime_12h[n]
next_datetime <- last_datetime + 24*60*60 

filtered$f[1,] = filtered$f[2,]

# One-step-ahead predictions
predictions <- dlmForecast(filtered, nAhead = 1)$a


colors <- c("Observed" = "grey40", "Future Prediction" = "red", "One-Step Ahead Forecast" = 'orange')

# Combine the plot with a single legend
plot_1 = ggplot(station_data_wide, aes(x = datetime_12h, y = station_41)) +
  geom_line(aes(color = "Observed")) +
  geom_point(aes(color = "Observed"), size = 2) +
  geom_line(aes(y = filtered$f[,1], color = "One-Step Ahead Forecast")) +
  geom_point(aes(y = filtered$f[,1], color = "One-Step Ahead Forecast"), size = 2) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[1], color = "Future Prediction"), size = 2) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[1], color = "Future Prediction"), shape = 4, size = 3) + 
  labs(title = "Time Series of PM2.5 - Station 41", x = "Datetime", y = "PM2.5", color = '') +
  scale_color_manual(values = colors) + 
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    legend.position = c(0.25, 0.83),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_blank(),   
    legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid"),
    legend.text = element_text(size = 16)
    
  )

plot_2 = ggplot(station_data_wide, aes(x = datetime_12h, y = station_47)) +
  geom_line(aes(color = "Observed")) +
  geom_point(aes(color = "Observed"), size = 2) +
  geom_line(aes(y = filtered$f[,2], color = "One-Step Ahead Forecast")) +
  geom_point(aes(y = filtered$f[,2], color = "One-Step Ahead Forecast"), size = 2) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[2], color = "Future Prediction"), size = 2) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[2], color = "Future Prediction"), shape = 4, size = 3) + 
  labs(title = "Time Series of PM2.5 - Station 47", x = "Datetime", y = "PM2.5", color = '') +
  scale_color_manual(values = colors) + 
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    legend.position = c(0.25, 0.83),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_blank(),   
    legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid"),
    legend.text = element_text(size = 16)
  )

plot_3 = ggplot(station_data_wide, aes(x = datetime_12h, y = station_96)) +
  geom_line(aes(color = "Observed")) +
  geom_point(aes(color = "Observed"), size = 2) +
  geom_line(aes(y = filtered$f[,3], color = "One-Step Ahead Forecast")) +
  geom_point(aes(y = filtered$f[,3], color = "One-Step Ahead Forecast"), size = 2) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[3], color = "Future Prediction"), size = 2) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[3], color = "Future Prediction"), shape = 4, size = 3) + 
  labs(title = "Time Series of PM2.5 - Station 96", x = "Datetime", y = "PM2.5", color = '') +
  scale_color_manual(values = colors) + 
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    legend.position = c(0.25, 0.83),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_blank(),   
    legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") ,
    legend.text = element_text(size = 16)
  )

plot_4 = ggplot(station_data_wide, aes(x = datetime_12h, y = station_99)) +
  geom_line(aes(color = "Observed")) +
  geom_point(aes(color = "Observed"), size = 2) +
  geom_line(aes(y = filtered$f[,4], color = "One-Step Ahead Forecast")) +
  geom_point(aes(y = filtered$f[,4], color = "One-Step Ahead Forecast"), size = 2) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[4], color = "Future Prediction"), size = 2) +
  geom_point(aes(x = as.POSIXct(next_datetime), y = predictions[4], color = "Future Prediction"), shape = 4, size = 3) + 
  labs(title = "Time Series of PM2.5 - Station 99", x = "Datetime", y = "PM2.5", color = '') +
  scale_color_manual(values = colors) + 
  theme_bw()+
  theme(
    panel.background = element_rect(colour = "black", size=1),
    plot.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_line(color = "grey90"),
    axis.line = element_line(color = "black"),
    legend.position = c(0.25, 0.83),
    plot.title = element_text(hjust = 0.5, size = 25),
    axis.title = element_text(size = 20),      # Axis titles
    axis.text = element_text(size = 20),       # Axis text
    legend.title = element_blank(),   
    legend.background = element_rect(color = "black", fill = "white", size = 0.5, linetype = "solid") ,
    legend.text = element_text(size = 16)
  )

grid.arrange(plot_1, plot_2, plot_3, plot_4, ncol=2)



