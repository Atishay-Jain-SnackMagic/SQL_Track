DROP TABLE IF EXISTS responses;
CREATE TABLE responses(
	id SERIAL PRIMARY KEY,
	email VARCHAR(50) UNIQUE,
	contact VARCHAR(10) UNIQUE,
	city VARCHAR(30)
);


-- Reason of using 'sed "s/ , /,/g" /home/ubuntu/Downloads/email_subscribers.txt' is that the delimiter in copy takes only one byte character and we have 3 byte character
COPY responses(email, contact, city) FROM PROGRAM 'sed "s/ , /,/g" /home/ubuntu/Downloads/email_subscribers.txt' DELIMITER ',';

SELECT * FROM responses;

-- What all cities did people respond from
SELECT DISTINCT(city)
FROM responses;

-- How many people responded from each city
SELECT city, COUNT(*) as count_respondents
FROM responses
GROUP BY city;

-- Which city were the maximum respondents from?(using subquery)
SELECT city
FROM responses
GROUP BY city
HAVING COUNT(*) = (
	SELECT count(*)
	FROM responses
	GROUP BY city
	ORDER BY COUNT(*) DESC
	LIMIT 1
);

-- Which city were the maximum respondents from? (using rank)
SELECT city
FROM (
	SELECT city, 
		RANK() OVER (ORDER BY COUNT(*) DESC) as rnk
	FROM responses
	GROUP BY city
) WHERE rnk = 1;

-- What all email domains did people respond from ?
SELECT DISTINCT SUBSTRING(email FROM '@(.*)$') AS domain
FROM responses;

-- What all email domains did people respond from? (another approach)
SELECT DISTINCT SPLIT_PART(email, '@', 2) AS domain
FROM responses;

-- Which is the most popular email domain among the respondents?
SELECT domain
FROM (
	SELECT SPLIT_PART(email, '@', 2) AS domain,
		RANK() OVER (ORDER BY COUNT(*) DESC) as rnk
	FROM responses
	GROUP BY domain
) as domain_rnk
WHERE rnk = 1;
