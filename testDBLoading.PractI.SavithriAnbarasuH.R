# Program Name: testDBLoading.PractI.SavithriAnbarasuH.R (Part F -> Test Data Loading Process)
# Author: Hariharasudan Savithri Anbarasu
# Semester: Full Summer 2025

# Load required libraries
if (!require("RMySQL")) install.packages("RMySQL")
if (!require("DBI")) install.packages("DBI")
if (!require("testthat")) install.packages("testthat")

library(RMySQL)
library(DBI)
library(testthat)

connectDB <- function(){
  # Database connection parameters
  db_user <- "avnadmin"
  db_password <- "AVNS_s5fw-5CC0zMcdySooAU"
  db_host <- "mysql-practicum-1-practicum-1-hariharasudan.f.aivencloud.com"
  db_port <- 28796
  db_name <- "defaultdb"
  
  # DB Connection
  tryCatch({
    con <- dbConnect(
      MySQL(),
      user = db_user,
      password = db_password,
      host = db_host,
      port = db_port,
      dbname = db_name
    )
    cat("Connected to DB\n")
  }, error = function(e) {
    cat("Error:", e$message, "\n")
    stop("Program ends since DB connection failed.")
  })
  
  return(con)
}

# Tests which check if the count in the tables match with the CSV
tableCountTest <- function(con, df_original){
  test_that("Unique restaurants count matches CSV", {
    csv_restaurants <- length(unique(df_original$Restaurant[!is.na(df_original$Restaurant) & df_original$Restaurant != ""]))
    
    db_restaurants <- dbGetQuery(con, "SELECT COUNT(*) as count FROM Restaurants")$count
    
    expect_equal(db_restaurants, csv_restaurants, 
                 info = paste("Expected", csv_restaurants, "restaurants, got", db_restaurants))
    print(paste0("Restaurant DB count matches CSV - ",db_restaurants))
  })
  
  test_that("Unique customers count matches CSV", {
    customers_with_contact <- df_original[!is.na(df_original$CustomerEmail) | !is.na(df_original$CustomerPhone), ]
    csv_customers <- length(unique(customers_with_contact$CustomerEmail))
    
    db_customers <- dbGetQuery(con, "SELECT COUNT(*) as count FROM Customers")$count
    
    expect_equal(db_customers, csv_customers,
                 info = paste("Expected", csv_customers, "customers, got", db_customers))
    print(paste0("Customer DB count matches CSV - ",db_customers))
  })
  
  test_that("Unique servers count matches CSV", {
    csv_servers <- length(unique(df_original$ServerEmpID[!is.na(df_original$ServerEmpID)]))
    
    db_servers <- dbGetQuery(con, "SELECT COUNT(*) as count FROM Servers")$count
    
    expect_equal(db_servers, csv_servers,
                 info = paste("Expected", csv_servers, "servers, got", db_servers))
    print(paste0("Server DB count matches CSV - ",db_servers))
  })
  
  test_that("Total visits count matches CSV", {
    csv_visits <- sum(!is.na(df_original$VisitID))
    
    db_visits <- dbGetQuery(con, "SELECT COUNT(*) as count FROM Visits")$count
    
    expect_equal(db_visits, csv_visits,
                 info = paste("Expected", csv_visits, "visits, got", db_visits))
    print(paste0("Visits DB count matches CSV - ",db_visits))
  })
  
}

# Tests which check if the total amount in the table match with the CSV
amountSpentTest <- function(con, df_original){
  test_that("Total food bill matches CSV", {
    csv_food_total <- sum(df_original$FoodBill[!is.na(df_original$FoodBill)])
    
    db_food_total <- dbGetQuery(con, "SELECT CAST(SUM(FoodBill) AS DOUBLE) as total FROM Visits")
    
    expect_equal(as.numeric(db_food_total), as.numeric(csv_food_total), tolerance = 0.01,
                 info = paste("Food bill totals don't match. CSV:", csv_food_total, 
                              "DB:", db_food_total))
    print(paste0("Total food bill DB amount matches CSV - ",db_food_total))
  })
  
  test_that("Total alcohol bill matches CSV", {
    csv_alcohol_total <- sum(df_original$AlcoholBill[!is.na(df_original$AlcoholBill)])
    
    db_alcohol_total <- dbGetQuery(con, "SELECT CAST(SUM(AlcoholBill) AS DOUBLE) as total FROM Visits")
    
    expect_equal(as.numeric(db_alcohol_total), as.numeric(csv_alcohol_total), tolerance = 0.01,
                 info = paste("Alcohol bill totals don't match. CSV:", csv_alcohol_total,
                              "DB:", db_alcohol_total))
    print(paste0("Total Alcohol bill DB amount matches CSV - ",db_alcohol_total))
  })
  
  test_that("Total tips amount matches CSV", {
    csv_tips_total <- sum(df_original$TipAmount[!is.na(df_original$TipAmount)])
    
    db_tips_total <- dbGetQuery(con, "SELECT CAST(SUM(TipAmount) AS DOUBLE) as total FROM Visits")
    
    
    expect_equal(as.numeric(db_tips_total), as.numeric(csv_tips_total), tolerance = 0.01,
                 info = paste("Tips totals don't match. CSV:", csv_tips_total,
                              "DB:", db_tips_total))
    print(paste0("Total tips bill DB amount matches CSV - ",db_tips_total))
  })
}
  

main <- function(){
  # Connect to DB
  con <-  connectDB()
  
  # Load original CSV data
  csv_url <- "https://s3.us-east-2.amazonaws.com/artificium.us/datasets/restaurant-visits-139874.csv"
  df_original <- read.csv(csv_url, stringsAsFactors = FALSE)
  
  tableCountTest(con, df_original)
  
  amountSpentTest(con, df_original)
  
  # Disconnect from database
  dbDisconnect(con)
  cat("\nDB disconnected\n")
}

main()