create database companydb;
use companydb;

CREATE TABLE departments (

    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

INSERT INTO departments VALUES
(1, 'Engineering'),
(2, 'Marketing'),
(3, 'Sales'),
(4, 'HR');

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT,
    salary DECIMAL(10,2),
    joining_date DATE,
    manager_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

INSERT INTO employees VALUES
(101, 'Alice', 'Johnson', 1, 75000.00, '2022-01-15', NULL),
(102, 'Bob', 'Smith', 1, 60000.00, '2022-03-10', 101),
(103, 'Charlie', 'Lee', 2, 55000.00, '2023-02-01', NULL),
(104, 'David', 'Kim', 2, 50000.00, '2023-04-05', 103),
(105, 'Eva', 'Martinez', 3, 45000.00, '2023-01-20', NULL),
(106, 'Frank', 'Wright', 3, 42000.00, '2023-05-15', 105),
(107, 'Grace', 'Hall', 1, 67000.00, '2024-01-11', 101),
(108, 'Hannah', 'Davis', 4, 47000.00, '2022-11-12', NULL),
(109, 'Ian', 'Clark', 1, 62000.00, '2023-07-10', 101),
(110, 'Jane', 'Lopez', 4, 46000.00, '2024-02-20', 108);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2)
);

INSERT INTO projects VALUES
(1, 'Website Redesign', '2023-01-01', '2023-03-31', 20000.00),
(2, 'Social Media Campaign', '2023-04-01', '2023-06-30', 15000.00),
(3, 'CRM Implementation', '2023-07-01', '2023-12-31', 50000.00),
(4, 'Recruitment Drive', '2023-01-15', '2023-04-15', 10000.00);

CREATE TABLE employee_projects (
    employee_id INT,
    project_id INT,
    allocation_pct INT,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

INSERT INTO employee_projects VALUES
(101, 1, 50),
(102, 1, 100),
(103, 2, 100),
(104, 2, 50),
(105, 3, 50),
(106, 3, 100),
(107, 1, 50),
(109, 3, 50),
(108, 4, 100),
(110, 4, 100);


------------------------------------------------------------------------------------------------------------------------------ 
# select queries basic to advance
-- 1. List all employees' full names and their salaries
select concat(first_name,' ',last_name)as name ,round(salary,0)as salary 
from employees;

-- 2. Show first name and joining date of employees who joined in 2023.
select first_name,joining_date 
from employees
where year(joining_date)=2023;

-- 3 Find employees who earn more than ₹60,000.
select first_name,salary
from employees
where salary>60000;

-- 4 Get the list of employees in the Engineering department
select e.first_name,d.department_name
from employees e
join departments d
on e.department_id=d.department_id
where d.department_name='Engineering';

-- 5 Find employees whose last name starts with ‘K’.
select last_name
from employees
where last_name regexp '^k';

-- 6  List the 3 most recently joined employees
select first_name,joining_date
from employees
order by joining_date desc
limit 3;

-- 7 Show the distinct departments present in the employee table.
select distinct d.department_name
from employees e
join departments d 
on e.department_id=d.department_id;

# 🔹 AGGREGATE & GROUP BY
-- 1. Count the number of employees in each department.
select count(e.employee_id)as no_of_employees,d.department_name
from employees e
join departments d
on e.department_id=d.department_id
group by d.department_name ;

-- 2 Find the average salary of employees in each department.
select round(avg(e.salary),1)as avg_salary, d.department_name
from employees e
join departments d
on e.department_id=d.department_id
group by d.department_name ;

-- 3 Get departments having more than 2 employees.
select d.department_name,count(e.employee_id) as emp_count
from employees e
join departments d
on e.department_id=d.department_id
group by d.department_name
having count(e.employee_id)>2 ;

#  JOINS
-- 1 List each employee's full name along with their department name.
select concat(e.first_name,' ',e.last_name)as name ,d.department_name 
from employees e
join departments d
on e.department_id=d.department_id;

-- 2 Show employee names and project names they are working on.
select concat(e.first_name,' ',e.last_name)as name,p.project_name
from employees e
join employee_projects ep
on e.employee_id=ep.employee_id
join projects p 
on  ep.project_id=p.project_id;

-- 3 List all employees and the number of projects they are assigned to.
select concat(e.first_name,' ',e.last_name)as name, count(ep.project_id)
from employees e 
left join employee_projects ep
on e.employee_id=ep.employee_id
group by e.employee_id;

-- or 

select concat(e.first_name,' ',e.last_name)as name, count(ep.project_id)
from employees e 
join employee_projects ep
on e.employee_id=ep.employee_id
group by name;

#  SUBQUERIES
-- 1 Find the names of employees who earn more than the average salary.
select concat(first_name, ' ',last_name ) as full_name,salary
from employees
where salary>(
select round(avg(salary),0)as avg_salary
from employees
) ;

-- 2 Get the name of the department with the highest number of employees.
select department_name
from departments
where department_id=(
select department_id
from employees
group by department_id
order by count(*) desc
limit 1
);

-- 3 List employees who are not assigned to any project.
select concat(first_name,' ',last_name ) as full_name
from employees
where employee_id not in (
select distinct employee_id
from employee_projects
);

# DATE FUNCTIONS
-- 1 List employees who joined before Jan 1, 2023.
select * 
from employees
where joining_date< '2023-01-01';

-- 2 Show employee names and how many months they’ve worked in the company.
select concat(first_name,' ',last_name)as name,joining_date,timestampdiff(month,joining_date,CURDATE())as months
from employees;

#  CASE & CONDITIONS
-- 1 Show each employee’s name, salary, and a column showing “Low”, “Medium”, or “High” salary level.
select concat(first_name,' ',last_name)as name, salary,
case 
when salary<50000 then 'low '
when salary<=60000 then 'medium '
else 'high '
end as salary_level
from employees;

-- 2 Display employee name and message: “Manager” if they manage someone, “Staff” otherwise.
select concat(first_name,' ',last_name)as name,
case
when manager_id is null then 'Staff'
else 'Manager'
end as message
from employeess;

# 🔹 COMMON TABLE EXPRESSIONS (CTEs)
-- 1 Using CTE, get departments where the average salary is more than ₹55,000.
with dept as(
select d.department_name,avg(e.salary) as avg_salary
from employees e 
join departments d 
on e.department_id=d.department_id
group by d.department_name
)
select * 
from dept
where avg_salary>55000;

# WINDOW FUNCTIONS
-- 1 Display employee names, salary, and their rank by salary within their department.
select concat(first_name,' ',last_name)as name,salary,department_id,
rank() over(partition by department_id order by  salary desc ) as salary_rank
from employees;


-- 2 Show cumulative salary (running total) of employees within each department.
select concat(first_name,' ',last_name)as name,department_id,round(salary,0),
sum(salary) over (partition by department_id order by salary) as c_salary
from employees;

-- 3 Find the employee with the highest salary in each department using window function.
select *
from (select concat(first_name,' ',last_name)as name,department_id,salary,
row_number() over(partition by department_id order by salary desc ) as highest_salary
from employees) rankk
where highest_salary=1;


-- 4 Show each employee’s salary and difference from the department average salary.
select 
       concat(first_name,' ',last_name)as name,
       department_id,
       salary,
       avg(salary) over (partition by department_id ) as avg_dept_salary,
       salary-avg(salary) over (partition by department_id )as difference_from_avg
from employees;




