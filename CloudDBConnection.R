library(RMySQL)
library(DBI)

library(RMySQL)

# 2. Settings
db_user <- 'avnadmin'            # use your value from the setup
db_password <- '####'    # use your value from the setup
db_name <- 'defaultdb'         # use your value from the setup

db_host <- 'mysql-practicum-1-practicum-1-hariharasudan.f.aivencloud.com'

db_port <- 28796

# 3. Connect to remote server database

mydb <-  dbConnect(RMySQL::MySQL(), user = db_user, password = db_password,
                           dbname = db_name, host = db_host, port = db_port)

dbListTables(mydb) # List all tables in the database


tables <- dbListTables(mydb)
print(tables)
dbDisconnect(mydb)
