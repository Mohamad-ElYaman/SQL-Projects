/*
This SQL exercise's purpose is to show overall information on the company and answer questions related to departments and performance
Some more specific queries were used to obtain information regarding attrition and job satisfaction
Answering questions such as "What employees deserve a raise?"
*/

-- Looking at number of employees in each department
SELECT COUNT("EmployeeNumber") AS "EmployeeCount", "Department"
FROM PUBLIC."EmployeeInfo"
GROUP BY "Department";
/* 
Count  Department
63	   "Human Resources  
961	   "Research & Development 
446	   "Sales
*/

-- Looking at number of employees for each job role in each department
SELECT "JobRole", "Department", COUNT(*) AS "EmployeeCount"
FROM PUBLIC."EmployeeInfo"
GROUP BY 2, 1;
-- Sales executive position contains the highest employee count at 326

-- Number of employees by department
SELECT  "Department", COUNT(*) AS "EmployeeCount", COUNT(DISTINCT "JobRole") AS "Number of Postitions"
FROM PUBLIC."EmployeeInfo"
GROUP BY 1;
-- Research & Development contains the highest total employee count at 961 with 6 available position
-- Human Resources with 63 employees and 2 positions, and Sales with 446 employees and 3 positions

-- Looking at average performance rating in each department
SELECT "Department", AVG("PerformanceRating") AS "AVGRating", "JobRole"
FROM PUBLIC."EmployeeInfo"
GROUP BY "Department", "JobRole"
ORDER BY "Department";
-- All department Share a similar average rating of around 3.15

-- Looking at Education levels for each department
SELECT "Education", COUNT(*) as count, "Department"
FROM PUBLIC."EmployeeInfo"
GROUP BY "Department", "Education"
ORDER BY "Department", count DESC;

-- Looking at total Rating for each department
SELECT "Department", "PerformanceRating", COUNT(*) AS "Total Rating"
FROM PUBLIC."EmployeeInfo"
GROUP BY "Department", "PerformanceRating"
ORDER BY 1;
-- The ratings are spread out evenly if count of rating are considered for each department


-- Looking at all new hires for each position in each department
SELECT "JobRole", COUNT(*) as "NewHires", "Department"
FROM PUBLIC."EmployeeInfo"
WHERE "YearsAtCompany" < 1
GROUP BY "Department", "JobRole";
/*
HR has not had any new hires in the most current year
Research & Development and Sales had hires in every department.
Research & Development had the highest employment count 
*/

-- Looking at the lowest 10 paid employees who have been at the company for atleast a year
SELECT"EmployeeNumber", "MonthlyIncome", "Department",
	"PerformanceRating", "YearsSinceLastPromotion", "YearsInCurrentRole"
FROM PUBLIC."EmployeeInfo"
WHERE "YearsInCurrentRole" > 0
ORDER BY "MonthlyIncome" ASC
LIMIT 10;
/*
Using this information to see which employee may be deserving of an increase in income
Based on their Income, performance rating, the time since they have last had a promotion, and time spent in current position
*/

-- Looking at how many attrition each department had
SELECT COUNT("Attrition") AS "NumOfAttritions", "Department"
FROM PUBLIC."EmployeeInfo"
WHERE "Attrition" = 1
GROUP BY "Department";
-- Research & Development had the highest attrition count at 133, followed by Sales at 92

-- Looking at job satisfaction rate in each department
SELECT "Department", "JobSatisfaction", COUNT(*)
FROM PUBLIC."EmployeeInfo"
GROUP BY "Department", "JobSatisfaction"
ORDER BY 1, "JobSatisfaction" DESC;
-- Human Resources has a higher count of lower job satisfaction rating when regarding employee count


-- Looking at new employees and how much training they have recieved
-- To look for any employeed with missing training to complete in the current year
SELECT "EmployeeNumber", "Age", "YearsAtCompany", "YearsWithCurrManager", "TrainingTimesLastYear", "YearsInCurrentRole"
FROM  PUBLIC."EmployeeInfo"
WHERE "TrainingTimesLastYear" <= 2 AND "YearsInCurrentRole" < 2;
-- Employee 90 has been at the company for a year, working under a new manager
-- with 0 training in the previous year. this is an employee to investigate further
-- for job knowledge and potential requirement for training


-- Looking at employeers who have not received a promotion having high performance rating
SELECT "EmployeeNumber", "Age", "YearsAtCompany",
"YearsWithCurrManager", "YearsInCurrentRole",
"YearsSinceLastPromotion", "MonthlyIncome", "PerformanceRating"
FROM  PUBLIC."EmployeeInfo"
WHERE "YearsSinceLastPromotion" > 2 AND "PerformanceRating" > 3 AND "YearsInCurrentRole" < 10
ORDER BY "YearsSinceLastPromotion" DESC;
-- This information will help decide which employees would be deserving a consideration for a promotion

-- Looking at all employees with low job involvement
Select "MonthlyIncome", "EmployeeNumber", "JobInvolvement",
"YearsAtCompany", "JobLevel", "PerformanceRating", "JobRole"
FROM  PUBLIC."EmployeeInfo"
Where "JobInvolvement" < 2;
-- This query is useful to investigate employee involvement further, and incase there was a need to downsize for any department

--Looking at employees who have long work travel distance and if they share low job satisfaction
SELECT "EmployeeNumber", "DistanceFromHome" ,"JobSatisfaction"
FROM PUBLIC."EmployeeInfo"
Where "DistanceFromHome" > 20
ORDER BY "DistanceFromHome"
-- This query is helpful to determine if a relationship exists between travel distance and job satisfaction
-- As well as considering compensation options for long traveling periods such as gas compensation or work from home options






