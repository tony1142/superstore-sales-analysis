# Dataset Details

## Overview
This project uses the **Sample Superstore Sales** dataset, a widely used dataset for data analysis and visualization. It contains **four years of sales data (2014–2017)** for a fictional Superstore, spanning **9,994 records** across three tables: `Orders`, `Returns`, and `People`.

## Source & Structure
The dataset originates from the **Tableau Community via Kaggle** and was provided as an [Excel (.xls) file](https://community.tableau.com/s/question/0D54T00000CWeX8SAL/sample-superstore-sales-excelxls) with three sheets:

| Sheet   | Purpose                      | Rows   |
|---------|------------------------------|--------|
| Orders  | Main sales transaction data  | 9,994  |
| Returns | Flag for returned orders     | 296    |
| People  | Regional manager assignments | 4      |

For analysis, the dataset was converted into **MySQL tables**, maintaining the same structure.

## Database Structure

Each table contains key fields relevant to sales, returns, and management.

### Orders Table (Sales Transactions)
- `row_id`: Unique identifier for each row  
- `order_id`: Unique identifier for each order  
- `order_date`: Date of the order  
- `ship_date`: Date of shipment  
- `ship_mode`: Shipping method  
- `customer_id`: Unique customer identifier  
- `customer_name`: Name of the customer  
- `segment`: Customer segment (Consumer, Corporate, Home Office)  
- `region`: Region of the sale (West, East, South, Central)  
- `product_id`: Unique identifier for the product  
- `category`: Product category (Technology, Office Supplies, Furniture)  
- `sub_category`: Product sub-category (e.g., Phones, Chairs)  
- `product_name`: Name of the product  
- `sales`: Sales amount  
- `quantity`: Quantity sold  
- `discount`: Discount applied  
- `profit`: Profit amount  

### Returns Table (Returned Orders)
- `order_id`: Links to the `Orders` table  
- `returned`: Indicates if the order was returned (`Yes` / `No`)  

### People Table (Regional Management)
- `region`: Sales region  
- `person`: Assigned regional manager  

## Data Wrangling Process

To prepare the dataset for MySQL analysis, several data transformation steps were required.

### 1. Initial CSV Conversion & Encoding Fixes
- The **Orders**, **Returns**, and **People** sheets were converted to CSV format.
- **UTF-8 encoding** caused import issues in MySQL (likely due to special characters).
- **Solution**: Re-encoded all files to **ASCII** for seamless MySQL import.

### 2. Column Reordering for MySQL Import
- The **Orders** sheet contained **comma-separated product names**, causing column misalignment.
- **Solution**: Moved `product_name` to the **last column**, preventing import errors.

### 3. MySQL Table Import & Type Conversion
- `Superstore_Orders_Reordered.csv` was first imported into a **temporary table** (`temp_orders`).
- **Data types** were adjusted (e.g., `order_date` → `DATE`, `sales` → `DECIMAL`).
- Final **Orders**, **Returns**, and **People** tables were created.

### 4. View Creation for Analysis
- A SQL **view** (`vw_superstore_analysis`) was created to integrate **Orders**, **Returns**, and **People** tables.
- This simplified analysis by providing a **single unified dataset**.

> 💡 All steps are documented in `data_wrangling_mysql.sql` and `data_preparation_mysql.sql`.

## Files in This Folder
- `Sample - Superstore.xls`: The original dataset file with three sheets (Orders, Returns, People).
- `Superstore_Orders_ascii.csv`: ASCII-encoded CSV file created from the Orders sheet.
- `Superstore_Orders_Reordered.csv`: Reordered version of `Superstore_Orders_ascii.csv` used for import into MySQL.
- `Superstore_Returns_ascii.csv`: ASCII-encoded CSV file created from the Returns sheet, used for import into MySQL.
- `Superstore_People_ascii.csv`: ASCII-encoded CSV file created from the People sheet, used for import into MySQL.
- `dataset_details.md`: This file, documenting the dataset and wrangling steps.
