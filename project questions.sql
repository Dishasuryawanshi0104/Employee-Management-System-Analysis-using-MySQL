use employeedb;

-- 1. EMPLOYEE INSIGHTS

-- How many unique employees are currently in the system ?
 
select count( distinct emp_ID) as unique_employee
from employee;
 
-- Which departments have the highest number of employees?

SELECT 
    jd.jobdept,
    COUNT(e.emp_ID) AS total_employees
FROM Employee e
JOIN JobDepartment jd
    ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY total_employees DESC 
limit 2;

-- What is the average salary per department?

SELECT 
	jobdepartment.jobdept,
    avg(salarybonus.annual) as salary
FROM salarybonus
join jobdepartment
on jobdepartment.Job_ID = salarybonus.salary_ID
group by jobdept
order by salary desc;

-- Who are the top 5 highest-paid employees?

select 
employee.emp_ID, employee.firstname, employee.lastname,
max(salarybonus.annual) as salary
from salarybonus
join employee
on employee.emp_ID = salarybonus.salary_ID
group by emp_ID
order by salary desc
limit 5;
   
-- What is the total salary expenditure across the company?

select
sum(salarybonus.annual) as total_salary
from salarybonus;


-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- How many different job roles exist in each department?

select jobdept ,
count(distinct name) as total_role
from jobdepartment
group by jobdept;

-- What is the average salary range per department?

SELECT 
	jobdept,
    min(annual) as min_salary,
	max(annual) as max_salary, 
    avg(annual) as avg_salary
FROM salarybonus
join jobdepartment
on jobdepartment.job_ID = salarybonus.salary_ID
group by jobdept;

-- Which job roles offer the highest salary?

SELECT 
	name ,
	max(annual) as max_salary
FROM salarybonus
join jobdepartment
on jobdepartment.job_ID = salarybonus.salary_ID
group by name
order by max_salary desc
limit 1;


-- Which departments have the highest total salary allocation?

SELECT 
	jobdept ,
	sum(annual) as sum_salary
FROM salarybonus
join jobdepartment
on jobdepartment.job_ID = salarybonus.salary_ID
group by jobdept
order by sum_salary desc
limit 1;


-- 3. QUALIFICATION AND SKILLS ANALYSIS

-- How many employees have at least one qualification listed?

SELECT 
    COUNT(DISTINCT QualID) AS emp_qualification
FROM qualification;


-- Which positions require the most qualifications?

SELECT 
	Qualification.position ,
    COUNT(Qualification.qualID) AS total_qualifications
FROM Qualification
JOIN Employee e
    ON Qualification.qualID = e.job_ID
JOIN Qualification Q
    ON e.emp_id = Q.emp_id
GROUP BY Qualification.position
ORDER BY total_qualifications DESC;



-- Which employees have the highest number of qualifications?

SELECT 
    jd.jobdept AS position,
    COUNT(q.emp_id) AS total_qualifications
FROM JobDepartment jd
JOIN Employee e
    ON jd.job_ID = e.job_ID
JOIN Qualification q
    ON e.emp_id = q.emp_id
GROUP BY jd.jobdept
ORDER BY total_qualifications DESC
limit 1;

-- 4. LEAVE AND ABSENCE PATTERNS

-- Which year had the most employees taking leaves?

select 
leave_ID ,
max(date) as year
from leaves
join employee e
on e.emp_ID = leaves.leave_ID
group by leave_ID;


-- What is the average number of leave days taken by its employees per department?

SELECT 
    jd.jobdept AS department,
    round(AVG(emp_leave.leave_count),2) AS avg_leave_days
FROM JobDepartment jd
JOIN Employee e 
    ON jd.Job_ID = e.Job_ID
LEFT JOIN (
    SELECT 
        emp_ID,
        COUNT(leave_ID) AS leave_count
    FROM Leaves
    GROUP BY emp_ID
) AS emp_leave
    ON e.emp_ID = emp_leave.emp_ID
GROUP BY jd.jobdept;


-- Which employees have taken the most leaves?

SELECT 
    jd.jobdept AS department,
    count(emp_leave.leave_count) AS leave_days
FROM JobDepartment jd
JOIN Employee e 
    ON jd.Job_ID = e.Job_ID
LEFT JOIN (
    SELECT 
        emp_ID,
        COUNT(leave_ID) AS leave_count
    FROM Leaves
    GROUP BY emp_ID
) AS emp_leave
    ON e.emp_ID = emp_leave.emp_ID
GROUP BY jd.jobdept
order by leave_days desc
limit 2;

-- What is the total number of leave days taken company-wide?

select 
count(leaves.leave_ID) as total_leaves
from leaves
join employee
on employee.emp_ID = leaves.leave_ID;

-- How do leave days correlate with payroll amounts?

SELECT 
    p.emp_ID,
    COUNT(l.leave_ID) AS total_leave_days,
    sb.amount AS monthly_salary,
    (sb.amount - (COUNT(l.leave_ID) * (sb.amount / 30))) AS payroll_after_leave
FROM Payroll p
JOIN SalaryBonus sb
    ON p.salary_ID = sb.salary_ID
LEFT JOIN Leaves l
    ON p.emp_ID = l.emp_ID
GROUP BY p.emp_ID, sb.amount;


        
-- 5. PAYROLL AND COMPENSATION ANALYSIS

-- What is the total monthly payroll processed?

select
sum(total_amount) as total_monthly_Payroll
from payroll ;

-- What is the average bonus given per department?

SELECT 
	jobdepartment.jobdept,
    avg(salarybonus.bonus) as bonus
FROM salarybonus
join jobdepartment
on jobdepartment.Job_ID = salarybonus.salary_ID
group by jobdept
order by bonus desc;

-- Which department receives the highest total bonuses?

SELECT 
	jobdepartment.jobdept,
    sum(salarybonus.bonus) as bonus
FROM salarybonus
join jobdepartment
on jobdepartment.Job_ID = salarybonus.salary_ID
group by jobdept
order by bonus desc
limit 1;

-- What is the average value of total_amount of employee after considering leave deductions?

SELECT 
    e.emp_ID,
    CONCAT(e.firstname, ' ', e.lastname) AS employee_name,
    ROUND(
        AVG(p.total_amount - IFNULL(lc.leave_count * (sb.amount / 30), 0)),
        2
    ) AS avg_amount_after_leave_deduction
FROM Employee e
JOIN Payroll p
    ON e.emp_ID = p.emp_ID
JOIN SalaryBonus sb
    ON p.salary_ID = sb.salary_ID
LEFT JOIN (
    SELECT emp_ID, COUNT(leave_ID) AS leave_count
    FROM Leaves
    GROUP BY emp_ID
) lc
    ON e.emp_ID = lc.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname;






