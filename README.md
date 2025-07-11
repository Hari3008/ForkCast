# ForkCast
A comprehensive database management system for analyzing restaurant visits, revenue, and customer behavior patterns.

## 🎯 Project Overview

ForkCast is a cloud-based relational database system designed to help restaurant management groups track and analyze:
- Customer visits and spending patterns
- Revenue trends across multiple restaurants
- Server performance metrics
- Customer loyalty program effectiveness

## 🏗️ Architecture

### Database Design
- **Normalization**: Fully normalized to 3NF (Third Normal Form)
- **Cloud Hosting**: MySQL database hosted on cloud infrastructure (Aiven/AWS RDS/Google Cloud)
- **ERD**: Complete entity-relationship diagram with IE (Crow's Feet) notation

### Key Components
1. **Database Schema Design** - Normalized relational schema from denormalized CSV data
2. **ETL Pipeline** - Extract, Transform, Load process for importing restaurant data
3. **Analytics Engine** - SQL-based reporting and trend analysis
4. **Business Logic Layer** - Stored procedures for transaction management

## 📊 Features

- **Revenue Analytics**: Track total revenue by restaurant, year, and customer segments
- **Customer Insights**: Analyze unique customers, loyalty program participation, and spending patterns
- **Visit Tracking**: Monitor restaurant visits, party sizes, and peak times
- **Trend Visualization**: Line charts showing revenue trends over time
- **Data Validation**: Comprehensive testing suite to ensure data integrity

## 🛠️ Technology Stack

- **Database**: MySQL 8.0+ (Cloud-hosted) -  Aiven
- **Programming Language**: R
- **Reporting**: R Markdown with kableExtra
- **Visualization**: Base R plotting functions
- **Libraries**: 
  - DBI (Database Interface)
  - RMySQL/RMariaDB
  - kableExtra (Table formatting)
  - Additional R packages for data manipulation

## 🚀 Getting Started

### Prerequisites
- R (version 4.0+)
- RStudio
- MySQL cloud database account (Aiven, AWS RDS, or Google Cloud SQL)
- Required R packages (see installation section)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/RestaurantPulse.git
cd RestaurantPulse
```

2. Install required R packages

```
rpackages <- c("DBI", "RMySQL", "kableExtra", "rmarkdown")
install.packages(packages)
```

3. Configure database connection
- Update connection parameters in R scripts with your cloud database credentials

### Database Setup

1. Run database creation script:
```r
source("createDB.PractI.YourName.R")
```

2. Load data into database:
```r
source("loadDB.PractI.YourName.R")
```

3. Verify data loading:
```r
source("testDBLoading.PractI.YourName.R")
```

## 📈 Analytics & Reporting

Generate comprehensive revenue reports by knitting the R Markdown notebook:
```r
rmarkdown::render("RevenueReport.PractI.YourName.Rmd")
```

The report includes:
- Revenue analysis by restaurant
- Year-over-year trends
- Customer behavior patterns
- Visual trend analysis

## 🔧 Database Operations

### Stored Procedures
- `storeVisit`: Add new restaurant visits with existing customer/server
- `storeNewVisit`: Add visits with automatic customer/server creation

### Key Tables
- Restaurants
- Customers
- Servers
- Visits
- Loyalty Program
- Additional normalized tables

## 📝 Data Source

The project uses synthetic restaurant visit data including:
- Visit dates and times
- Customer information
- Party sizes
- Food and alcohol sales
- Tips
- Server assignments
- Loyalty program participation

Data URL: `https://s3.us-east-2.amazonaws.com/artificium.us/datasets/restaurant-visits-139874.csv`

## 🔍 Key Metrics Tracked

- **Restaurant Performance**
  - Total visits per restaurant
  - Revenue by location
  - Average party size
  - Customer retention rates

- **Financial Analytics**
  - Food vs. alcohol revenue split
  - Average check size
  - Tip percentages
  - Year-over-year growth

- **Customer Behavior**
  - Visit frequency
  - Spending patterns
  - Loyalty program engagement
  - Party size trends

## ⚠️ Important Notes

- Ensure proper handling of missing values and sentinel values in the data
- Text fields must use single quotes for Aiven MySQL
- Use batch inserts for efficient data loading
- Disconnect from database after operations to free resources

## 🤝 Contributing

This is an academic project. While contributions are not expected, feedback and suggestions are welcome.
