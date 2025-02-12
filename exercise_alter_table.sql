CREATE TABLE testing_table(
	name TEXT,
	contact_name TEXT,
	roll_no TEXT
);

ALTER TABLE testing_table DROP COLUMN name;
ALTER TABLE testing_table RENAME contact_name TO username;
ALTER TABLE testing_table ALTER COLUMN roll_no TYPE INT USING roll_no::INTEGER;
SELECT *
FROM information_schema.columns
WHERE table_name = 'testing_table';
