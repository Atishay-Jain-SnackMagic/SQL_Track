CREATE TABLE testing_table(
	name TEXT,
	contact_name TEXT,
	roll_no TEXT
);

ALTER TABLE testing_table DROP COLUMN name;
ALTER TABLE testing_table RENAME COLUMN contact_name TO username;
ALTER TABLE testing_table ADD COLUMN first_name TEXT;
ALTER TABLE testing_table ADD COLUMN last_name TEXT;
ALTER TABLE testing_table ALTER COLUMN roll_no TYPE INT USING roll_no::INTEGER;

SELECT * FROM testing_table;
