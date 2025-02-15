CREATE TYPE usertype AS ENUM('admin', 'normal');

CREATE TABLE categories(
	id INT PRIMARY KEY,
	name TEXT NOT NULL
);

CREATE TABLE users(
	id INT PRIMARY KEY,
	name TEXT NOT NULL,
	type usertype DEFAULT 'normal' NOT NULL
);

CREATE TABLE articles(
	id INT PRIMARY KEY,
	title TEXT NOT NULL,
	category_id INT REFERENCES categories(id),
	author_id INT REFERENCES users(id)
);

CREATE TABLE comments(
	id SERIAL PRIMARY KEY,
	article_id INT REFERENCES articles(id),
	user_id INT REFERENCES users(id),
	comment TEXT
);

-- Insert into categories
INSERT INTO categories (id, name) VALUES 
	(1, 'Technology'),
	(2, 'Health'),
	(3, 'Education'),
	(4, 'Sports'),
	(5, 'Science'),
	(6, 'Entertainment');


-- Insert into users
INSERT INTO users (id, name, type) VALUES 
	(1, 'Alice', 'admin'),
	(2, 'Bob', 'normal'),
	(3, 'user3', 'admin'),
	(4, 'David', 'admin'),
	(5, 'Emma', 'admin'),
	(6, 'Frank', 'normal'),
	(7, 'Grace', 'normal'),
	(8, 'Hannah', 'admin'),
	(9, 'Isaac', 'normal');

-- Insert into articles
INSERT INTO articles (id, title, category_id, author_id) VALUES 
	(1, 'AI Revolution', 1, 1),
	(2, 'Healthy Eating', 2, 2),
	(3, 'Learning PostgreSQL', 3, 3),
	(4, 'The Future of Quantum Computing', 5, 4),
	(5, 'Olympics 2024 Highlights', 4, 5),
	(6, 'Space Exploration Updates', 5, 6),
	(7, 'Blockchain and Its Applications', 1, 7),
	(8, 'Movie Industry Trends in 2025', 6, 8),
	(9, 'Nutrition for Athletes', 2, 9);

-- Insert into comments
INSERT INTO comments (article_id, user_id, comment) VALUES 
	(1, 2, 'Great insights!'),
	(2, 3, 'Very useful tips.'),
	(3, 1, 'Well explained!'),
	(4, 2, 'Quantum computing is fascinating!'),
	(5, 3, 'Can’t wait for the next Olympics!'),
	(6, 1, 'Space tech is evolving fast.'),
	(7, 5, 'Blockchain is the future of finance!'),
	(8, 6, 'Excited for the next big movie releases.'),
	(9, 4, 'Athletes need proper nutrition to perform their best.'),
	(1, 7, 'AI is changing the world rapidly.'),
	(3, 8, 'PostgreSQL is powerful for databases.'),
	(2, 9, 'Health is wealth, very informative.'),
	(3, 1, 'PostgreSQL is very powerful.');
	

-- Update a category name
UPDATE categories 
SET name = 'Tech & AI' 
WHERE id = 1;

-- Update a user's name
UPDATE users 
SET name = 'Alice Johnson' 
WHERE id = 1;

-- Update an article's title
UPDATE articles 
SET title = 'AI in 2025' 
WHERE id = 1;

-- Update a comment
UPDATE comments 
SET comment = 'Amazing article!' 
WHERE id = 1;

-- Delete comments with user_id = 2 or article having category_id = 2 or author_id = 2
DELETE FROM comments 
WHERE user_id = 2 OR article_id IN (
	SELECT id
	FROM articles
	WHERE category_id = 2 OR author_id = 2
);

-- Delete articles with id = 2 or category_id = 2 or author_id = 2
DELETE FROM articles 
WHERE id = 2 OR category_id = 2 OR author_id = 2;

-- Delete a user
DELETE FROM users 
WHERE id = 2;

-- Delete a category
DELETE FROM categories 
WHERE id = 2;


-- Select all articles whose author's name is user3
SELECT title
FROM articles
INNER JOIN users ON author_id = users.id
WHERE users.name = 	'user3';

-- select all the articles and also the comments associated with those articles in a single query
SELECT title, comment
FROM articles
INNER JOIN users ON author_id = users.id
INNER JOIN comments ON comments.article_id = articles.id
WHERE users.name = 	'user3';

-- select all the articles and also the comments associated with those articles in a single query (using nested subquery)
SELECT title, comment
FROM articles, (
	SELECT comment, article_id FROM comments
	) AS temp
WHERE articles.id = temp.article_id AND author_id IN (
	SELECT id FROM users WHERE name = 'user3'
	);

-- select all articles which do not have any comments
SELECT title
FROM articles
LEFT JOIN comments ON articles.id = comments.article_id
WHERE comments.id is NULL;

-- select all articles which do not have any comments(using subquery)
SELECT title
FROM articles a
WHERE NOT EXISTS(
	SELECT 1 FROM comments WHERE article_id = a.id
);

-- select article which has maximum comments
SELECT title
FROM articles a
INNER JOIN comments ON a.id = comments.article_id
GROUP BY a.id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- select article which does not have more than one comment by the same user
SELECT a.title
FROM articles a
LEFT JOIN (
    SELECT article_id, user_id, COUNT(*) AS comment_count
    FROM comments
    GROUP BY article_id, user_id
) AS comment_counts ON a.id = comment_counts.article_id
GROUP BY a.id
HAVING MAX(comment_counts.comment_count) IS NULL OR MAX(comment_counts.comment_count) <= 1;
