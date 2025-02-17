use dvj;
select * from career_change_prediction_dataset;

create table ccpd like career_change_prediction_dataset;
insert ccpd select * from career_change_prediction_dataset;

select * from ccpd;
describe ccpd;
with duplicated_cte as ( select *,row_number() over(partition  by
 Field_of_Study,
Current_Occupation, 
Age,
Gender, 
Years_of_Experience,
Education_Level, 
Industry_Growth_Rate,
Job_Satisfaction,
Work_Life_Balance,
Job_Opportunities,
Salary, 
Job_Security,
Career_Change_Interest, 
Skills_Gap,
Family_Influence,
Technology_Adoption) as row_num from ccpd)
select * from duplicated_cte where row_num >1;



select * from ccpd where Field_of_Study is null or Field_of_Study = '' or
Current_Occupation is null or Current_Occupation = '' or
Age is null or Age = '' or
Gender is null or Gender = '' or
Years_of_Experience is null or Years_of_Experience = '' or
Education_Level is null or Education_Level = '' or
Industry_Growth_Rate is null or Industry_Growth_Rate = '' or
Job_Satisfaction is null or Job_Satisfaction = '' or
Work_Life_Balance is null or  Work_Life_Balance = '' or 
Job_Opportunities is null or Job_Opportunities = '' or
Salary is null or Salary = '' or 
Job_Security is null or Job_Security  = '' or 
Skills_Gap is null or  Skills_Gap = '' or
Family_Influence is null or Family_Influence = '' or 
Technology_Adoption is null or Technology_Adoption = ''; 

-- EDA
describe ccpd;

 select min(Age) as min_age,max(Age) as max_age,avg(Age) as avg_age,
 min(Years_of_Experience) as min_Years_of_Experience,max(Years_of_Experience) as max_Years_of_Experience , avg(Years_of_Experience) as ang_Years_of_Experience,
 min(Salary) as min_salary,max(Salary) as max_Salary, avg(Salary) as avg_salary from ccpd;


select count(distinct Field_of_Study) as  unique_Field_of_Study,
count(distinct Education_Level) as unique_Education_Level,
count(distinct Gender) as unique_gender,
count(distinct Education_Level) as unique_Education_Level,
count(distinct  Current_Occupation) as unique_Current_Occupation 
from ccpd;
-- DISTRIBUTION OF MALE AND FEMALE ACROSS DIFFRENT FIELD 
select Gender, count(*) from ccpd  group by Gender;

-- TOP 10 MOST COMMON FIELD OF STUDIES
select Field_of_Study,count(*) as count from ccpd group by Field_of_Study order by count desc  limit 10;

SELECT * FROM CCPD;


-- CO-RELATION BETWEEN SALARY AND Years_of_Experience
SELECT 
(SUM((Salary - avg_Salary) * (Years_of_Experience - avg_Experience)) /
SQRT(SUM(POW(Salary - avg_Salary, 2)) * SUM(POW(Years_of_Experience - avg_Experience, 2)))) 
AS salary_Years_of_Experience_correlation
FROM (
SELECT 
Salary, Years_of_Experience, 
(SELECT AVG(Salary) FROM ccpd) AS avg_Salary, 
(SELECT AVG(Years_of_Experience) FROM ccpd) AS avg_Experience
FROM ccpd) AS subquery;

select Job_Satisfaction,Work_Life_Balance from ccpd;

-- CO-RELATION BETWEEN  JOB_SATISFACTION AND WORK_LIFE_BALANCE
 SELECT 
SUM((Job_Satisfaction - avg_Job_Satisfaction) * (Work_Life_Balance - avg_Work_Life_Balance)) /
SQRT(SUM(POW(Job_Satisfaction - avg_Job_Satisfaction, 2)) * 
SUM(POW(Work_Life_Balance - avg_Work_Life_Balance, 2))) AS Job_Satisfaction_Work_Life_Balance_corr
FROM (
SELECT 
Job_Satisfaction, 
Work_Life_Balance,
(SELECT AVG(Job_Satisfaction) FROM ccpd) AS avg_Job_Satisfaction,
(SELECT AVG(Work_Life_Balance) FROM ccpd) AS avg_Work_Life_Balance
FROM ccpd) AS subquery;

-- CO-RELATION BETWEEN  SALARY AND JOB_SATISFACTION

with avg_value as ( select avg(Job_Satisfaction) as avg_Job_Satisfaction,
avg(Salary) as avg_salary from ccpd)
select sum((Job_Satisfaction-avg_Job_Satisfaction) * (Salary -avg_salary)) /
sqrt(sum(pow(Job_Satisfaction-avg_Job_Satisfaction,2)) *
sum(pow(Salary -avg_salary,2))) as  SALARY_JOB_SATISFACTION_correlation
from ccpd,avg_value;

select Job_Satisfaction,Education_Level ,avg(Salary) as avg_salary from ccpd  group by Job_Satisfaction,Education_Level order by avg_Salary desc;

select Education_Level,Job_Satisfaction,count(*) from ccpd  group by Education_Level,Job_Satisfaction order by Education_Level,Job_Satisfaction;

select Technology_Adoption,count(*) from ccpd group by Technology_Adoption order by count(*) desc;

-- FIELD OF STUDY VS CURRENT OCCUPATION
select Field_of_Study,count(*) as count from ccpd group by Field_of_Study order by count;
 select Current_Occupation,count(*) as count from ccpd group by Current_Occupation order by count;
 
 -- FAMILIY INFLUENCE TO CHANGE FIELD OF STUDY
 SELECT Family_Influence,count(*) as count from ccpd group by Family_Influence order by count;
 
 -- CARRER CHANGE INTREST
 SELECT Family_Influence, COUNT(*) as count FROM CCPD where Career_Change_Interest='yes' group by Family_Influence order by count desc;
 
 -- EDUCATION LEVEL VS SALARY
 select Education_Level,avg(salary) as avg_salary, count(*) as count from ccpd  group by Education_Level order by avg_salary;
