-- =======================
-- HR Analytics - MySQL Version
-- Converted from Oracle to MySQL
-- =======================

-- Drop tables
DROP TABLE IF EXISTS promotions;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- Create tables
CREATE TABLE departments (
  department_id INT PRIMARY KEY,
  department_name VARCHAR(100)
);

CREATE TABLE employees (
  emp_id INT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  gender CHAR(1),
  department_id INT,
  job_title VARCHAR(100),
  hire_date DATE,
  salary DECIMAL(12,2),
  performance_score DECIMAL(5,2),
  FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE attendance (
  attendance_id INT PRIMARY KEY,
  emp_id INT,
  month_start DATE,
  days_present INT,
  days_absent INT,
  FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

CREATE TABLE promotions (
  promotion_id INT PRIMARY KEY,
  emp_id INT,
  promotion_date DATE,
  new_title VARCHAR(100),
  new_salary DECIMAL(12,2),
  FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- Insert departments
INSERT INTO departments VALUES
(1, 'Data & Analytics'),
(2, 'Human Resources'),
(3, 'Marketing'),
(4, 'Finance'),
(5, 'IT Support');

-- Insert employees
INSERT INTO employees VALUES
(101, 'John', 'Smith', 'M', 1, 'Data Analyst', '2018-04-12', 70000, 4.20),
(102, 'Priya', 'Sharma', 'F', 2, 'HR Executive', '2019-01-17', 55000, 4.50),
(103, 'David', 'Brown', 'M', 3, 'Marketing Lead', '2017-09-03', 85000, 3.80),
(104, 'Sneha', 'Patil', 'F', 1, 'Data Engineer', '2020-07-22', 72000, 4.10),
(105, 'Arjun', 'Rao', 'M', 2, 'HR Manager', '2016-11-15', 92000, 4.60),
(106, 'Aisha', 'Khan', 'F', 3, 'Marketing Analyst', '2021-03-10', 63000, 4.00),
(107, 'Rohit', 'Desai', 'M', 4, 'Finance Analyst', '2015-06-01', 78000, 3.90),
(108, 'Meera', 'Iyer', 'F', 5, 'IT Support Engineer', '2022-02-20', 50000, 3.70),
(109, 'Sameer', 'Patel', 'M', 1, 'Senior Data Analyst', '2014-10-05', 95000, 4.70),
(110, 'Kavita', 'Joshi', 'F', 4, 'Finance Manager', '2013-12-12', 102000, 4.40),
(111, 'Vikram', 'Malhotra', 'M', 3, 'Content Strategist', '2020-05-18', 61000, 3.95),
(112, 'Nisha', 'Verma', 'F', 5, 'IT Technician', '2019-08-09', 47000, 3.85);

-- Insert attendance
INSERT INTO attendance VALUES
(1, 101, '2024-07-01', 21, 2),
(2, 102, '2024-07-01', 20, 3),
(3, 103, '2024-07-01', 19, 4),
(4, 104, '2024-07-01', 22, 1),
(5, 105, '2024-07-01', 18, 5),
(6, 106, '2024-07-01', 20, 3),
(7, 107, '2024-07-01', 21, 2),
(8, 108, '2024-07-01', 22, 1),
(9, 109, '2024-07-01', 20, 3),
(10, 110, '2024-07-01', 19, 4),
(11, 111, '2024-07-01', 21, 2),
(12, 112, '2024-07-01', 22, 1),
(13, 101, '2024-08-01', 20, 3),
(14, 104, '2024-08-01', 21, 2),
(15, 105, '2024-08-01', 19, 4),
(16, 109, '2024-08-01', 22, 1);

-- Insert promotions
INSERT INTO promotions VALUES
(1, 101, '2022-03-01', 'Senior Data Analyst', 85000),
(2, 102, '2023-08-15', 'HR Specialist', 60000),
(3, 104, '2024-06-10', 'Senior Data Engineer', 90000),
(4, 109, '2021-11-20', 'Lead Data Scientist', 115000),
(5, 110, '2019-05-01', 'Senior Finance Manager', 120000);

-- ===========================
-- ANALYTICS QUERIES (MySQL)
-- ===========================

-- 1. Department-wise avg salary
SELECT d.department_name,
       ROUND(AVG(e.salary), 2) AS avg_salary,
       COUNT(*) AS headcount
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_salary DESC;

-- 2. Gender pay gap by department
SELECT d.department_name,
       e.gender,
       ROUND(AVG(e.salary), 2) AS avg_salary,
       COUNT(*) AS count_emp
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name, e.gender
ORDER BY d.department_name, e.gender;

-- 3. Top performers
SELECT emp_id,
       CONCAT(first_name, ' ', last_name) AS full_name,
       job_title,
       performance_score
FROM employees
ORDER BY performance_score DESC
LIMIT 10;

-- 4. Absenteeism %
SELECT e.emp_id,
       CONCAT(e.first_name, ' ', e.last_name) AS full_name,
       SUM(a.days_present) AS total_present,
       SUM(a.days_absent) AS total_absent,
       ROUND((SUM(a.days_absent) / (SUM(a.days_present) + SUM(a.days_absent))) * 100, 2) AS absence_pct
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
GROUP BY e.emp_id
ORDER BY absence_pct DESC;

-- 5. Promotion analysis
SELECT e.emp_id,
       CONCAT(e.first_name, ' ', e.last_name) AS full_name,
       e.job_title AS old_title,
       p.new_title,
       e.salary AS old_salary,
       p.new_salary,
       p.promotion_date,
       (p.new_salary - e.salary) AS salary_increase
FROM promotions p
JOIN employees e ON p.emp_id = e.emp_id
ORDER BY salary_increase DESC;

-- 6. Salary rank per department
SELECT d.department_name,
       e.emp_id,
       CONCAT(e.first_name, ' ', e.last_name) AS full_name,
       e.salary,
       DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS dept_salary_rank
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY d.department_name, dept_salary_rank;

-- 7. Absence group vs performance
WITH emp_abs AS (
  SELECT e.emp_id,
         CONCAT(e.first_name, ' ', e.last_name) AS full_name,
         e.performance_score,
         COALESCE(SUM(a.days_absent),0) AS total_absent
  FROM employees e
  LEFT JOIN attendance a ON e.emp_id = a.emp_id
  GROUP BY e.emp_id
)
SELECT 
  CASE 
     WHEN total_absent >= 6 THEN 'High absence (>=6)'
     WHEN total_absent >= 3 THEN 'Medium absence (3-5)'
     ELSE 'Low absence (0-2)'
  END AS absence_group,
  ROUND(AVG(performance_score),2) AS avg_perf,
  COUNT(*) AS emp_count
FROM emp_abs
GROUP BY absence_group;
