# Program Name: deleteDB.PractI.SavithriAnbarasuH.R (Part D -> Delete Database)
# Name: Hariharasudan Savithri Anbarasu
# Semester: Full Summer 2025

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
    cat("Connected to DB\n\n")
  }, error = function(e) {
    cat("Error:", e$message, "\n")
    stop("Program ends since DB connection failed.")
  })
  
  return(con)
}

dropTables <- function(con, tables_before){
  # List of tables to be dropped
  # First the tables which have foreign keys (dependencies) are dropped.
  # only Visits table has dependencies.
  tables_to_drop <- c("Visits", "Customers", "Servers", "Restaurants")
  
  # Drop tables
  for (table in tables_to_drop) {
    # Check if table exists before dropping
    if (table %in% tables_before) {
      dropSql <- paste0("DROP TABLE IF EXISTS ", table)
      dbExecute(con,dropSql)
    } else {
      cat("Table", table, "does not exist\n")
    }
  }
}


main <- function(){
  # Connect to DB
  con = connectDB()
  
  # List current tables before deletion
  cat("Tables in database: (BEFORE DELETION)\n")
  tables_before <- dbListTables(con)
  if (length(tables_before) > 0) {
    cat(paste("-", tables_before, collapse = "\n"), "\n")
  } else {
    cat("No tables found in database\n")
  }
  
  # Disable foreign key checks
  dbExecute(con, "SET FOREIGN_KEY_CHECKS = 0")
  cat("\nTemporarily disabled foreign key checks.\n\n")
  
  dropTables(con, tables_before)
  
  # List current tables after deletion
  cat("\nTables in database: (AFTER DELETION)\n")
  tables_after <- dbListTables(con)
  if (length(tables_after) == 0) {
    cat("All tables have been dropped\n\n")
  } else {
    cat("Not all tables were deleted\n")
  }
  
  # Re enabling foreign key checks
  dbExecute(con, "SET FOREIGN_KEY_CHECKS = 1")
  cat("Re enabled foreign key checks.\n\n")
  
  # Disconnect from database
  dbDisconnect(con)
  cat("DB disconnected\n")

}

main()