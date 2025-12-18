#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(pROC)

#load saved objects from logistic regression r script
load("/Users/darrylnagal/Winter Break Project 2025/logistic_model.RData")  # loads object: model
load("/Users/darrylnagal/Winter Break Project 2025/test_data.RData")       # loads object: test

#renaming for clarity inside Shiny
logistic_model <- model
test_data <- test

#ui
ui <- fluidPage(
  titlePanel("Heart Failure Survival Prediction (Logistic Regression)"),
  sidebarLayout(
    sidebarPanel(
      h4("Patient Clinical Inputs"),
      numericInput("age", "Age:", value = 60, min = 40, max = 95),
      selectInput("anaemia", "Anaemia:", choices = c("No" = 0, "Yes" = 1)),
      numericInput("creatinine_phosphokinase",
                   "Creatinine Phosphokinase:",
                   value = 250, min = 23, max = 7861),
      selectInput("diabetes", "Diabetes:", choices = c("No" = 0, "Yes" = 1)),
      numericInput("ejection_fraction",
                   "Ejection Fraction (%):",
                   value = 35, min = 0, max = 100),
      selectInput("high_blood_pressure",
                  "High Blood Pressure:",
                  choices = c("No" = 0, "Yes" = 1)),
      numericInput("platelets",
                   "Platelets:",
                   value = 262000, min = 25100, max = 850000),
      numericInput("serum_creatinine",
                   "Serum Creatinine:",
                   value = 1.1, min = 0.5, max = 9.4),
      numericInput("serum_sodium",
                   "Serum Sodium:",
                   value = 137, min = 113, max = 148),
      selectInput("sex", "Sex:", choices = c("Female" = 0, "Male" = 1)),
      selectInput("smoking", "Smoking:", choices = c("No" = 0, "Yes" = 1)),
      numericInput("time", "Follow-up Time (days):", value = 100, min = 0)
    ),
    mainPanel(
      h3("Model Output"),
      h4("Predicted Probability of Death"),
      verbatimTextOutput("prediction"),
      hr(), #line going through the text, like an outline
      h4("Model Performance (Test Set)"),
      plotOutput("rocPlot"),
      verbatimTextOutput("confMatrix")
    )
  )
)

# server
server <- function(input, output) {
  
  # Create reactive dataframe from inputs
  new_patient <- reactive({
    data.frame(
      age = input$age,
      anaemia = as.numeric(input$anaemia),
      creatinine_phosphokinase = input$creatinine_phosphokinase,
      diabetes = as.numeric(input$diabetes),
      ejection_fraction = input$ejection_fraction,
      high_blood_pressure = as.numeric(input$high_blood_pressure),
      platelets = input$platelets,
      serum_creatinine = input$serum_creatinine,
      serum_sodium = input$serum_sodium,
      sex = as.numeric(input$sex),
      smoking = as.numeric(input$smoking),
      time = input$time
    )
  })
  
  # prediction
  output$prediction <- renderPrint({
    prob <- predict(logistic_model, new_patient(), type = "response")
    paste0(round(prob, 3),
           "  → probability of death (DEATH_EVENT = 1)")
  })
  
  # roc curve
  output$rocPlot <- renderPlot({
    probs <- predict(logistic_model, test_data, type = "response")
    roc_obj <- roc(test_data$DEATH_EVENT, probs)
    plot(
      roc_obj,
      main = paste("ROC Curve (AUC =", round(auc(roc_obj), 3), ")")
    )
  })
  
  # confusion matrix
  output$confMatrix <- renderPrint({
    probs <- predict(logistic_model, test_data, type = "response")
    preds <- ifelse(probs > 0.5, 1, 0)
    
    table(
      Predicted = preds,
      Actual = test_data$DEATH_EVENT
    )
  })
}

shinyApp(ui = ui, server = server)

