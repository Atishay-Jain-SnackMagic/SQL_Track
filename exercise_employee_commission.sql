-- DROP TABLE IF EXISTS departments, employees, commissions;

CREATE TABLE departments(
	id SERIAL PRIMARY KEY,
	name TEXT
);

CREATE TABLE employees(
	id SERIAL PRIMARY KEY,
	name TEXT,
	salary NUMERIC,
	department_id INT NOT NULL REFERENCES departments(id)
);

CREATE TABLE commissions(
	id SERIAL PRIMARY KEY,
	employee_id INT NOT NULL REFERENCES employees(id),
	commission_amount NUMERIC
);

CREATE INDEX idx_employees_salary ON employees(salary);

INSERT INTO departments(name) VALUES
	('Banking'),
	('Insurance'),
	('Services');

INSERT INTO employees(name, salary, department_id) VALUES
	('Chris Gayle', 1000000, 1),
	('Michael Clarke', 800000, 2),
	('Rahul Dravid', 700000, 1),
	('Ricky Pointing', 650000, 2),
	('Albie Morkel', 650000, 2),
	('Wasim Akram', 700000, 3);

INSERT INTO commissions(employee_id, commission_amount) VALUES
	(1, 5000),
	(2, 3000),
	(3, 4000),
	(1, 4000),
	(2, 3000),
	(4, 2000),
	(5, 9000),
	(6, 5000);

-- Find the employee who gets the highest total commission
SELECT e.*
FROM employees e
INNER JOIN commissions c ON e.id = c.employee_id
GROUP BY e.id
HAVING SUM(commission_amount) = ( 
	SELECT SUM(commission_amount) as amt
	FROM commissions 
	GROUP BY employee_id
	ORDER BY amt DESC
	LIMIT 1
);

-- Find the employee who gets the highest total commission (using rank)
SELECT e.*
FROM employees e
INNER JOIN (
    SELECT employee_id, 
           SUM(commission_amount) AS total_commission,
           RANK() OVER (ORDER BY SUM(commission_amount) DESC) AS rnk
    FROM commissions
    GROUP BY employee_id
) cr ON e.id = cr.employee_id
WHERE cr.rnk = 1;

-- Find employee with 4th Highest salary from employee table (if 2 employees have same salary then, this will return the data as per the order of scan)
SELECT *
FROM employees
ORDER BY salary DESC
OFFSET 3
LIMIT 1;

-- Find employee with 4th Highest salary from employee table
SELECT *
FROM employees
WHERE salary = (
    SELECT DISTINCT salary
    FROM employees
    ORDER BY salary DESC
    LIMIT 1 OFFSET 3
);


-- Another way using dense rank
SELECT *
FROM (
    SELECT *, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk 
    FROM employees
) ranked
WHERE rnk = 4;


-- Find department that is giving highest commission. (using subquery)
SELECT d.name, SUM(commission_amount) as commission
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
INNER JOIN commissions c ON e.id = c.employee_id
GROUP BY d.id
HAVING SUM(commission_amount) = (
	SELECT MAX(total_commission)
    FROM (
        SELECT SUM(c.commission_amount) AS total_commission
        FROM employees e
        INNER JOIN commissions c ON e.id = c.employee_id
        GROUP BY e.department_id
    )
);

-- Find department that is giving highest commission(using rank)
SELECT name, commission
FROM (
    SELECT d.name, SUM(c.commission_amount) AS commission,
           RANK() OVER (ORDER BY SUM(c.commission_amount) DESC) AS rnk
    FROM employees e
    INNER JOIN departments d ON e.department_id = d.id
    INNER JOIN commissions c ON e.id = c.employee_id
    GROUP BY d.id, d.name
) ranked
WHERE rnk = 1;

-- Find employees getting commission more than 3000
SELECT string_agg(name, ', '), amount
FROM employees e, (SELECT employee_id, SUM(commission_amount) AS amount FROM commissions GROUP BY employee_id) AS c
WHERE e.id = c.employee_id AND amount > 3000
GROUP BY c.amount;

-- Find employees getting commission more than 3000, as a single column
SELECT CONCAT(string_agg(name, ', '),'    ', amount)
FROM employees e, (SELECT employee_id, SUM(commission_amount) AS amount FROM commissions GROUP BY employee_id) AS c
WHERE e.id = c.employee_id AND amount > 3000
GROUP BY c.amount;

-- Find employees getting commission more than 3000, without summing
SELECT string_agg(DISTINCT(name), ', '), commission_amount
FROM employees e
INNER JOIN commissions c ON e.id = c.employee_id
WHERE c.commission_amount > 3000
GROUP BY c.commission_amount;
