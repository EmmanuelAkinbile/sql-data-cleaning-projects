/* ==========================================
   SQL Data Cleaning — Layoffs (Guided)
   Source: Followed Alex the Analyst tutorial
   Objective: Practice a repeatable cleaning workflow
   Note: Do NOT modify raw tables. Work only in staging.
   ========================================== */
   
-- Initial glance at raw table
SELECT *
FROM layoffs;

-- --------------------------------------------------
-- STEP 0 — Make a copy of raw data (work in staging)
-- --------------------------------------------------
CREATE TABLE layoffs_staging
LIKE layoffs;						-- copying structure of raw data table

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- --------------------------------------------------
-- STEP 1 — Identify duplicates with ROW_NUMBER()
-- (we'll remove them in the staging2 table (final step))
-- --------------------------------------------------
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company, location, 
		industry, total_laid_off, percentage_laid_off, 
        `date`, stage, country, funds_raised_millions)row_num
FROM layoffs_staging;

-- Narrower duplicate definition used for deletion
WITH duplicate_cte as 
(
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`)row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- --------------------------------------------------
-- STEP 1b - Create staging2 with a row_num column,
--           insert data + row numbers, then delete dups
-- --------------------------------------------------
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *	-- should be empty now
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`)row_num
    FROM layoffs_staging;

-- Remove duplicates (keep row_num = 1)
DELETE
FROM layoffs_staging2
WHERE row_num >1;

-- Optional QA: check final count vs before
SELECT COUNT(*) AS rows_after_dedupe FROM layoffs_staging2;

SELECT * FROM layoffs_staging2;  -- spot check

-- --------------------------------------------------
-- STEP 2 — Standardize values (example: trim company)
-- --------------------------------------------------
SELECT company, (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Checking industry field for spelling errors
SELECT DISTINCT industry									
FROM layoffs_staging2
;

UPDATE layoffs_staging2		-- Merging 2 distinct 'industries' that are the same into 1
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Checking for multiple instances of trailing '.' 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)	
FROM layoffs_staging2
ORDER BY 1
;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT * 			-- Rechecking fields 
FROM layoffs_staging2;

-- Will now update the datatype of the date field
SELECT `date`		-- Checking data format in table
FROM layoffs_staging2;

UPDATE layoffs_staging2		-- date parsing in table
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2	-- altering datatype of the field/column 
MODIFY COLUMN `date` DATE;

-- --------------------------------------------------
-- STEP 3 — Nulls / blanks handling 
-- --------------------------------------------------
SELECT *						-- checking for null values in both total_laid_off and percentage_laid_off
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off is null;

-- also checking for blank/ empty cells in the industry field so it may be corrected
SELECT *
FROM layoffs_staging2
WHERE industry is null or industry = ' ';

UPDATE layoffs_staging2
SET industry = null
where industry = ' ';

-- checking fields for specific company, same company listed multiple times but industry should be populated 
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Airbnb%';

SELECT t1.industry, t2.industry		
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry is null or t1.industry = ' ')
and t2.industry is not null;

UPDATE layoffs_staging2 t1		-- will now replace empty industry value with value it should have 
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry is null or t1.industry = ' ')
and t2.industry is not null;

UPDATE layoffs_staging2			-- QA check; making sure the industry is populated for all instances of Airbnb 
SET industry = 'Travel'
WHERE company = 'Airbnb';

-- --------------------------------------------------
-- STEP 4 — Drop columns 
-- --------------------------------------------------
SELECT *	-- checking for instances when the 2 fields are null
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off is null;

DELETE 		-- removing the columns when the 2 fields are null since we have no way of populating the fields (at least for this project)
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off is null;

ALTER TABLE layoffs_staging2 	-- removing the row num column since we do not need it any longer
DROP COLUMN row_num;
