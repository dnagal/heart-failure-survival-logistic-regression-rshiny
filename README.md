# heart-failure-survival-logistic-regression-rshiny
Logistic regression analysis of heart failure clinical data, including assumption checking and model validation, with an interactive R Shiny app for mortality probability estimation.

This project uses the Heart Failure Clinical Records dataset from the UCI Repository to perform logistic regression and represents my first attempt with this machine learning method.The goal is to determine whether a model can predict survival or death based on clinical data for patients who experienced heart failure.

Exploratory Data Analysis (EDA):
Before modeling, EDA was conducted to explore relationships between clinical variables and survival outcomes:
Age: Boxplots comparing age by death_event (0 = survived, 1 = deceased) show that patients who survived were generally younger. Distributions were right-skewed for both groups.
Ejection Fraction: Clinically described as “the percentage of blood leaving the heart at each contraction”, boxplots suggest that survivors tended to have higher ejection fraction rates.

These analyses helped identify potentially important predictors for logistic regression.

Prior to model development, key logistic regression assumptions were evaluated to ensure the dataset was appropriate for analysis. The outcome variable satisfied the binary requirement, and independence of observations was assumed as each record represented a unique patient. Linearity of the logit for continuous predictors was assessed using the Box–Tidwell test, which revealed that serum creatinine did not exhibit a linear relationship with the log-odds of death; as a result, this variable was log-transformed. Multicollinearity was examined using the Variance Inflation Factor (VIF), and results indicated that predictor correlation was not a concern.

Logistic Regression Modeling:
Reproducibility was ensured with set.seed(123).

The caret package was used to split the dataset: 80% training, 20% testing.

A logistic regression model was fit using all variables. The training model had an AIC of 199.45.

Odds ratios were calculated by exponentiating the coefficients, with confidence intervals reported for each predictor.

Prediction:
Predictions were made on the unobserved test data.

A threshold of 0.5 was used to classify outcomes:

  ≥ 0.5 → class = 1 (event occurred)

  < 0.5 → class = 0 (event did not occur)

Model Performance:
The model was evaluated using a confusion matrix and standard classification metrics:
  Accuracy: 77.97% (correctly classifies ~4 of every 5 observations)

  No Information Rate: 69.49% (difference not statistically significant at p = 0.099)

  Sensitivity: 85.37% (highly effective at identifying survivors, class 0)

  Specificity: 61.11% (lower, indicating more difficulty identifying deaths, class 1)

  AUC: 0.7818 (model reliably distinguishes positive vs. negative cases)

The model balances predictive accuracy with clinical relevance, retaining significant continuous variables.

R Shiny Application:
An interactive R Shiny app is included. Feel free to adjust the clinical variable results to calculate a predicted probability of death. Experiment with the app to explore predictions based on different patient profiles!
