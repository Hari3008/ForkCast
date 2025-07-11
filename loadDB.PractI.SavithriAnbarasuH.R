# Program Name: loadDB.Pract1.SavithriAnbarasuH.R (Part E -> Populate Database)
# Author: Hariharasudan Savithri Anbarasu
# Semester: Full Summer 2025

# Load required libraries
if (!require("RMySQL")) install.packages("RMySQL")
if (!require("DBI")) install.packages("DBI")

library(RMySQL)
library(DBI)

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

# Function to clean and handle sentinel values
clean_data <- function(df) {
  df_clean <- df
  
  # Handle date sentinel values
  df_clean$StartDateHired[df_clean$StartDateHired == "0000-00-00"] <- NA
  df_clean$EndDateHired[df_clean$EndDateHired == "0000-00-00"] <- NA
  df_clean$ServerBirthDate[df_clean$ServerBirthDate == "0000-00-00"] <- NA
  df_clean$VisitDate[df_clean$VisitDate == "0000-00-00"] <- NA
  
  # Handle party size sentinel value (99 -> unknown)
  df_clean$PartySize[df_clean$PartySize == 99] <- 1
  
  # Handle missing or invalid numeric values
  df_clean$WaitTime[is.na(df_clean$WaitTime) | df_clean$WaitTime < 0] <- 0
  df_clean$FoodBill[is.na(df_clean$FoodBill)] <- 0
  df_clean$TipAmount[is.na(df_clean$TipAmount)] <- 0
  df_clean$AlcoholBill[is.na(df_clean$AlcoholBill)] <- 0
  df_clean$DiscountApplied[is.na(df_clean$DiscountApplied)] <- 0
  df_clean$HourlyRate[is.na(df_clean$HourlyRate)] <- 0
  
  # Handle boolean values
  df_clean$LoyaltyMember <- as.logical(df_clean$LoyaltyMember)
  df_clean$LoyaltyMember[is.na(df_clean$LoyaltyMember)] <- FALSE
  
  # Handle missing names - Replace with "Unknown"
  df_clean$CustomerName[is.na(df_clean$CustomerName) | df_clean$CustomerName == ""] <- "Unknown"
  df_clean$ServerName[is.na(df_clean$ServerName) | df_clean$ServerName == ""] <- "Unknown"
  
  # Trim whitespace from character fields
  char_cols <- sapply(df_clean, is.character)
  df_clean[char_cols] <- lapply(df_clean[char_cols], trimws)
  
  return(df_clean)
}

# Function to escape strings for SQL - Handling NULL values, data type conversion
sql_escape <- function(x) {
  if (is.null(x) || is.na(x) || x == "") {
    return("NULL")
  } else if (is.character(x)) {
    x <- gsub("'", "''", x) # Escape single quotes by doubling them
    return(paste0("'", x, "'"))
  } else if (is.logical(x)) {
    return(ifelse(x, "1", "0"))
  } else {
    return(as.character(x))
  }
}

loadRestaurants <- function(con, df.clean){
  restaurants <- unique(df.clean[!is.na(df.clean$Restaurant) & df.clean$Restaurant != "", "Restaurant", drop = FALSE])
  names(restaurants)[1] <- "RestaurantName"
  
  # Insert restaurants one by one to handle duplicates
  for (i in 1:nrow(restaurants)) {
    insertRestSql <- sprintf("INSERT IGNORE INTO Restaurants (RestaurantName) VALUES (%s)",
                             sql_escape(restaurants$RestaurantName[i]))
    dbExecute(con, insertRestSql)
  }
  
  # Get restaurant IDs for mapping
  restaurant_map <- dbGetQuery(con, "SELECT RestaurantID, RestaurantName FROM Restaurants")
  cat("Restaurants loaded:", nrow(restaurant_map), "\n")
  return(restaurant_map)
}


loadServers <- function(con, df.clean){
  # Extract unique servers
  server_cols <- c("ServerEmpID", "ServerName", "StartDateHired", "EndDateHired", 
                   "HourlyRate", "ServerBirthDate", "ServerTIN")
  servers_all <- df.clean[!is.na(df.clean$ServerEmpID), server_cols]
  
  # Remove duplicates based on ServerEmpID
  servers <- servers_all[!duplicated(servers_all$ServerEmpID), ]
  
  # Insert servers
  for (i in 1:nrow(servers)) {
    insertServerSql <- sprintf("INSERT IGNORE INTO Servers (ServerEmpID, ServerName, StartDateHired, 
          EndDateHired, HourlyRate, ServerBirthDate, ServerTIN) 
          VALUES (%s, %s, %s, %s, %s, %s, %s)",
                               sql_escape(servers$ServerEmpID[i]),
                               sql_escape(servers$ServerName[i]),
                               sql_escape(servers$StartDateHired[i]),
                               sql_escape(servers$EndDateHired[i]),
                               sql_escape(servers$HourlyRate[i]),
                               sql_escape(servers$ServerBirthDate[i]),
                               sql_escape(servers$ServerTIN[i]))
    
    dbExecute(con, insertServerSql)
  }
  
  server_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM Servers")$count
  cat("Servers loaded:", server_count, "\n")
  
}


loadCustomers <- function(con,df.clean){
  customer_cols <- c("CustomerName", "CustomerPhone", "CustomerEmail", "LoyaltyMember")
  customers_all <- df.clean[(!is.na(df.clean$CustomerEmail) | !is.na(df.clean$CustomerPhone)), customer_cols]
  
  # Remove duplicates based on CustomerEmail
  customers <- customers_all[!duplicated(customers_all$CustomerEmail), ]
  
  # Insert customers
  for (i in 1:nrow(customers)) {
    insertCustsql <- sprintf("INSERT IGNORE INTO Customers (CustomerName, CustomerPhone, 
          CustomerEmail, LoyaltyMember) VALUES (%s, %s, %s, %s)",
                             sql_escape(customers$CustomerName[i]),
                             sql_escape(customers$CustomerPhone[i]),
                             sql_escape(customers$CustomerEmail[i]),
                             sql_escape(customers$LoyaltyMember[i]))
    
    dbExecute(con, insertCustsql)
  }
  
  # Get customer IDs for mapping
  customer_map <- dbGetQuery(con, "SELECT CustomerID, CustomerEmail, CustomerPhone FROM Customers")
  cat("Customers loaded:", nrow(customer_map), "\n")
  return(customer_map)
}


# Function to create batch insert SQL
create_batch_insert <- function(data, start_row, end_row) {
  batch <- data[start_row:end_row, ]
  
  # Create VALUES clauses for each row
  values_clauses <- apply(batch, 1, function(row) {
    sprintf("(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
            sql_escape(row["VisitID"]),
            sql_escape(row["RestaurantID"]),
            sql_escape(row["ServerEmpID"]),
            sql_escape(row["CustomerID"]),
            sql_escape(row["VisitDate"]),
            sql_escape(row["VisitTime"]),
            sql_escape(row["MealType"]),
            sql_escape(row["PartySize"]),
            sql_escape(row["Genders"]),
            sql_escape(row["WaitTime"]),
            sql_escape(row["FoodBill"]),
            sql_escape(row["TipAmount"]),
            sql_escape(row["DiscountApplied"]),
            sql_escape(row["PaymentMethod"]),
            sql_escape(if (is.na(row["orderedAlcohol"]) || row["orderedAlcohol"] == "") "No" else row["orderedAlcohol"]),
            sql_escape(row["AlcoholBill"]))
  })
  
  # Combining into single INSERT command
  sql <- sprintf("INSERT INTO Visits (VisitID, RestaurantID, ServerEmpID, CustomerID,
          VisitDate, VisitTime, MealType, PartySize, Genders, WaitTime,
          FoodBill, TipAmount, DiscountApplied, PaymentMethod, 
          orderedAlcohol, AlcoholBill) VALUES %s",
                 paste(values_clauses, collapse = ", "))
  
  return(sql)
}


loadVisits <- function(con, df.clean, restaurant_map, customer_map){
  # Merge with restaurant IDs
  visits <- df.clean
  visits$RestaurantID <- restaurant_map$RestaurantID[match(visits$Restaurant, restaurant_map$RestaurantName)]
  
  # Merge with customer IDs
  visits$CustomerID <- customer_map$CustomerID[match(visits$CustomerEmail, customer_map$CustomerEmail)]
  
  # Prepare visits data
  visit_cols <- c("VisitID", "RestaurantID", "ServerEmpID", "CustomerID", "VisitDate", "VisitTime",
                  "MealType", "PartySize", "Genders", "WaitTime", "FoodBill", "TipAmount",
                  "DiscountApplied", "PaymentMethod", "orderedAlcohol", "AlcoholBill")
  
  visits_to_insert <- visits[!is.na(visits$VisitID), visit_cols]
  
  cat("Preparing to insert", nrow(visits_to_insert), "visits\n")
  
  # Insert visits in larger batches for better performance 
  batch_size <- 2000
  inserted_visits <- 0
  
  for (i in seq(1, nrow(visits_to_insert), by = batch_size)) {
    end_row <- min(i + batch_size - 1, nrow(visits_to_insert)) # last row of current batch
    # Create batch insert SQL
    batch_sql <- create_batch_insert(visits_to_insert, i, end_row)
    # Execute batch insert
    if (dbExecute(con, batch_sql)) {
      inserted_visits <- inserted_visits + (end_row - i + 1)
    } else {
      cat(sprintf("Failed to insert batch"))
    }
    
  }
  cat("Visits loaded:", inserted_visits, "\n")
}

main <- function(){
  # CSV filename
  csv_url <- "https://s3.us-east-2.amazonaws.com/artificium.us/datasets/restaurant-visits-139874.csv"
  # Load the data
  df.orig <- read.csv(csv_url, stringsAsFactors = FALSE)
  cat("Loaded data from csv to df.orig\n")
  
  # Connect to DB
  con = connectDB()
  
  # Clean the data
  df.clean <- clean_data(df.orig)
  cat("Cleaned data and handled sentinel values\n")
  
  # Load Restaurants
  restaurant_map <- loadRestaurants(con,df.clean)
  
  # Load Customers
  customer_map <- loadCustomers(con, df.clean)
  
  # Load Servers
  loadServers(con, df.clean)
  
  # Load Visits
  loadVisits(con, df.clean, restaurant_map, customer_map)
  
  # Disconnect from database
  dbDisconnect(con)
  cat("\nDB disconnected\n")
}

main()