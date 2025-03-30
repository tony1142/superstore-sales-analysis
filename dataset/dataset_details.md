# Dataset Details – Superstore Power BI Dashboard

## Overview

This Power BI project uses the Sample Superstore Sales dataset, which contains four years of sales data (2014–2017) for a fictional retail business. The dataset includes transaction-level details on customer orders, returns, and regional sales assignments across the United States.

The original dataset was provided as an Excel (.xls) file with three sheets: `Orders`, `Returns`, and `People`.

- Orders: 9,994 rows
- Returns: 296 rows
- People: 4 rows

For this Power BI project, only the `Orders` and `Returns` tables were used.

## Source

This dataset originates from the Tableau Community and is publicly available via Kaggle:

[https://www.kaggle.com/datasets/jessemostipak/sample-superstore](https://www.kaggle.com/datasets/jessemostipak/sample-superstore)


## Tables Used

### 1. Orders Table (Sales Transactions)

The `Orders` table contains the core transaction-level sales data used to calculate KPIs such as Sales, Profit, Quantity, and Discount. It also provides the necessary categorical dimensions for slicing and filtering visualizations.

**Fields used:**
- `Order ID`: Primary key for transaction identification
- `Order Date`: Used for all time-based analysis (linked to custom date table)
- `Sales`: Transaction revenue (aggregated using SUM)
- `Profit`: Profit per transaction (aggregated using SUM)
- `Category`: Product category (Technology, Office Supplies, Furniture)
- `Sub-Category`: More specific product classification (e.g., Phones, Chairs)
- `Region`: Sales region (West, East, South, Central)
- `State`: State-level location for geographic analysis
- `Segment`: Customer segment (Consumer, Corporate, Home Office)

**Fields removed:**
- `Row ID`: Unique row index not needed for analysis
- `Ship Date`, `Ship Mode`: Not relevant to the business questions answered in this report
- `Product ID`: Excluded to simplify the model, as product-level analysis was done by Sub-Category

These unused columns were removed to keep the data model compute efficient and focused on the core analytical goals.

---

### 2. Returns Table (Returned Orders)

The `Returns` table was used to identify which orders were returned. It is a simple reference table containing:

- `Order ID`: Identifier used to join with the Orders table

A relationship was established between `Returns[Order ID]` and `Orders[Order ID]`. Return rates were calculated using DAX by comparing distinct order counts in both tables.

The `Returned` column (Yes/No) was not imported, as only the presence or absence of the Order ID was needed for analysis.

## Custom Date Table

To support accurate time intelligence functions such as `SAMEPERIODLASTYEAR`, a custom date table was created using Data Analysis Expressions (DAX). This approach avoids reliance on Power BI’s auto-generated date hierarchies, which can create multiple redundant date tables in the background and degrade performance.

### DAX Formula:

```dax
Date Table = 
ADDCOLUMNS(
    CALENDAR(MIN(Orders[Order Date]), MAX(Orders[Order Date])),
    "Start of Month", EOMONTH([Date], -1) + 1
)
```

The table was marked as a **Date Table** in Power BI and linked to `Orders[Order Date]`. `Start of Month` is used for monthly grouping in time-series visuals.

---

## Custom Columns

To improve the clarity of tooltips and categorical date displays, a clean Month-Year label was created:

```dax
Month Year Label = FORMAT('Date Table'[Start of Month], "MMM YYYY")
```

This field is used in custom tooltip pages to show readable hover labels (e.g., "Jan 2017") instead of full potentially misleading date stamps.

---

## Data Model Relationships

The final data model includes three core tables and one measures table:

- **Orders → Date Table**  
  Relationship: Many-to-one  
  Used to support time-based filtering and DAX time intelligence functions. Linked on `Orders[Order Date] → Date Table[Date]`.

- **Orders → Returns**  
  Relationship: One-to-many  
  Used to compute return percentages based on matching `Order ID`.

- **Key Measures Table**  
  This standalone table was created to organize all custom DAX measures for improved clarity and reuse.

The model design follows a star schema pattern to improve performance, simplify calculations, and enable clean filtering across visuals.

---

## Data Cleaning & Transformation Notes

- Tables were imported from `Sample - Superstore.xls`
- Headers were promoted on import
- Only necessary columns were retained
- No transformations beyond header promotions, column removal and renaming were performed
- Relationships created:
  - `Orders[Order ID]` → `Returns[Order ID]`
  - `Orders[Order Date]` → `Date Table[Date]`

---

## Model & Visualization Design Notes

- A collapsible slicer panel was created using image icons, bookmarks, and selection panes to allow users to show/hide filter options intuitively.
- A tooltip page was designed for time-series visuals using a clean Month-Year label (`MMM YYYY`) to clearly display point-in-time comparisons.
- Conditional formatting was applied to profit-based visuals (map and bar chart) to highlight negative profit using red tones, improving the communication of loss-making areas.

---

## Summary

This dataset was intentionally minimized and cleaned to support a focused set of KPIs and visualizations tied directly to business performance. All enhancements were made with clarity, speed, and practical decision-making in mind.
