# Air Pollution Dynamics Modeling

This repository contains the project "Air Pollution Dynamics Modeling," which focuses on analyzing and predicting air pollution levels using hourly air quality data from the U.S. West Coast during the summer of 2020.

## Overview

The project aims to:
- Model PM2.5 pollution levels using Hidden Markov Models (HMMs) and Dynamic Linear Models (DLMs).
- Provide real-time pollution level predictions.
- Incorporate spatial dependencies to improve forecasting accuracy.

## Data

Hourly data includes PM2.5 concentrations, temperature, wind speed, and station locations, provided by the U.S. EPA.

## Methodology

- **Hidden Markov Models (HMMs)**: Both univariate and multivariate HMMs are used to estimate pollution levels. The univariate models focus solely on PM2.5 data, while the multivariate models incorporate additional covariates such as temperature and wind speed to improve prediction accuracy.

- **Dynamic Linear Models (DLMs)**: These models are based on Bayesian statistics for time series analysis. DLMs are particularly well-suited for modeling time-varying dynamics and handling missing data, which is common in environmental datasets. The Bayesian framework allows for flexible modeling of uncertainty and provides a robust way to update predictions as new data becomes available.

- **Spatial-Temporal Models**: Extending the DLM approach, these models incorporate spatial dependencies between monitoring stations to enhance prediction accuracy across multiple locations. By modeling the spatial relationships between stations, the spatial-temporal models can better capture regional pollution dynamics and provide more reliable short-term forecasts.

## Results

The models effectively predict pollution levels and identify high-pollution events, with spatial-temporal models providing the most robust results due to their ability to incorporate both temporal and spatial dependencies.
