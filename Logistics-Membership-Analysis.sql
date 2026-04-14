/* =========================================================
   PROJECT: International Logistics Association Membership Analysis
   AUTHOR: Shafi Mulani
   DESCRIPTION: 
   This SQL script performs an end-to-end ETL and analytical workflow:
   
   1. Raw Data Ingestion from CSV into a staging table
   2. Data Quality Auditing using Regex-based validation
   3. Data Transformation & Standardization (Cleaning Phase)
   4. Deduplication and Data Integrity Enforcement
   5. Business Intelligence Queries for Dashboard Insights

   TOOLS USED: PostgreSQL, Regex, Window Functions, CTEs
   ========================================================= */


/* =========================================================
   PHASE 1: ENVIRONMENT SETUP & DATA INGESTION
   Purpose: Store raw, unprocessed data exactly as received
   ========================================================= */

-- Drop existing staging table if present


DROP TABLE IF EXISTS raw_member;
-- Create staging table (all fields stored as TEXT to avoid data loss during ingestion)

CREATE TABLE raw_member (
    member_id TEXT,
    last_name TEXT,
    first_name TEXT,
    address_1 TEXT,
    address_2 TEXT,
    address_3 TEXT,
    address_4 TEXT,
    address_5 TEXT,
    dues_amount TEXT,
    membership_valid_through TEXT,
    member_type TEXT,
    certification TEXT
);

-- Preview raw data
SELECT * FROM raw_member ;
-- Loading raw data from the local directory
COPY raw_member
FROM 'E:/MAIN PRO/P6 _International-Logistics-Association-Memberships/International  Logistics Association Memberships.csv'
DELIMITER ','
CSV HEADER;


-- Phase 2: Data Quality Auditing
-- Identifying anomalies using Regular Expressions (Regex) to flag non-standard IDs, Currencies, and Dates
SELECT member_id FROM raw_member
WHERE member_id !~ '^\d+$';


-- Detect improperly formatted monetary values
SELECT dues_amount FROM raw_member
WHERE dues_amount !~ '^\$?\s?\d+(,\d{3})*(\.\d+)?$';

-- Detect invalid or inconsistent date formats
SELECT membership_valid_through FROM raw_member
WHERE membership_valid_through !~ '^\d{1,2}/\d{1,2}/\d{4}$';


-- Phase 3: Transformation & Standardization (The "Cleaning" Stage)
-- Creating a production-ready table with proper data types and standardized formats
-- Drop cleaned table if already exists
DROP TABLE IF EXISTS cleaned_member;
-- Create cleaned dataset
CREATE TABLE cleaned_member AS
SELECT
 -- Convert valid numeric IDs to INTEGER for indexing and joins
    CASE 
        WHEN member_id ~ '^\d+$' THEN CAST(member_id AS INT)
        ELSE NULL
    END AS member_id,

    last_name,
    first_name,
 -- Consolidate multi-line address into a single column
    CONCAT_WS(', ', address_1, address_2, address_3, address_4, address_5) AS full_address,
 -- Clean currency symbols and convert to NUMERIC for aggregation
    CAST(
        REPLACE(REPLACE(NULLIF(TRIM(dues_amount), ''), '$', ''), ',', '')
    AS NUMERIC) AS dues_amount,
  -- Standardize date format into SQL DATE type
    CASE 
        WHEN membership_valid_through ~ '^\d{1,2}/\d{1,2}/\d{4}$'
        THEN TO_DATE(membership_valid_through, 'MM/DD/YYYY')
        ELSE NULL
    END AS membership_valid_through,

    member_type,
 -- Replace NULL/blank certification values for consistent reporting
    COALESCE(NULLIF(certification, ''), 'No Certification') AS certification

FROM raw_member;
-- Validate cleaned output
SELECT * FROM cleaned_member ;


-- Phase 4: Deduplication & Constraints
-- Using Window Functions (ROW_NUMBER) to identify and remove redundant records
-- Identify duplicate Member IDs
SELECT member_id, COUNT(*)
FROM cleaned_member
GROUP BY member_id
HAVING COUNT(*) > 1;

-- Inspect problematic records (NULL IDs , duplicates)
SELECT *
FROM cleaned_member
WHERE member_id IS NULL
   OR member_id IN (
       SELECT member_id
       FROM cleaned_member
       GROUP BY member_id
       HAVING COUNT(*) > 1
   );

-- Remove records with NULL IDs (invalid entries)

DELETE FROM cleaned_member
WHERE member_id IS NULL;

-- Remove duplicate records using ROW_NUMBER window function
DELETE FROM cleaned_member
WHERE ctid IN (
    SELECT ctid FROM (
        SELECT 
            ctid,
            ROW_NUMBER() OVER (PARTITION BY member_id ORDER BY member_id) AS rn
        FROM cleaned_member
    ) t
    WHERE rn > 1
);

--Verifying No Duplicates Left
SELECT member_id, COUNT(*) AS count
FROM cleaned_member
GROUP BY member_id
HAVING COUNT(*) > 1;


--Adding Primary Key constraint for data integrity
ALTER TABLE cleaned_member
ADD PRIMARY KEY (member_id);


SELECT * FROM cleaned_member
ORDER BY member_id;

---PHASE 5: BUSINESS INTELLIGENCE & ANALYTICS
--- Purpose: Generate insights for dashboard and decision-making


---Membership Expiry Analysis

SELECT 
    member_id,
    membership_valid_through,
    CASE 
        WHEN membership_valid_through IS NULL THEN 'Unknown'
        WHEN membership_valid_through < CURRENT_DATE THEN 'Expired'
        ELSE 'Active'
    END AS status
FROM cleaned_member;


-- Member Distribution by Type (Window Function)


SELECT DISTINCT
    member_type,
    COUNT(*) OVER (PARTITION BY member_type) AS total_members
FROM cleaned_member;

-- Certification Distribution (CTE for clarity)

WITH cleaned_data AS (
    SELECT 
        member_id,
        COALESCE(certification, 'No Certification') AS certification
    FROM cleaned_member
)
SELECT 
    certification, 
    COUNT(*) AS total_members
FROM cleaned_data
GROUP BY certification;

-- Revenue Analysis by Membership Type

SELECT 
    member_type,
    SUM(dues_amount) AS total_revenue
FROM cleaned_member
GROUP BY member_type
ORDER BY total_revenue DESC;

-- Active vs Expired Members Breakdown

SELECT 
    CASE 
        WHEN membership_valid_through < CURRENT_DATE THEN 'Expired'
        ELSE 'Active'
    END AS status,
    COUNT(*) AS total_members
FROM cleaned_member
GROUP BY status;

---Top Paying Members using Window Function 

SELECT *
FROM (
    SELECT 
        member_id,
        first_name,
        dues_amount,
        RANK() OVER (ORDER BY dues_amount DESC) AS rank
    FROM cleaned_member
) t
WHERE rank <= 5;

-- Certification Distribution Overview

SELECT 
    certification,
    COUNT(*) AS total
FROM cleaned_member
GROUP BY certification
ORDER BY total DESC;

-- Data Quality Summary Report

SELECT 
    COUNT(*) AS total_rows,
    COUNT(member_id) AS valid_ids,
    COUNT(dues_amount) AS valid_dues,
    COUNT(membership_valid_through) AS valid_dates
FROM cleaned_member;

-- Final dataset preview (ready for BI tools like Tableau)
SELECT * FROM cleaned_member;

-- Phase 5: Business Intelligence & Insights
-- These queries serve as the foundation for the Tableau Dashboard KPIs






