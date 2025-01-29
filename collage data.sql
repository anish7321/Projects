select * from college_data;

create table collagedata_staging like college_data;
select  * from collagedata_staging;

insert collagedata_staging select * from college_data;
select  * from collagedata_staging;

with duplicate_cte as(
select *,
row_number() over(partition by College_ID ,Country,Total_Students,Male,Female,
CGPA,Annual_Family_Income,Branch, Research_Papers_Published,Placement_Rate) as row_num
from collagedata_staging)
select * from duplicate_cte where row_num > 1;

SELECT College_ID, Country, COUNT(*)
FROM collagedata_staging
GROUP BY College_ID, Country, Total_Students, Male, Female, CGPA, 
         Annual_Family_Income, Branch, Research_Papers_Published, Placement_Rate
HAVING COUNT(*) > 1;

select Branch from collagedata_staging;


SELECT * 
FROM collagedata_staging 
WHERE 
    College_ID = '' OR College_ID IS NULL OR
    Country = '' OR Country IS NULL OR
    Total_Students IS NULL OR
    Male IS NULL OR
    Female IS NULL OR
    CGPA IS NULL OR
    Annual_Family_Income IS NULL OR
    Branch = '' OR Branch IS NULL OR
    Placement_Rate IS NULL OR
    Faculty_Count IS NULL;


select country, sum(Male) as total_male,sum(Female) as total_female,
 avg(CGPA) as avg_cgpa,min(CGPA) as min_cgpa,
 max(CGPA) as max_cgpa,count(*) as total_records 
from collagedata_staging group by country;

select Placement_Rate, Country,Branch,
count(*) from collagedata_staging group by Placement_Rate,Country,Branch order by Placement_Rate desc;


-- NUMBER OF STUDENTS FOR TOP 5 COUNTRY

select country , sum(Male) as total_male,
sum(Female) as total_female ,
sum(Total_Students) as Total_Students
 from collagedata_staging
 group by country order by Total_Students desc limit 5; 
 
 -- Ratio of MALE AND FEMALE 
 
select country , sum(Male) as total_male,
sum(Female) as total_female ,sum(male) *100/nullif(sum(Male) + sum(Female),0) as percentage_male,
sum(Female) *100/nullif(sum(Male) + sum(Female),0) as percentage_Female from collagedata_staging
group by country
order by percentage_male,percentage_Female asc;

select Branch,sum(Research_Papers_Published) as total_researchpaper from collagedata_staging
 group by Branch order by total_researchpaper asc;

SELECT Sports, Branch,COUNT(*) AS college_count FROM collagedata_staging WHERE Sports IS NOT NULL GROUP BY Sports,Branch
ORDER BY college_count DESC;

SELECT College_ID, Country,Branch ,
(Total_Students * 1.0 / NULLIF(Faculty_Count, 0)) AS student_per_faculty FROM collagedata_staging ORDER BY student_per_faculty DESC  ;

select max(Annual_Family_Income),min(Annual_Family_Income),avg(Annual_Family_Income) from collagedata_staging;
 -- checking the co relation between income and cgpa (high income affect cgpa or not)
 
select case when  Annual_Family_Income < 500000 then 'low_income'
when Annual_Family_Income between 600000 and 1000000 then 'average_income'
else'high_inome' end as income_group, avg (CGPA) avg_cgpa from collagedata_staging
group by  income_group order by avg_cgpa;

select case when Male > Female  then 'male' else 'Female' end as high_scorer_gender, avg(CGPA) from collagedata_staging group by high_scorer_gender;
















