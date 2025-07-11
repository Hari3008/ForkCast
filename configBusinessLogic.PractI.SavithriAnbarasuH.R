# Program Name: configBusinessLogic.PractI.SavithriAnbarasuH.R (Part H -> Add Business Logic)
# Author: Hariharasudan Savithri Anbarasu
# Semester: Full Summer 2025

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
    cat("Connected to DB\n\n")
  }, error = function(e) {
    cat("Error:", e$message, "\n")
    stop("Program ends since DB connection failed.")
  })
  
  return(con)
}
options(warn = -1)

# Create storeVisit procedure
storeVisitProcedure <- function(con){
  storeVisit_sql <- "
CREATE PROCEDURE storeVisit(
    IN p_VisitID INT,
    IN p_RestaurantID INT,
    IN p_ServerEmpID INT,
    IN p_CustomerID INT,
    IN p_VisitDate DATE,
    IN p_VisitTime TIME,
    IN p_MealType VARCHAR(50),
    IN p_PartySize INT,
    IN p_Genders VARCHAR(50),
    IN p_WaitTime INT,
    IN p_FoodBill DECIMAL(10,2),
    IN p_TipAmount DECIMAL(10,2),
    IN p_DiscountApplied DECIMAL(10,2),
    IN p_PaymentMethod VARCHAR(50),
    IN p_orderedAlcohol VARCHAR(10),
    IN p_AlcoholBill DECIMAL(10,2),
    OUT p_Result VARCHAR(100)
)
BEGIN
    -- Validate inputs
    IF p_PartySize <= 0 THEN
        SET p_PartySize = 1;
    END IF;
    
    IF p_FoodBill < 0 THEN
        SET p_FoodBill = 0;
    END IF;
    
    IF p_AlcoholBill < 0 THEN
        SET p_AlcoholBill = 0;
    END IF;
    
    IF p_TipAmount < 0 THEN
        SET p_TipAmount = 0;
    END IF;
    
    IF p_DiscountApplied < 0 THEN
        SET p_DiscountApplied = 0;
    END IF;
    
    IF p_WaitTime < 0 THEN
        SET p_WaitTime = 0;
    END IF;
    
    -- Insert the visit
    INSERT INTO Visits (
        VisitID, RestaurantID, ServerEmpID, CustomerID,
        VisitDate, VisitTime, MealType, PartySize, Genders, WaitTime,
        FoodBill, TipAmount, DiscountApplied, PaymentMethod,
        orderedAlcohol, AlcoholBill
    ) VALUES (
        p_VisitID, p_RestaurantID, p_ServerEmpID, p_CustomerID,
        p_VisitDate, p_VisitTime, p_MealType, p_PartySize, p_Genders, p_WaitTime,
        p_FoodBill, p_TipAmount, p_DiscountApplied, p_PaymentMethod,
        p_orderedAlcohol, p_AlcoholBill
    );
    
    SET p_Result = 'Visit added successfully';
END
"
  dbExecute(con, storeVisit_sql)
  cat("Created storeVisit procedure\n")
}




# Create storeNewVisit procedure
storeNewVisitProcedure <- function(con){
  
  storeNewVisit_sql <- "
CREATE PROCEDURE storeNewVisit(
    IN p_VisitID INT,
    IN p_RestaurantID INT,
    IN p_RestaurantName VARCHAR(100),
    IN p_ServerEmpID INT,
    IN p_ServerName VARCHAR(100),
    IN p_ServerHourlyRate DECIMAL(10,2),
    IN p_CustomerID INT,
    IN p_CustomerName VARCHAR(100),
    IN p_CustomerEmail VARCHAR(100),
    IN p_CustomerPhone VARCHAR(20),
    IN p_LoyaltyMember BOOLEAN,
    IN p_VisitDate DATE,
    IN p_VisitTime TIME,
    IN p_MealType VARCHAR(50),
    IN p_PartySize INT,
    IN p_Genders VARCHAR(50),
    IN p_WaitTime INT,
    IN p_FoodBill DECIMAL(10,2),
    IN p_TipAmount DECIMAL(10,2),
    IN p_DiscountApplied DECIMAL(10,2),
    IN p_PaymentMethod VARCHAR(50),
    IN p_orderedAlcohol VARCHAR(10),
    IN p_AlcoholBill DECIMAL(10,2),
    OUT p_Result VARCHAR(100)
)
BEGIN
    DECLARE v_RestaurantExists INT;
    DECLARE v_ServerExists INT;
    DECLARE v_CustomerExists INT;
    
    -- Check/Create Restaurant with given ID
    SELECT COUNT(*) INTO v_RestaurantExists 
    FROM Restaurants 
    WHERE RestaurantID = p_RestaurantID;
    
    IF v_RestaurantExists = 0 THEN
        INSERT INTO Restaurants (RestaurantID, RestaurantName) 
        VALUES (p_RestaurantID, IFNULL(p_RestaurantName, 'Unknown Restaurant'));
    END IF;
    
    -- Check/Create Server with given ID
    IF p_ServerEmpID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_ServerExists 
        FROM Servers 
        WHERE ServerEmpID = p_ServerEmpID;
        
        IF v_ServerExists = 0 THEN
            INSERT INTO Servers (ServerEmpID, ServerName, HourlyRate) 
            VALUES (p_ServerEmpID, 
                    IFNULL(p_ServerName, 'Unknown'), 
                    IFNULL(p_ServerHourlyRate, 0.00));
        END IF;
    END IF;
    
    -- Check/Create Customer with given ID
    IF p_CustomerID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_CustomerExists 
        FROM Customers 
        WHERE CustomerID = p_CustomerID;
        
        IF v_CustomerExists = 0 THEN
            INSERT INTO Customers (CustomerID, CustomerName, CustomerEmail, CustomerPhone, LoyaltyMember) 
            VALUES (
                p_CustomerID,
                IFNULL(p_CustomerName, 'Unknown'), 
                p_CustomerEmail, 
                p_CustomerPhone, 
                IFNULL(p_LoyaltyMember, FALSE)
            );
        ELSE
            -- Update existing customer
            UPDATE Customers 
            SET CustomerEmail = IFNULL(p_CustomerEmail, CustomerEmail),
                CustomerPhone = IFNULL(p_CustomerPhone, CustomerPhone),
                LoyaltyMember = IFNULL(p_LoyaltyMember, LoyaltyMember)
            WHERE CustomerID = p_CustomerID;
        END IF;
    END IF;
    
    -- Validate numeric inputs
    IF p_PartySize IS NULL OR p_PartySize <= 0 THEN
        SET p_PartySize = 1;
    END IF;
    
    IF p_FoodBill IS NULL OR p_FoodBill < 0 THEN
        SET p_FoodBill = 0;
    END IF;
    
    IF p_AlcoholBill IS NULL OR p_AlcoholBill < 0 THEN
        SET p_AlcoholBill = 0;
    END IF;
    
    IF p_TipAmount IS NULL OR p_TipAmount < 0 THEN
        SET p_TipAmount = 0;
    END IF;
    
    IF p_DiscountApplied IS NULL OR p_DiscountApplied < 0 THEN
        SET p_DiscountApplied = 0;
    END IF;
    
    IF p_WaitTime IS NULL OR p_WaitTime < 0 THEN
        SET p_WaitTime = 0;
    END IF;
    
    -- Insert the visit
    INSERT INTO Visits (
        VisitID, RestaurantID, ServerEmpID, CustomerID,
        VisitDate, VisitTime, MealType, PartySize, Genders, WaitTime,
        FoodBill, TipAmount, DiscountApplied, PaymentMethod,
        orderedAlcohol, AlcoholBill
    ) VALUES (
        p_VisitID, p_RestaurantID, p_ServerEmpID, p_CustomerID,
        p_VisitDate, p_VisitTime, p_MealType, p_PartySize, p_Genders, p_WaitTime,
        p_FoodBill, p_TipAmount, p_DiscountApplied, p_PaymentMethod,
        IFNULL(p_orderedAlcohol, 'No'), p_AlcoholBill
    );
    
    -- Set output parameters
    SET p_Result = 'Visit added successfully';
END
"
  dbExecute(con, storeNewVisit_sql)
  cat("Created storeNewVisit procedure\n\n")
}


teststoreVisit <- function(con){
# Test storeVisit procedure
cat("Testing storeVisit procedure\n\n")

# get valid IDs from the database for testing
test_restaurant <- dbGetQuery(con, "SELECT RestaurantID FROM Restaurants LIMIT 1")
test_server <- dbGetQuery(con, "SELECT ServerEmpID FROM Servers LIMIT 1")
test_customer <- dbGetQuery(con, "SELECT CustomerID FROM Customers LIMIT 1")

if (nrow(test_restaurant) > 0 && nrow(test_server) > 0 && nrow(test_customer) > 0) {
  # Generate a unique VisitID for testing
  max_visit <- dbGetQuery(con, "SELECT MAX(VisitID) as max_id FROM Visits")
  test_visit_id <- ifelse(is.na(max_visit$max_id), 1000000, max_visit$max_id + 1)
  
  tryCatch({
    # Execute multiple statements
    dbExecute(con, "SET @result = ''")
    
    call_stmt <- sprintf("CALL storeVisit(%d, %d, %d, %d, '%s', '%s', '%s', %d, '%s', %d, %.2f, %.2f, %.2f, '%s', '%s', %.2f, @result)",
                         test_visit_id,
                         test_restaurant$RestaurantID[1],
                         test_server$ServerEmpID[1],
                         test_customer$CustomerID[1],
                         Sys.Date(),
                         format(Sys.time(), "%H:%M:%S"),
                         "Lunch",
                         2,
                         "Mixed",
                         15,
                         45.50,
                         9.10,
                         5.00,
                         "Credit Card",
                         "Yes",
                         12.00)
    
    dbExecute(con, call_stmt)
    result <- dbGetQuery(con, "SELECT @result AS Result")
    
    cat("storeVisit test result:", result$Result, "\n")
    
    # Verify the visit was added
    verify_sql <- sprintf("SELECT * FROM Visits WHERE VisitID = %d", test_visit_id)
    verify_result <- dbGetQuery(con, verify_sql)
    cat("Added visit after calling stored procedure: ")
    cat(verify_result$VisitID[1])
    
    if (nrow(verify_result) > 0) {
      cat("\nVisit successfully added to database\n")
    }
  }, error = function(e) {
    cat("Error testing storeVisit:", e$message, "\n")
  })
} else {
  cat("Cannot test storeVisit - no existing data found\n")
}

}

teststoreNewVisit <- function(con){
  # Test storeNewVisit procedure
  cat("\nTesting storeNewVisit procedure\n\n")
  
  # Generate another unique VisitID
  max_visit <- dbGetQuery(con, "SELECT MAX(VisitID) as max_id FROM Visits")
  test_visit_id2 <- ifelse(is.na(max_visit$max_id), 2000000, max_visit$max_id + 1)
  
  tryCatch({
    # Set output variables
    dbExecute(con, "SET @result = ''")
    
    # Call procedure
    call_stmt2 <- sprintf("CALL storeNewVisit(%d, %d, '%s', %d, '%s', %.2f, %d, '%s', '%s', '%s', %d, '%s', '%s', '%s', %d, '%s', %d, %.2f, %.2f, %.2f, '%s', '%s', %.2f, @result)",
                          test_visit_id2,20,
                          "Test Restaurant",
                          99999,  # New server ID
                          "Test Server", 21.75, 100,
                          "Test Customer",
                          "test@example.com",
                          "555-0123",
                          1,  # Loyalty member
                          Sys.Date(),
                          format(Sys.time(), "%H:%M:%S"),
                          "Dinner",
                          4,
                          "Mixed",
                          20,
                          120.00,
                          24.00,
                          10.00,
                          "Cash",
                          "Yes",
                          35.00)
    
    dbExecute(con, call_stmt2)
    
    # Get results
    result2 <- dbGetQuery(con, "SELECT @result AS Result")
    
    # Verify the visit was added
    visit_verify_sql <- sprintf("SELECT * FROM Visits WHERE VisitID = %d", test_visit_id2)
    visit_verify_result <- dbGetQuery(con, visit_verify_sql)
    restaurant_verify_sql <- sprintf("SELECT * FROM Restaurants WHERE RestaurantID = %d", 20)
    restaurant_verify_result <- dbGetQuery(con, restaurant_verify_sql)
    server_verify_sql <- sprintf("SELECT * FROM Servers WHERE ServerEmpID = %d", 99999)
    server_verify_result <- dbGetQuery(con, server_verify_sql)
    customer_verify_sql <- sprintf("SELECT * FROM Customers WHERE CustomerID = %d", 100)
    customer_verify_result <- dbGetQuery(con, customer_verify_sql)
    
    if (nrow(visit_verify_result) > 0 && nrow(restaurant_verify_result) > 0 && nrow(server_verify_result) > 0 && nrow(customer_verify_result) > 0  ) {
      cat("Visit successfully added with new/existing entities\n")
    }
    
    cat("Created new Visit with \n Visit ID : ", visit_verify_result$VisitID[1], "\n")
    cat("Created/Found new Restuarant with \n Restaurant ID : ", restaurant_verify_result$RestaurantID[1], "\n")
    cat("Created/Found new Server with \n Server ID : ", server_verify_result$ServerEmpID[1], "\n")
    cat("Created/Found new Customer with \n Customer ID : ", customer_verify_result$CustomerID[1], "\n")
    
  }, error = function(e) {
    cat("Error testing storeNewVisit:", e$message, "\n")
  })

}

main <- function(){
  
  # Connect to the DB
  con <- connectDB()
  
  # Drop existing stored procedures if they exist
  cat("Dropping existing stored procedures if they exist\n")
  dbExecute(con, "DROP PROCEDURE IF EXISTS storeVisit")
  dbExecute(con, "DROP PROCEDURE IF EXISTS storeNewVisit")
  
  # Creating the stored procedures to execute the business logic
  storeVisitProcedure(con)
  storeNewVisitProcedure(con)
  
  # Testing the stored procedures
  teststoreVisit(con)
  teststoreNewVisit(con)
  
  # Disconnect from DB
  dbDisconnect(con)
  cat("\nDB disconnected\n")
  
}

main()