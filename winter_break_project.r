#binary logistic regression winter break solo project :D 

#installing tidyverse library
library(tidyverse)

#creating a new dataframe called hf for heart failure dataset 
hf <- read.csv("~/Desktop/heart_failure_clinical_records_dataset.csv")

#quick glances at the datasets
str(hf)
summary(hf)
#DEATH_EVENT is confirmed as binary variable which is needed for logistic regression

#exploratory data analysis 
#age by outcome.- age compared to death event
hf %>%
  ggplot(aes(x = factor(DEATH_EVENT), y = age)) +
  geom_boxplot() +
  labs(x = "Death Event", y = "Age")

#ejection fraction vs outcome
hf %>%
  ggplot(aes(x = factor(DEATH_EVENT), y = ejection_fraction)) +
  geom_boxplot()
#ejection fraction refers to the percentage of blood leaving the heart at each contraction

#checking assumptions for logistic regression
#box-tidwell***
hf$DEATH_EVENT <- as.numeric(as.character(hf$DEATH_EVENT))

# Check for missing or invalid values
summary(hf$age)
summary(hf$serum_creatinine)
summary(hf$platelets)

# Drop rows with NA or <= 0 (Box-Tidwell requires positive values)
hf_bt <- hf[ hf$age > 0 & hf$serum_creatinine > 0 & hf$platelets > 0, ]

hf_bt$age_ln        <- hf_bt$age * log(hf_bt$age)
hf_bt$creatinine_ln <- hf_bt$serum_creatinine * log(hf_bt$serum_creatinine)
hf_bt$platelets_ln  <- hf_bt$platelets * log(hf_bt$platelets)

bt_model <- glm(
  hf$DEATH_EVENT ~ age + age_ln +
    serum_creatinine + creatinine_ln +
    platelets + platelets_ln,
  family = binomial(link = "logit"),
  data = hf_bt
)

print(summary(bt_model))
#The linearity of the logit was assessed using Box–Tidwell interaction terms.
#platelets and age satisfied the assumption (p > 0.05), while serum_creatinine
#violated linearity (p = 0.002), indicating a potential need for transformation
#or alternative modeling for this predictor.

#log transformation for serum creatinine 
hf_bt$log_creatinine <- log(hf_bt$serum_creatinine)

#verifying transformation 
bt_model_fixed <- glm(
  hf_bt$DEATH_EVENT ~ age + log_creatinine + platelets,
  family = binomial,
  data = hf_bt
)

print(summary(bt_model_fixed))
#All predictors now satisfy the linearity assumption 
#(Box–Tidwell no longer needed since creatinine is log-transformed)

#==================
#calculating VIF
install.packages("car")
library(car)

#fiting logistic regression model (without Box-Tidwell terms)
logit_model <- glm(
  DEATH_EVENT ~ age + serum_creatinine + platelets,
  family = binomial(link = "logit"),
  data = hf
)

#compute VIFs
vif(logit_model)
#VIF <5 for age, serum creatinine, and platelets suggesting that multicollinearity is not an issue 

#train/test split
set.seed(123)
#used so that we can always return something reproducible - needed for machine learning

#installing caret to allow for createDataPartition
install.packages("caret")
library(caret)

#creating a training and test split where 80% of the data will go to training and 20% on unseen testing data
train_index <- createDataPartition(hf_bt$DEATH_EVENT, p = 0.8, list = FALSE)
train <- hf_bt[train_index, ]
test  <- hf_bt[-train_index, ]

#logistic regression model
model <- glm(
  DEATH_EVENT ~ age + anaemia + creatinine_phosphokinase +
    diabetes + ejection_fraction + high_blood_pressure +
    platelets + serum_creatinine + serum_sodium +
    sex + smoking + time,
  data = train,
  family = binomial
)

summary(model)

#interpreting coefficients
exp(cbind(
  OR = coef(model),
  confint(model)
))

#making predictions
test$prob <- predict(model, newdata = test, type = "response")
test$pred <- ifelse(test$prob > 0.5, 1, 0)

#convert both prediction and actual to factors with same levels
test$pred <- factor(test$pred, levels = c(0, 1))
test$death_event <- factor(test$DEATH_EVENT, levels = c(0, 1))

#run confusion matrix using the factor columns
confusionMatrix(test$pred, test$death_event)

#installing roc package
install.packages("pROC")
library(pROC)

#roc curve + auc
roc_obj <- roc(test$death_event, test$prob)
auc(roc_obj)

plot(roc_obj)

getwd()

# saving this project 
save(model, file = "/Users/darrylnagal/Winter Break Project 2025/logistic_model.RData")
save(test, file = "/Users/darrylnagal/Winter Break Project 2025/test_data.RData")

#checking the min and max values for all variables in the dataset for r shiny application
#age
min(hf$age)
max(hf$age)
median(hf$age)

library(ggplot2)
ggplot(hf, aes(x = age)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Age",
    x = "Age",
    y = "Count"
  )

#creatinine_phosphokinase
min(hf$creatinine_phosphokinase)
max(hf$creatinine_phosphokinase)
median(hf$creatinine_phosphokinase)

ggplot(hf, aes(x = creatinine_phosphokinase)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Creatinine Phosphokinase",
    x = "Creatinine Phosphokinase",
    y = "Count"
  )

#platelets 
min(hf$platelets)
max(hf$platelets)
median(hf$platelets)

ggplot(hf, aes(x = platelets)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Platelets",
    x = "Platelets",
    y = "Count"
  )

#serum creatinine 
min(hf$serum_creatinine)
max(hf$serum_creatinine)
median(hf$serum_creatinine)

ggplot(hf, aes(x = serum_creatinine)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Serum Creatinine",
    x = "Serum Creatinine",
    y = "Count"
  )

#serum sodium 
min(hf$serum_sodium)
max(hf$serum_sodium)
median(hf$serum_sodium)

ggplot(hf, aes(x = serum_sodium)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Serum Sodium",
    x = "Serum Sodium",
    y = "Count"
  )