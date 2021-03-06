
library(mlr)
library(ggplot2)
library(robustHD)
library(readr)
library(tidyverse)
data <- read_csv('ACMETelephoneABT.csv')
data$occupation[is.na(data$occupation)] = 'missing'

data_no_handling = data
data_no_handling$regionType[is.na(data_no_handling$regionType)] = 'missing'

data$customer = NULL

table(data$regionType)

data$regionType[data$regionType == 'r'] = 'rural'
data$regionType[data$regionType == 's'] = 'suburban'
data$regionType[data$regionType == 't'] = 'town'
data$regionType[data$regionType == 'unknown'] = NA


table(data$creditCard)

data$creditCard[data$creditCard == 'f'] = 'false'
data$creditCard[data$creditCard == 'no'] = 'false'
data$creditCard[data$creditCard == 't'] = 'true'
data$creditCard[data$creditCard == 'yes'] = 'true'

table(data$numHandsets)

table(data$currentHandsetPrice)

hist(data$age)

data$age[data$age == 0] = NA

data = as.data.frame(unclass(data), stringsAsFactors=TRUE)

imp = impute(data, 
             target = "churn", # Tell the algorithm not to use information in the target column for imputation.
             cols = list(
               regionType = imputeLearner("classif.cforest"),
               age = imputeLearner("regr.cforest")
             )
)


table(imp$data$regionType)

hist(imp$data$age)


data_imputed = imp$data

data_imputed$regionType = data$regionType
levels(data_imputed$regionType) = c(levels(data_imputed$regionType), 'missing')
data_imputed$regionType[is.na(data_imputed$regionType)] = 'missing'


library(MASS)
x = log(data_imputed$currentHandsetPrice + 1)
fit <- fitdistr(x, "normal")
para <- fit$estimate
hist(x, prob = TRUE, breaks = 30)
curve(dnorm(x, para[1], para[2]), col = 2, add = TRUE)


data_imputed$numHandsets = log(data_imputed$numHandsets)
data_imputed$currentHandsetPrice = log(data_imputed$currentHandsetPrice + 1)
data_imputed$avgOverBundleMins = log(data_imputed$avgOverBundleMins + 1)
data_imputed$avgRoamCalls = log(data_imputed$avgRoamCalls + 1)
data_imputed$avgReceivedMins = log(data_imputed$avgReceivedMins + 1)
data_imputed$avgOutCalls = log(data_imputed$avgOutCalls + 1)
data_imputed$avgInCalls = log(data_imputed$avgInCalls + 1)
data_imputed$peakOffPeakRatio = log(data_imputed$peakOffPeakRatio + 1)
data_imputed$avgDroppedCalls = log(data_imputed$avgDroppedCalls + 1)
data_imputed$lastMonthCustomerCareCalls = log(data_imputed$lastMonthCustomerCareCalls + 1)
data_imputed$numRetentionCalls = log(data_imputed$numRetentionCalls + 1)
data_imputed$numRetentionOffersAccepted = log(data_imputed$numRetentionOffersAccepted + 1)
data_imputed$newFrequentNumbers = log(data_imputed$newFrequentNumbers + 1)


numerical_col_index <- unlist(lapply(data_imputed, is.numeric))  # For all numerical columns
data_standardised = lapply(data_imputed[ , numerical_col_index], standardize) # Standardise it


mean(data_standardised$currentHandsetPrice)
sd(data_standardised$currentHandsetPrice)


categorical_col_index = !numerical_col_index
data_standardised = cbind(data_standardised, data_imputed[ , categorical_col_index])


data_dummified = createDummyFeatures(data_standardised, target = 'churn', method = "reference", cols = NULL)
write.csv(data_dummified, 'data_standarised.csv', row.names = FALSE)






