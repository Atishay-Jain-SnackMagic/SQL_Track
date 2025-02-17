-- DROP TABLE IF EXISTS departments, employees, commissions;

CREATE TABLE departments(
	id INT PRIMARY KEY,
	name TEXT
);

CREATE TABLE employees(
	id INT PRIMARY KEY,
	name TEXT,
	salary NUMERIC,
	department_id INT NOT NULL REFERENCES departments(id)
);

CREATE TABLE commissions(
	id INT PRIMARY KEY,
	employee_id INT NOT NULL REFERENCES employees(id),
	commission_amount NUMERIC
);

CREATE INDEX idx_employees_salary ON employees(salary);

INSERT INTO departments(id, name) VALUES
	(1, 'Banking'),
	(2, 'Insurance'),
	(3, 'Services');

INSERT INTO employees(id, name, salary, department_id) VALUES
	(1, 'Chris Gayle', 1000000, 1),
	(2, 'Michael Clarke', 800000, 2),
	(3, 'Rahul Dravid', 700000, 1),
	(4, 'Ricky Pointing', 600000, 2),
	(5, 'Albie Morkel', 650000, 2),
	(6, 'Wasim Akram', 750000, 3);

INSERT INTO commissions(id, employee_id, commission_amount) VALUES
	(1, 1, 5000),
	(2, 2, 3000),
	(3, 3, 4000),
	(4, 1, 4000),
	(5, 2, 3000),
	(6, 4, 2000),
	(7, 5, 1000),
	(8, 6, 5000);

-- Find the employee who gets the highest total commission
SELECT employee_id
FROM commiSsions
GROUP BY employee_id
ORDER BY SUM(commission_amount) DESC
LIMIT 1;

-- Find employee with 4th Highest salary from employee table
SELECT *
FROM employees
ORDER BY salary DESC
OFFSET 3
LIMIT 1;

-- Find department that is giving highest commission.
SELECT department_id, SUM(COMMISSION_AMOUNT)
FROM employees e
INNER JOIN commissions c ON e.id = c.employee_id
GROUP BY department_id
ORDER BY SUM(commission_amount) DESC
LIMIT 1;

-- Find employees getting commission more than 3000
SELECT string_agg(name, ', '), amount
FROM employees e, (SELECT employee_id, SUM(commission_amount) AS amount FROM commissions GROUP BY employee_id) AS c
WHERE e.id = c.employee_id AND amount > 3000
GROUP BY c.amount;
