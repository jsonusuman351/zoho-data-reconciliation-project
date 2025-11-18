SELECT
    -- Select all columns from the base table (T1)
    T1."Agency_Invoice_Number",
    T1."Agency_Name",
    T1."Class",
    T1."Domestic/International",
    T1."GST_Rate",
    T1."K3",
    T1."Location",
    T1."PNR",
    T1."Ticket/PNR",
    T1."Ticket_Number",
    T1."Transaction_Amount_INR",
    T1."Transaction_Date",
    T1."Transaction_Type",
    T1."Vendor",
    T1."Priority",
    T1."Input Airline",
    T1."Traveller Name",
    T1."Type",
    T1."Origin City",
    T1."SOTO Status",

    -- Create 'origin' column (first 3 chars of Location)
    LEFT(T1."Location", 3) AS "origin",

    -- Select all relevant columns from the 'Invoice' subquery (T2)
    T2."Supplier_GSTIN",
    T2."Invoice_Number",
    T2."Invoice_Date",
    T2."Tax Rate",
    T2."Invoice Taxable",
    T2."Invoice CGST",
    T2."Invoice SGST",
    T2."Invoice IGST",
    T2."Invoice Total_GST",
    T2."Invoice Total_Amount",

    -- Create new calculated/formula columns
    (T1."K3" - T2."Invoice Total_GST") AS "GST Difference",

    CASE
        WHEN T2."Invoice_Number" IS NOT NULL THEN 'Invoice received'
        ELSE 'Not received'
    END AS "Invoice Status", -- Status based on successful join to T2

    CASE
        WHEN T3."2A/2B-Invoice/Note_Number" IS NOT NULL THEN 'In 2A/2B'
        ELSE 'Not In 2A/2B'
    END AS "2A/2B Status" -- Status based on successful join to T3

FROM
    "DA-hackathon_Booking" AS T1 -- T1 is the base table.
LEFT JOIN
    -- Subquery 1: This replaces 'Ranked_Invoice'. It de-duplicates the invoice table.
    (
        SELECT
            *,
            ROW_NUMBER() OVER(
                PARTITION BY "Ticket/PNR", "Vendor", "Transaction_Type", "Origin"
                ORDER BY "Invoice_Date" DESC
            ) as rn
        FROM "DA-hackathon_Invoice"
    ) AS T2
ON
    T1."Ticket/PNR" = T2."Ticket/PNR"
    AND T1."Vendor" = T2."Vendor"
    AND T1."Transaction_Type" = T2."Transaction_Type"
    AND LEFT(T1."Location", 3) = T2."Origin"
    AND T2.rn = 1 -- Only join the single most recent invoice
LEFT JOIN
    -- Subquery 2: This replaces 'Unique_2A_2B'. It gets a distinct list of 2A/2B invoices.
    (
        SELECT DISTINCT
            "2A/2B-Invoice/Note_Number",
            "Transaction_Type"
        FROM "DA-hackathon_2A_2B"
    ) AS T3
ON
    T2."Invoice_Number" = T3."2A/2B-Invoice/Note_Number"
    AND T2."Transaction_Type" = T3."Transaction_Type"
