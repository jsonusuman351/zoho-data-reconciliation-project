# 📈 Zoho Data Reconciliation & Analytics Project


### 1. Project Objective

Welcome to my Data Reconciliation and Analytics project. The primary objective was to tackle a common business challenge: **data discrepancy**. I set out to consolidate, analyze, and reconcile data from three distinct financial sources—**Bookings**, **Invoices**, and **GST 2A/2B filings**—to identify critical gaps and financial differences.

The final deliverable is a unified, clean query table and an executive dashboard that precisely highlights:
* Invoices received but **missing** from GST 2A/2B data.
* Bookings for which an invoice was **never received**.
* The total **GST difference** between the initial booking system (`K3`) and the final invoice.

---

### 2. Tech Stack

* **Platform:** Zoho Analytics
* **Data Analysis & Transformation:** SQL (for all joins, aggregations, and business logic)
* **Visualization:** Zoho Analytics Dashboard

---

### 3. My Analytical Methodology

The core of this project was a single, complex SQL query (`data_reconciliation_query.sql`). My approach was focused on data integrity and ensuring a reliable "single source of truth."

#### The Challenge
The data was siloed in three separate tables. The main risk was potential duplicate entries in the `Invoice` and `2A_2B` tables, which could severely skew the final analysis and inflate numbers.

#### My Solution
I built the query using the following steps to ensure 100% accuracy:

**1. Preserving All Bookings (Base Table)**
I used the `DA-hackathon_Booking` table as the main "source of truth" and performed `LEFT JOIN` operations. This strategic choice ensured that even if a booking was missing an invoice or GST filing, it would still appear in the final report.

**2. Ensuring Data Integrity (De-duplication)**
Before joining, I used subqueries to de-duplicate the `Invoice` and `2A_2B` tables. I used the `ROW_NUMBER()` window function to rank duplicates and select only the most recent invoice (`rn = 1`).
This was the most critical step to prevent row multiplication and guarantee the final row count (2,980) precisely matched the base booking table.

**3. Deriving Business Logic (Calculated Columns)**
I created several calculated columns using `CASE` statements to flag discrepancies at a glance and make the data "dashboard-ready."

* **Invoice Status:** Checks if a matching invoice was found for a booking.
    ```sql
    CASE
        WHEN T2."Invoice_Number" IS NOT NULL THEN 'Invoice received'
        ELSE 'Not received'
    END AS "Invoice Status"
    ```

* **2A/2B Status:** Checks if a received invoice also existed in the GST data.
    ```sql
    CASE
        WHEN T3."2A/2B-Invoice/Note_Number" IS NOT NULL THEN 'In 2A/2B'
        ELSE 'Not In 2A/2B'
    END AS "2A/2B Status"
    ```

* **GST Difference:** A simple financial calculation to find discrepancies.
    ```sql
    (T1."K3" - T2."Invoice Total_GST") AS "GST Difference"
    ```

---

### 4. Dashboard & Key Findings

The final table and dashboard were built to answer critical business questions at a glance:

* `🧾` **Invoice vs. GST:** Which invoices have we received but are missing from our GST 2A/2B filings?
* ` booking-to-Invoice Gaps:` Which bookings were confirmed but never invoiced?
* `💰` **Financial Discrepancies:** What is the total GST difference between our booking system (`K3`) and the final invoices?

---

### 5. Project Outputs

* **`data_reconciliation_query.sql`**: The core SQL script used to perform the entire transformation and reconciliation.
* **`final_output_table.csv`**: The final, cleaned, and reconciled table (2,980 rows) with all calculated status columns.
* **`final_dashboard.pdf`**: A PDF preview of the Zoho Analytics dashboard built on top of the final table, visualizing the key metrics.