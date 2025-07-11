# Program Name : createDB.PractI.SavithriAnbarasuH.R (Part C -> Realise Database)
# Name: Hariharasudan Savithri Anbarasu
# Semester: Full Summer 2025

# Install packages
if (!require("RMySQL")) install.packages("RMySQL")
if (!require("DBI")) install.packages("DBI")

library(RMySQL)
library(DBI)

connectDB  <- function() {
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

dropTables <- function(con){
  cat("Dropping existing tables if they exist\n\n")
  dropVisitsSQL <- "DROP TABLE IF EXISTS Visits"
  dbExecute(con, dropVisitsSQL)
  dropCustomersSQL <- "DROP TABLE IF EXISTS Customers"
  dbExecute(con, dropCustomersSQL)
  dropServersSQL <- "DROP TABLE IF EXISTS Servers"
  dbExecute(con, dropServersSQL)
  dropRestaurantsSQL <- "DROP TABLE IF EXISTS Restaurants"
  dbExecute(con, dropRestaurantsSQL)
}

createTables <- function(con){
  # Create Restaurants table
  createRestaurantsSql <- "
CREATE TABLE IF NOT EXISTS Restaurants (
    RestaurantID INT AUTO_INCREMENT PRIMARY KEY,
    RestaurantName VARCHAR(100) NOT NULL,
    UNIQUE KEY unique_restaurant_name (RestaurantName)
);
"
  dbExecute(con, createRestaurantsSql)
  
  # Create Servers table
  createServersSql <- "
CREATE TABLE IF NOT EXISTS Servers (
    ServerEmpID INT PRIMARY KEY,
    ServerName VARCHAR(100) NOT NULL,
    StartDateHired DATE DEFAULT NULL,
    EndDateHired DATE DEFAULT NULL,
    HourlyRate DECIMAL(10,2) DEFAULT 0.00,
    ServerBirthDate DATE DEFAULT NULL,
    ServerTIN VARCHAR(20) DEFAULT NULL,
    UNIQUE KEY unique_server_tin (ServerTIN),
    CONSTRAINT chk_hourly_rate CHECK (HourlyRate >= 0),
    CONSTRAINT chk_dates CHECK (EndDateHired IS NULL OR EndDateHired >= StartDateHired)
);"
  dbExecute(con, createServersSql)
  
  # Create Customers table
  createCustomersSql <- "
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerPhone VARCHAR(20) DEFAULT NULL,
    CustomerEmail VARCHAR(100) DEFAULT NULL,
    LoyaltyMember BOOLEAN DEFAULT FALSE,
    UNIQUE KEY unique_email (CustomerEmail),
    UNIQUE KEY unique_phone (CustomerPhone)
);"
  dbExecute(con, createCustomersSql)
  
  # Create Visits table
  createVisitsSql <- "
CREATE TABLE IF NOT EXISTS Visits (
    VisitID INT PRIMARY KEY,
    RestaurantID INT NOT NULL,
    ServerEmpID INT DEFAULT NULL,
    CustomerID INT DEFAULT NULL,
    VisitDate DATE NOT NULL,
    VisitTime TIME DEFAULT NULL,
    MealType VARCHAR(50) DEFAULT NULL,
    PartySize INT DEFAULT 1,
    Genders VARCHAR(50) DEFAULT NULL,
    WaitTime INT DEFAULT 0,
    FoodBill DECIMAL(10,2) DEFAULT 0.00,
    TipAmount DECIMAL(10,2) DEFAULT 0.00,
    DiscountApplied DECIMAL(10,2) DEFAULT 0.00,
    PaymentMethod VARCHAR(50) DEFAULT NULL,
    orderedAlcohol VARCHAR(10) DEFAULT 'No',
    AlcoholBill DECIMAL(10,2) DEFAULT 0.00,
    
    FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ServerEmpID) REFERENCES Servers(ServerEmpID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE SET NULL ON UPDATE CASCADE,
    
    CONSTRAINT chk_party_size CHECK (PartySize > 0),
    CONSTRAINT chk_wait_time CHECK (WaitTime >= 0),
    CONSTRAINT chk_food_bill CHECK (FoodBill >= 0),
    CONSTRAINT chk_tip_amount CHECK (TipAmount >= 0),
    CONSTRAINT chk_discount CHECK (DiscountApplied >= 0),
    CONSTRAINT chk_alcohol_bill CHECK (AlcoholBill >= 0),
    CONSTRAINT chk_ordered_alcohol CHECK (orderedAlcohol IN ('Yes', 'No', 'Unknown')),
    CONSTRAINT chk_payment CHECK (PaymentMethod IN ('Cash','Mobile Payment','Credit Card')),
    CONSTRAINT chk_mealtype CHECK (MealType IN ('Breakfast','Dinner','Lunch', 'Take-Out'))
);"
  dbExecute(con, createVisitsSql)

}


main <- function() {
  # Connect to DB
  con = connectDB()

  # Drop existing tables
  dropTables(con)
  
  # Create Tables in DB
  createTables(con)
  
  # Verify tables were created
  tables <- dbListTables(con)
  cat("Tables created in database:", paste(tables, collapse = ", "), "\n\n")
  
  # Disconnect from database
  dbDisconnect(con)
  cat("DB disconnected\n")
}

main()