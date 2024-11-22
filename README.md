# Layoffs Data Cleaning and Transformation

This project involves cleaning and transforming a dataset that contains information about layoffs across various companies. The goal is to ensure the data is standardized, duplicates are removed, and missing values are handled to make the dataset ready for analysis.

## Project Overview

The dataset contains columns such as `company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, and `funds_raised_millions`. This project processes the data using SQL to achieve the following goals:

- **Remove duplicate records**: Identifying and eliminating duplicates based on various attributes.
- **Standardize data**: Ensuring consistency in data, such as trimming whitespace, updating industry names, and fixing country names.
- **Handle missing values**: Removing rows where critical data is missing or filling in missing values based on related data.

## Steps Taken

1. **Backup and Duplicate Removal**: 
   - Created a backup table `laysoffs_stage` and used the `ROW_NUMBER()` function to identify duplicates. Only the first occurrence of each record was retained.

2. **Create and Populate New Table**: 
   - A new table `laysoffs_stage2` was created to store the cleaned data with an additional column for row numbers.

3. **Data Cleaning**: 
   - Data cleaning steps include:
     - **Trimming whitespace** from company names.
     - **Standardizing industry names** (e.g., "Crypto" names are unified)\\.
     - **Fixing country names** by removing any trailing periods.
     - **Handling missing data** by deleting rows with missing critical values or filling in values from matching records.

4. **Date Format Correction**: 
   - The `date` column was standardized to the proper date format (`%m/%d/%Y`).

## Key SQL Queries

### Creating Backup Table and Removing Duplicates

```sql
CREATE TABLE laysoffs_stage LIKE layoffs;
INSERT INTO laysoffs_stage SELECT * FROM layoffs;
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num FROM laysoffs_stage;
```

# Data Transformation and Cleaning
```sql
-- Create laysoffs_stage2 table
CREATE TABLE laysoffs_stage2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  date TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

-- Insert data into laysoffs_stage2 with row numbers
INSERT INTO laysoffs_stage2 SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num FROM laysoffs_stage;

-- Delete duplicate records
DELETE FROM laysoffs_stage2 WHERE row_num > 1;

-- Update date format
UPDATE laysoffs_stage2 SET date = STR_TO_DATE(date, '%m/%d/%Y');

-- Trim spaces from company names
UPDATE laysoffs_stage2 SET company = TRIM(company);

-- Standardize industry names
UPDATE laysoffs_stage2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

-- Remove periods from country names
UPDATE laysoffs_stage2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';
```
#Technologies Used
SQL: All data cleaning and transformation tasks were performed using SQL.
MySQL: The SQL queries were executed on a MySQL database.

#Conclusion
This project effectively cleans and prepares the layoffs dataset for analysis by removing duplicates, handling missing values, and standardizing the data. The resulting dataset is now ready for further analysis or visualization tasks.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

