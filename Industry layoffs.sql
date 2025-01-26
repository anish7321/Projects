 -- Data cleaning
 -- Fixing null and empty columns
 -- Normalizing 
 
 select * from layoffs;
 -- Creating copy of orignal Data set 
 
 create table layoffs_staaging like  layoffs;
 select * from layoffs;
 
 insert layoffs_staaging select * from layoffs;
 select * from layoffs_staaging;
 
 -- Removing Duplicates
 
 with duplicate_cte as(
 select *,
 row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
 as row_num 
 from layoffs_staaging)
 select *  from duplicate_cte where 
 row_num >1;
 
 
 CREATE TABLE `layoffs_staaging2` (
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

 select * from layoffs_staaging2;
 
 insert into layoffs_staaging2
 select *,
 row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
 as row_num 
 from layoffs_staaging;
 
 delete from layoffs_staaging2 where row_num>1;
 
 select * from layoffs_staaging2;
 
 --  Standardizing Data
 
 select trim(company) from layoffs_staaging2;
 
 update layoffs_staaging2
 set company = trim(company);
 
 select distinct(industry) from layoffs_staaging2 ;
 
 select * from layoffs_staaging2 where industry like 'crypto%';
 
 select industry from layoffs_staaging2;
 
 update layoffs_staaging2
 set industry = null
 where industry ='';
 
  select distinct country,trim(trailing'.' from country) from layoffs_staaging2 order by 1;
  
  update layoffs_staaging2
  set country = trim(trailing'.' from country)
  where country like 'United States%';

select `date`, STR_TO_DATE(`date`, '%m/%d/%Y') from layoffs_staaging2;

update layoffs_staaging2 
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

 alter table layoffs_staaging2  modify column `date` DATE;
 
 -- working with null values 
 
 select * from layoffs_staaging2 where total_laid_off is null and percentage_laid_off is null;
 
 select * from layoffs_staaging2 where industry is null or industry = '';
  select * from layoffs_staaging2 where company ='Airbnb';
  select * from layoffs_staaging2;
 select *
 from layoffs_staaging2 t1
 join layoffs_staaging2 t2 
	on t1.company = t2.company 
where (t1.industry is null or t2.industry = '') 
and t2.industry is not null;
 
update layoffs_staaging2 t1
join layoffs_staaging2 t2 
	on t1.company = t2.company 
set t1.industry= t2.industry
where t1.industry is null
 and t2.industry is not null;

 
 
 -- Exploratory Data Analysis (EDA)
 
 select max(total_laid_off),max(percentage_laid_off) from layoffs_staaging2;
 select * from layoffs_staaging2 where percentage_laid_off =1
 order by funds_raised_millions desc;
 
 select company,sum(total_laid_off) from layoffs_staaging2
 group by company order by 1;
 
 select min(`date`),max(`date`) from layoffs_staaging2;
 
  select country,sum(total_laid_off) from layoffs_staaging2
 group by country order by 1;
 
 select year(`date`),sum(total_laid_off) from layoffs_staaging2
 group by year(`date`) order by 1;
 
 select stage,sum(total_laid_off) from layoffs_staaging2
 group by stage order by 2 desc;
 
 select company,avg(percentage_laid_off) from layoffs_staaging2
 group by company order by 1 desc;
 
 select substring(`date`,1,7) as month, sum(total_laid_off)
 from layoffs_staaging2 where substring(`date`,1,7) is not null
 group by `month` order by 1 asc;

 
 with rolling_total as
 (
  select substring(`date`,1,7) as month, sum(total_laid_off) as tlo
 from layoffs_staaging2 where substring(`date`,1,7) is not null
 group by `month` order by 1 asc
)
 select `month`,tlo, sum(tlo) over(order by `month`) as rolling_totals
 from rolling_total;
 
  select company,year(`date`),sum(total_laid_off) from layoffs_staaging2
 group by company,year(`date`) order by 3 desc;
 
 
 with company_year  (company,years,total_laid_off) as
 (
 select company,year(`date`),sum(total_laid_off) from layoffs_staaging2
 group by company,year(`date`)
 ),company_year_rank as
 (
 select *, dense_rank() over(partition by years order by total_laid_off desc ) as ranking from company_year
 where years is not null
 order by ranking asc)
 select * from  company_year_rank where ranking <=5;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 