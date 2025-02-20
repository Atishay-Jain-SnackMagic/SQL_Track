-- DROP TABLE IF EXISTS asset_alLocations, common_assets, repairs, employees, categories, assets;

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE categories(
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE NOT NULL
);

CREATE TABLE assets(
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	category_id INT NOT NULL REFERENCES categories(id),
	purchase_date DATE NOT NULL,
	model TEXT NOT NULL,
	price DECIMAL(10, 2) NOT NULL,
	warranty_end DATE NOT NULL,
	allocable BOOLEAN DEFAULT 't',
	CHECK (warranty_end > purchase_date)
);

CREATE TABLE asset_allocations(
	id SERIAL PRIMARY KEY,
	asset_id INT REFERENCES assets(id),
	employee_id INT REFERENCES employees(id),
	start_date DATE,
	end_date DATE
);

CREATE TABLE common_assets(
	asset_id INT PRIMARY KEY,
	location TEXT
);

CREATE TABLE repairs(
	id SERIAL PRIMARY KEY,
	asset_id INT NOT NULL REFERENCES assets(id),
	repair_date DATE NOT NULL,
	cost DECIMAL(10, 2) NOT NULL,
	defect TEXT,
	warranty DATE
);


CREATE OR REPLACE FUNCTION set_default_warranty()
RETURNS TRIGGER AS $$
DECLARE
     category_ids INT[];
BEGIN
    SELECT array_agg(id) INTO category_ids 
    FROM categories 
    WHERE name IN ('Laptop', 'iPhone', 'Printer', 'Projector');

    IF NEW.warranty_end IS NULL AND NEW.category_id = ANY(category_ids) THEN
        NEW.warranty_end := NEW.purchase_date + INTERVAL '1 year';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_assets
BEFORE INSERT ON assets
FOR EACH ROW
EXECUTE FUNCTION set_default_warranty();


CREATE OR REPLACE FUNCTION validate_asset_allocation()
RETURNS TRIGGER AS $$
DECLARE
    is_allocable BOOLEAN;
    existing_allocation INT;
BEGIN
    SELECT allocable INTO is_allocable FROM assets WHERE id = NEW.asset_id;

    SELECT COUNT(*) INTO existing_allocation 
    FROM asset_allocations 
    WHERE asset_id = NEW.asset_id AND end_date IS NULL;

    IF is_allocable = FALSE THEN
        RAISE EXCEPTION 'This asset is not allocable.';
    END IF;

    IF existing_allocation > 0 THEN
        RAISE EXCEPTION 'This asset is already assigned to another employee.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_asset_allocations
BEFORE INSERT ON asset_allocations
FOR EACH ROW
EXECUTE FUNCTION validate_asset_allocation();


CREATE OR REPLACE FUNCTION validate_common_asset()
RETURNS TRIGGER AS $$
DECLARE
    is_allocable BOOLEAN;
BEGIN
    SELECT allocable INTO is_allocable FROM assets WHERE id = NEW.asset_id;

    IF is_allocable = TRUE THEN
        RAISE EXCEPTION 'This asset is allocable and cannot be stored in common assets.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_common_assets
BEFORE INSERT ON common_assets
FOR EACH ROW
EXECUTE FUNCTION validate_common_asset();


INSERT INTO categories(name) VALUES
	('Laptop'), ('iPhone'), ('Printer'), ('Projector'), ('Modem');

-- Insert Employees
INSERT INTO employees (name) VALUES
    ('Alice'), ('Bob'), ('Chris'), ('Duke'), ('Emily');

-- Insert Assets
INSERT INTO assets (name, category_id, purchase_date, model, price, warranty_end, allocable) VALUES
    ('Laptop A', 1, '2011-01-01', 'Model A', 1000.00, '2012-01-01', 't'),
    ('Laptop B', 1, '2011-01-01', 'Model B', 1200.00, '2012-01-01', 't'),
    ('Laptop N1', 1, '2023-01-01', 'Model N1', 1300.00, '2024-01-01', 't'),
    ('Laptop N2', 1, '2023-01-01', 'Model N2', 1500.00, '2024-01-01', 't'),
    ('iPhone A', 2, '2011-04-01', 'iPhone 4', 800.00, '2012-05-01', 't'),
    ('iPhone B', 2, '2011-01-01', 'iPhone 4', 900.00, '2012-01-01', 't'),
    ('Projector A', 4, '2011-08-15', 'Epson', 2000.00, '2012-08-15', 'f'),
    ('Printer A', 3, '2011-08-15', 'HP LaserJet', 500.00, '2012-08-15', 'f'),
    ('Printer B', 3, '2011-09-10', 'Canon Pixma', 600.00, '2012-09-09', 'f');

-- Insert Asset Allocations
INSERT INTO asset_allocations (asset_id, employee_id, start_date, end_date) VALUES
    (1, 1, '2011-01-01', '2011-12-31'),
    (1, 2, '2012-01-01', NULL),
    (3, 2, '2011-01-01', '2011-12-31'),
    (5, 1, '2011-04-01', NULL),
    (6, 2, '2011-01-01', NULL);

-- Insert Common Assets
INSERT INTO common_assets (asset_id, location) VALUES
    (7, 'Meeting Room'),
    (8, 'Meeting Room');


-- Find the name of the employee who has been alloted the maximum number of assets till date (using subquery)
SELECT e.*
FROM employees e
INNER JOIN asset_allocations a ON e.id = a.employee_id
GROUP BY e.id
HAVING COUNT(*) = (
	SELECT COUNT(*)
	FROM asset_allocations
	GROUP BY employee_id
	ORDER BY COUNT(*) DESC
	LIMIT 1
);

-- Find the name of the employee who has been alloted the maximum number of assets till date (using rank)
SELECT e.*
FROM employees e
INNER JOIN (
	SELECT employee_id,
	RANK() OVER (ORDER BY COUNT(*) DESC) as rnk
	FROM asset_allocations
	GROUP BY employee_id) AS a ON e.id = a.employee_id
WHERE rnk = 1;


-- Identify the name of the employee who currently has the maximum number of assets as of today
SELECT e.*
FROM employees e
INNER JOIN asset_allocations a ON e.id = a.employee_id
WHERE a.end_date IS NULL
GROUP BY e.id
HAVING COUNT(*) = (
	SELECT COUNT(*)
	FROM asset_allocations
	WHERE end_date IS NULL
	GROUP BY employee_id
	ORDER BY COUNT(*) DESC
	LIMIT 1
);

-- Identify the name of the employee who currently has the maximum number of assets as of today
SELECT e.*
FROM employees e
INNER JOIN (
	SELECT employee_id,
	RANK() OVER (ORDER BY COUNT(*) DESC) as rnk
	FROM asset_allocations
	WHERE end_date IS NULL
	GROUP BY employee_id) AS a ON e.id = a.employee_id
WHERE rnk = 1;

-- -- Find name and period of all the employees who have used a Laptop - let’s say laptop A - since it was bought by the company.
SELECT e.name, SUM(CASE 
	WHEN end_date IS NULL THEN (CURRENT_DATE)
	ELSE end_date
	END - start_date) AS PERIOD
FROM asset_allocations alloc
INNER JOIN assets a ON a.id = alloc.asset_id
INNER JOIN categories c ON a.category_id = c.id
INNER JOIN employees e ON e.id = alloc.employee_id
WHERE c.name = 'Laptop'
GROUP BY e.id;

-- Find the list of assets that are currently not assigned to anyone hence lying with the asset manage ( HR)
SELECT assets.*
FROM assets
LEFT JOIN (SELECT * FROM asset_allocations WHERE end_date IS NULL) AS asset_allocations ON assets.id = asset_allocations.asset_id
WHERE asset_allocations.id IS NULL

EXCEPT

SELECT assets.*
FROM assets
INNER JOIN common_assets ON assets.id = common_assets.asset_id;

-- Another way of doing this
SELECT *
FROM assets
WHERE id NOT IN (
	SELECT asset_id
	FROM asset_allocations 
	WHERE end_date IS NULL

	UNION

	SELECT asset_id
	FROM common_assets
);

-- An employee say Bob is leaving the company, write a query to get the list of assets he should be returning to the company.
SELECT a.*
FROM assets a
INNER JOIN (SELECT * FROM asset_allocations WHERE end_date IS NULL) AS temp ON a.id = temp.asset_id
INNER JOIN employees e ON e.id = temp.employee_id
WHERE e.name = 'Bob';

-- Write a query to find assets which are out of warranty.
SELECT *
FROM assets
WHERE CURRENT_DATE > warranty_end;

-- Return a list of Employee Names who do not have any asset assigned to them.
SELECT e.name
FROM employees e
LEFT JOIN (SELECT employee_id FROM asset_allocations WHERE end_date IS NULL) AS alloc ON alloc.employee_id = e.id
WHERE alloc.employee_id IS NULL;

-- Return a list of Employee Names who do not have any asset assigned to them (using subquery).
SELECT name
FROM employees
WHERE id NOT IN (
	SELECT employee_id
	FROM asset_allocations
	WHERE end_date IS NULL
);
