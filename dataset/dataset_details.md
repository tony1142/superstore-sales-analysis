# Dataset Details

## Overview
This project uses the Sample Superstore Sales dataset, a widely-used dataset for data analysis and visualization practice. The dataset contains sales data for a fictional Superstore over four years (2014–2017), with 9,994 records across three tables: `Orders`, `Returns`, and `People`.

## Source
The dataset was sourced from the Tableau Community via Kaggle: [Sample - Superstore Sales (Excel).xls](https://community.tableau.com/s/question/0D54T00000CWeX8SAL/sample-superstore-sales-excelxls). It is provided as an XLS file with three sheets:
- **Orders Sheet**: Contains the main sales transaction data (9,994 rows).
- **Returns Sheet**: Contains return information (296 rows).
- **People Sheet**: Contains regional manager information (4 rows).

## Dataset Structure
The dataset was converted into three tables for analysis:

| Table   | Rows  | Purpose                     | Source Sheet |
|---------|-------|-----------------------------|--------------|
| Orders  | 9,994 | Core sales transaction data | Orders       |
| Returns | 296   | Flag for returned orders    | Returns      |
| People  | 4     | Maps regions to regional managers | People       |

### Key Fields
- **Orders**:
  - `row_id`: Unique identifier for each row.
  - `order_id`: Unique identifier for each order.
  - `order_date`: Date of the order.
  - `ship_date`: Date of shipment.
  - `ship_mode`: Shipping method.
  - `customer_id`: Unique identifier for the customer.
  - `customer_name`: Name of the customer.
  - `segment`: Customer segment (Consumer, Corporate, Home Office).
  - `country`: Country of the sale (all US in this dataset).
  - `city`: City of the sale.
  - `state`: State of the sale.
  - `postal_code`: Postal code of the sale.
  - `region`: Region of the sale (West, East, South, Central).
  - `product_id`: Unique identifier for the product.
  - `category`: Product category (Technology, Office Supplies, Furniture).
  - `sub_category`: Product sub-category (e.g., Phones, Chairs).
  - `product_name`: Name of the product.
  - `sales`: Sales amount.
  - `quantity`: Quantity sold.
  - `discount`: Discount applied.
  - `profit`: Profit amount.
- **Returns**:
  - `returned`: Indicates if the order was returned (Yes/No).
  - `order_id`: Links to the `order_id` in the Orders table.
- **People**:
  - `region`: Region (West, East, South, Central).
  - `person`: Name of the regional manager.

## Data Wrangling Steps
The original dataset required several wrangling steps to prepare it for analysis in MySQL:

1. **Initial Conversion of Smaller Files with UTF-8 Encoding**:
   - The smaller sheets (`Returns` and `People`) were converted first to test the import process, using UTF-8 encoding:
     - The `Returns` sheet was saved as `Superstore_Returns_utf8.csv`.
     - The `People` sheet was saved as `Superstore_People_utf8.csv`.
   - These UTF-8 encoded files caused import issues in MySQL, likely due to special characters or formatting.

2. **Switch to ASCII Encoding for All Files**:
   - After encountering issues with UTF-8, all three sheets were converted to CSV files using ASCII encoding:
     - The `Orders` sheet was saved as `Superstore_Orders_ascii.csv`.
     - The `Returns` sheet was saved as `Superstore_Returns_ascii.csv`.
     - The `People` sheet was saved as `Superstore_People_ascii.csv`.

3. **Column Reordering for Orders**:
   - The `Superstore_Orders_ascii.csv` file had issues with comma-separated values in the `product_name` column (due to overly detailed product names), causing misalignment during the MySQL import.
   - The columns were reordered to move `product_name` to the last column, creating `Superstore_Orders_Reordered.csv`.

4. **Import into MySQL**:
   - The reordered `Superstore_Orders_Reordered.csv` was imported into a temporary table (`temp_orders`) in MySQL.
   - Type conversion was applied (e.g., converting `order_date` to DATE, `sales` to DECIMAL) to create the final `orders` table.
   - `Superstore_Returns_ascii.csv` and `Superstore_People_ascii.csv` were imported into the `returns` and `people` tables, respectively.
   - These steps are documented in the [data_wrangling_mysql.sql](../../sql_scripts/data_wrangling_mysql.sql) script.

5. **View Creation**:
   - A view (`vw_superstore_analysis`) was created to join the `orders`, `returns`, and `people` tables for analysis.
   - This step is documented in the [data_preparation_mysql.sql](../../sql_scripts/data_preparation_mysql.sql) script.

## Files in This Folder
- `Sample - Superstore.xls`: The original dataset file with three sheets (Orders, Returns, People).
- `Superstore_Orders_ascii.csv`: ASCII-encoded CSV file created from the Orders sheet.
- `Superstore_Orders_Reordered.csv`: Reordered version of `Superstore_Orders_ascii.csv` used for import into MySQL.
- `Superstore_Returns_ascii.csv`: ASCII-encoded CSV file created from the Returns sheet, used for import into MySQL.
- `Superstore_People_ascii.csv`: ASCII-encoded CSV file created from the People sheet, used for import into MySQL.
- `dataset_details.md`: This file, documenting the dataset and wrangling steps.
