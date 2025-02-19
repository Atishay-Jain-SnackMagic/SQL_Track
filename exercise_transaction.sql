-- To create a database
CREATE DATABASE bank;

-- To use the database (in psql)
\c bank;

-- Creating the relations
CREATE TABLE accounts(
	id SERIAL PRIMARY KEY,
	account_no INT UNIQUE NOT NULL,
	balance NUMERIC CHECK (balance >= 0)
);

CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	name TEXT,
	email TEXT,
	account_no INT UNIQUE NOT NULL REFERENCES accounts(account_no)
);

-- Inserting raw data
INSERT INTO accounts (account_no, balance) VALUES
	(1, 5000.00),
	(2, 12000.50),
	(3, 300.75);

INSERT INTO users (name, email, account_no) VALUES
	('userA', 'userA@example.com', 1),
	('userB', 'userB@example.com', 2),
	('userC', 'userC@example.com', 3);

-- userA is depositing 1000 Rs. to his account
BEGIN;
	UPDATE accounts
	SET balance = balance + 1000
	FROM (SELECT account_no FROM users WHERE name = 'userA' LIMIT 1) AS temp
	WHERE accounts.account_no = temp.account_no;
COMMIT;

-- userA is withdrawing 500 Rs. from his account
DO $$
DECLARE
	BEGIN
		UPDATE accounts 
		SET balance = balance - 500
		FROM (SELECT account_no FROM users WHERE name = 'userA' LIMIT 1) AS temp
		WHERE accounts.account_no = temp.account_no;

	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'rollback happened';
END $$;

-- userA is transferring 200 Rs to userB's account
DO $$
DECLARE
	BEGIN
		UPDATE accounts
		SET balance = balance - 200
		FROM (SELECT account_no FROM users WHERE name = 'userA' LIMIT 1) AS temp
		WHERE accounts.account_no = temp.account_no;

		UPDATE accounts
		SET balance = balance + 200
		FROM (SELECT account_no FROM users WHERE name = 'userB' LIMIT 1) AS temp
		WHERE accounts.account_no = temp.account_no;

	EXCEPTION WHEN OTHERS THEN
	    	RAISE NOTICE 'rollback happened';
END $$;

SELECT * FROM accounts;
