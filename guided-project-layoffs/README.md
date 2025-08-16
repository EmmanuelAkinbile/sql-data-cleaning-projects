# SQL Data Cleaning — Layoffs (Guided Project)

**Source:** Based on Alex the Analyst’s SQL data cleaning tutorial.  
**Goal:** Practice a standard, repeatable cleaning workflow using SQL.

---

## Steps Performed
1. **Create staging copy** of raw table to avoid modifying source data.  
2. **Remove duplicates** using `ROW_NUMBER()` with `PARTITION BY` logic.  
3. **Standardize text fields** (trimming extra spaces, fixing casing).  
4. **Standardize dates** into consistent `YYYY-MM-DD` format.  
5. **Handle nulls** by replacing blanks with `NULL` or consistent placeholders.  
6. **Drop unnecessary columns** to simplify the dataset.  
7. **Final QA checks** to validate row counts and data quality.

---

## Files
- `sql_scripts/data_cleaning_layoffs.sql` — Complete, commented SQL script.  
- `outputs/` — (Optional) screenshots or exports showing before/after cleaning steps.

---

## What I Practiced
- Using **window functions** (`ROW_NUMBER`) and **CTEs** to find/remove duplicates.  
- String functions (`TRIM`, `UPPER/LOWER`) to standardize messy text data.  
- Date formatting with `STR_TO_DATE()` (MySQL) / `CAST()` (other SQL engines).  
- Designing a clear **step-by-step cleaning process** with documentation.

---

## Notes
This is a **guided project** completed by following Alex the Analyst’s tutorial.  
It demonstrates mastery of SQL fundamentals for data cleaning and prepares me to apply the same workflow to new, independent datasets.
