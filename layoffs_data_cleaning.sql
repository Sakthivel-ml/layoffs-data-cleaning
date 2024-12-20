USE cleaning;

-- DESCRIBE TABLE STRUCTURE
DESCRIBE layoffs;

-- CREATE A STAGING TABLE
CREATE TABLE laysoffs_stage LIKE layoffs;
SELECT * FROM laysoffs_stage;
INSERT INTO laysoffs_stage SELECT * FROM layoffs;

-- ADD ROW_NUMBER() TO IDENTIFY DUPLICATES
SELECT *, ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM laysoffs_stage;

-- CREATE TEMPORARY CTE FOR ROW_NUMBER LOGIC
WITH temper_cte AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
    FROM laysoffs_stage
)

-- CREATE FINAL STAGING TABLE
CREATE TABLE laysoffs_stage2 (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- INSERT DATA INTO THE NEW TABLE
SELECT * FROM laysoffs_stage2;
INSERT INTO laysoffs_stage2
SELECT *, ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM laysoffs_stage;

-- DELETE DUPLICATES
SET SQL_SAFE_UPDATES = 0;
DELETE FROM laysoffs_stage2 WHERE row_num > 1;
SELECT * FROM laysoffs_stage2 WHERE row_num = 1;
SET SQL_SAFE_UPDATES = 1;

-- FORMAT THE DATE COLUMN
SELECT `date` FROM laysoffs_stage2;
UPDATE laysoffs_stage2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE laysoffs_stage2 MODIFY COLUMN `date` DATE;

-- DATA CLEANING AND STANDARDIZATION
-- REMOVE EXTRA SPACES FROM COMPANY NAMES
SELECT company, TRIM(company) FROM laysoffs_stage2 ORDER BY 1;
UPDATE laysoffs_stage2 SET company = TRIM(company);

-- STANDARDIZE INDUSTRY NAMES
SELECT DISTINCT industry FROM laysoffs_stage2 ORDER BY 1;
UPDATE laysoffs_stage2 SET industry = "Crypto" WHERE industry LIKE "Crypto%";

-- CLEAN COUNTRY NAMES
SELECT DISTINCT country FROM laysoffs_stage2 ORDER BY 1;
UPDATE laysoffs_stage2 SET country = TRIM(TRAILING "." FROM country) WHERE country LIKE 'United States%';

-- HANDLE NULL VALUES
SELECT * FROM laysoffs_stage2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
DELETE FROM laysoffs_stage2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- UPDATE MISSING INDUSTRY VALUES
SELECT t1.industry, t2.industry 
FROM laysoffs_stage2 t1 
JOIN laysoffs_stage2 t2 
ON t1.company = t2.company 
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE laysoffs_stage2 SET industry = NULL WHERE industry = "";
SELECT industry FROM laysoffs_stage2 WHERE industry IS NULL;

-- COPY NON-NULL VALUES FROM RELATED ROWS
UPDATE laysoffs_stage2 t1 
JOIN laysoffs_stage2 t2 
ON t1.company = t2.company 
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT industry FROM laysoffs_stage2 WHERE industry IS NULL;
