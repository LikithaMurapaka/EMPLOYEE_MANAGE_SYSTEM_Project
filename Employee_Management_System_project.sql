CREATE DATABASE EMPLOYEE_MANAGE_SYSTEM;
USE EMPLOYEE_MANAGE_SYSTEM;

CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
DESC JobDepartment;
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
desc JobDepartment;
desc SalaryBonus;
desc Employee;
desc Qualification;
desc Payroll;
desc Leaves;
SELECT * FROM  JobDepartment;
SELECT * FROM  SalaryBonus;
SELECT * FROM  Employee;
SELECT * FROM  Qualification;
SELECT * FROM  Leaves;
SELECT * FROM Payroll; 

SELECT CONCAT_WS(' ',FIRSTNAME,LASTNAME) AS FULLNAME
FROM EMPLOYEE;

ALTER TABLE EMPLOYEE
ADD FULLNAME VARCHAR(100);

UPDATE EMPLOYEE
SET FULLNAME=CONCAT_WS(' ',FIRSTNAME,LASTNAME);

--  EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
SELECT COUNT(DISTINCT(EMP_ID)) AS TOTAL_UNIQUE_EMPLOYEES
FROM EMPLOYEE;

-- Which departments have the highest number of employees?
SELECT JOBDEPT,COUNT(EMP_ID) AS TOTALEMPLOYEES
FROM Employee AS E
JOIN JobDepartment AS J
ON E.JOB_ID=J.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY TOTALEMPLOYEES DESC LIMIT 2;

-- What is the average salary per department?
SELECT J.JOBDEPT,AVG(S.AMOUNT+S.BONUS) AS AVG_SALARY
FROM JobDepartment AS J
JOIN SalaryBonus AS S
ON J.JOB_ID=S.JOB_ID
GROUP BY J.JOBDEPT;

-- Who are the top 5 highest-paid employees?
SELECT E.FULLNAME,S.ANNUAL
FROM SalaryBonus AS S
JOIN EMPLOYEE AS E
ON S.JOB_ID=E.JOB_ID
ORDER BY S.ANNUAL DESC LIMIT 5;

SELECT E.emp_ID,
       E.fULLname,
       JD.jobdept,
       SB.amount AS salary
FROM Employee E
JOIN SalaryBonus SB
ON E.Job_ID = SB.Job_ID
JOIN JobDepartment JD
ON E.Job_ID = JD.Job_ID
ORDER BY SB.amount DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT SUM(AMOUNT) AS total_salary_expenditure
FROM SalaryBonus;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
SELECT JOBDEPT,COUNT(DISTINCT(NAME)) AS TOTAL_JIB_ROLES
FROM JobDepartment
GROUP BY JOBDEPT;

-- What is the average salary range per department?
SELECT J.JOBDEPT,AVG(S.AMOUNT) AS AVGSALARY
FROM JobDepartment AS J
JOIN SalaryBonus AS S
ON J.JOB_ID=S.JOB_ID
GROUP BY J.JOBDEPT;

-- Which job roles offer the highest salary?
SELECT J.NAME,MAX(S.AMOUNT) AS MAXSALARY
FROM JobDepartment AS J
JOIN SalaryBonus AS S
ON J.JOB_ID=S.JOB_ID
GROUP BY J.NAME
ORDER BY MAXSALARY DESC LIMIT 1; 


-- Which departments have the highest total salary allocation?
SELECT J.JOBDEPT,SUM(S.AMOUNT) AS TOTAL_SALARY
FROM JobDepartment AS J
JOIN SalaryBonus AS S
ON J.JOB_ID=S.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY TOTAL_SALARY DESC LIMIT 1; 

-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT EMP_ID) AS EMPLOYEES_WITH_QUALIFICATIONS
FROM Qualification; 

-- Which positions require the most qualifications?
SELECT POSITION,COUNT(QUALID)
FROM Qualification
GROUP BY POSITION
ORDER BY COUNT(REQUIREMENTS) DESC;

-- Which employees have the highest number of qualifications?
SELECT E.EMP_ID,FULLNAME,COUNT(Q.QUALID) AS TOTAL_NUM_QUALIFICATIONS
FROM Employee AS E
JOIN Qualification AS Q
ON E.EMP_ID=Q.EMP_ID
GROUP BY E.EMP_ID,FULLNAME
ORDER BY TOTAL_NUM_QUALIFICATIONS DESC;

-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
SELECT YEAR(L.DATE) AS LEAVE_YEAR,COUNT(DISTINCT(E.EMP_ID))
FROM LEAVES AS L
JOIN EMPLOYEE AS E
ON L.EMP_ID=E.EMP_ID
GROUP BY LEAVE_YEAR
ORDER BY LEAVE_YEAR DESC LIMIT 1;

-- What is the average number of leave days taken by its employees per department?
SELECT JD.jobdept,
       AVG(leave_count) AS avg_leave_days
FROM
(
    SELECT E.emp_ID,
           E.Job_ID,
           COUNT(L.leave_ID) AS leave_count
    FROM Employee E
    LEFT JOIN Leaves L
    ON E.emp_ID = L.emp_ID
    GROUP BY E.emp_ID, E.Job_ID
) AS LeaveData
JOIN JobDepartment JD
ON LeaveData.Job_ID = JD.Job_ID
GROUP BY JD.jobdept;


-- Which employees have taken the most leaves?
SELECT E.FULLNAME,E.EMP_ID, COUNT(L.LEAVE_ID) AS NOLEAVES
FROM EMPLOYEE AS E
LEFT JOIN LEAVES AS L
ON E.EMP_ID=L.EMP_ID
GROUP BY E.FULLNAME,E.EMP_ID
ORDER BY NOLEAVES DESC;

-- What is the total number of leave days taken company-wide?
SELECT COUNT(LEAVE_ID) AS TOTAL_LEAVES
FROM LEAVES;

-- How do leave days correlate with payroll amounts?
SELECT P.EMP_ID,P.TOTAL_AMOUNT,COUNT(L.LEAVE_ID) AS TOTALLEAVES
FROM LEAVES AS L
JOIN Payroll AS P
ON L.EMP_ID=P.EMP_ID
GROUP BY P.EMP_ID,P.TOTAL_AMOUNT
ORDER BY TOTALLEAVES;

SELECT * FROM  JobDepartment;
SELECT * FROM  SalaryBonus;
SELECT * FROM  Employee;
SELECT * FROM  Qualification;
SELECT * FROM  Leaves;
SELECT * FROM Payroll; 

-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
SELECT MONTH(DATE) AS MONTHLY,SUM(TOTAL_AMOUNT) AS MONTHLY_PAYROLL
FROM PAYROLL
GROUP BY MONTHLY
ORDER BY MONTHLY_PAYROLL;

-- What is the average bonus given per department?
SELECT J.JOBDEPT,AVG(S.BONUS) AS AVGBONUS
FROM JobDepartment AS J
LEFT JOIN SalaryBonus AS S
ON J.JOB_ID=S.JOB_ID
GROUP BY J.JOBDEPT;

-- Which department receives the highest total bonuses?
SELECT J.JOBDEPT,SUM(S.BONUS) AS TOTALBONUS
FROM JobDepartment AS J
LEFT JOIN SalaryBonus AS S
ON J.JOB_ID=S.JOB_ID
GROUP BY J.JOBDEPT
ORDER BY TOTALBONUS DESC LIMIT 1;

-- What is the average value of total_amount after considering leave deductions?
SELECT AVG(total_amount) AS Avg_Net_Payment
FROM Payroll;

