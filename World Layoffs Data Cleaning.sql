-- Data Cleaning

SELECT * 
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove any Columns

DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Finding duplicates
SELECT *, 
ROW_NUMBER() OVER(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';

DROP TABLE IF EXISTS layoffs_staging2;

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
;
 
SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

-- Deleting duplicates 
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- Standardizing Data
SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Normalize Crypto Industry name
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Normalize Country Name
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`, 
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Converting Date from String to a datetime
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = 'Bally%';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Turns blank industry string into Null Value
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Filling in Missing Industry Values if Industry is known for a company
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON  t1.company = t2.company
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Deleting rows that have both total_laid_off and Percentage_laid_off value as Null
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- Removing row_num since there are no more duplicates
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;