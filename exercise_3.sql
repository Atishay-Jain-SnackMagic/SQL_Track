CREATE TYPE usertype AS ENUM('admin', 'normal');

CREATE TABLE categories(
	id SERIAL PRIMARY KEY,
	name varchar(30) NOT NULL
);

CREATE TABLE users(
	id SERIAL PRIMARY KEY,
	name varchar(30) NOT NULL,
	type usertype DEFAULT 'normal' NOT NULL
);

CREATE TABLE articles(
	id SERIAL PRIMARY KEY,
	title varchar(60) NOT NULL,
	content TEXT,
	category_id INT NOT NULL REFERENCES categories(id),
	author_id INT NOT NULL REFERENCES users(id)
);

CREATE TABLE comments(
	id SERIAL PRIMARY KEY,
	article_id INT NOT NULL REFERENCES articles(id),
	user_id INT NOT NULL REFERENCES users(id),
	comment TEXT
);

-- Insert into categories
INSERT INTO categories (name) VALUES 
	('Technology'),
	('Health'),
	('Education'),
	('Sports'),
	('Science'),
	('Entertainment');

-- Insert into users
INSERT INTO users (name, type) VALUES 
	('Alice', 'admin'),
	('Bob', 'normal'),
	('user3', 'admin'),
	('David', 'admin'),
	('Emma', 'admin'),
	('Frank', 'normal'),
	('Grace', 'normal'),
	('Hannah', 'admin'),
	('Isaac', 'normal');

-- Insert into articles
INSERT INTO articles (title, content, category_id, author_id) VALUES  
    ('AI Revolution', 'Exploring the impact of AI on various industries.', 1, 1),
    ('Healthy Eating', 'A guide to maintaining a balanced and nutritious diet.', 2, 2),
    ('Learning PostgreSQL', 'Essential tips and best practices for mastering PostgreSQL.', 3, 3),
    ('The Future of Quantum Computing', 'Advancements and potential of quantum technology.', 5, 4),
    ('Olympics 2024 Highlights', 'Key moments and performances from the latest Olympics.', 4, 5),
    ('Space Exploration Updates', 'Recent discoveries and missions in space science.', 5, 6),
    ('Blockchain and Its Applications', 'How blockchain is revolutionizing industries.', 1, 7),
    ('Movie Industry Trends in 2025', 'Upcoming changes and innovations in filmmaking.', 6, 8),
    ('Nutrition for Athletes', 'The best diet strategies for peak athletic performance.', 2, 9);

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
	(3, 1, 'PostgreSQL is very very powerful for databases.');
	

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
FROM articles a, (
	SELECT comment, article_id FROM comments
	) AS temp
WHERE a.id = temp.article_id AND author_id IN (
	SELECT id FROM users WHERE name = 'user3'
	);

-- select all the articles and also the comments associated with those articles in a single query (using nested subquery)
SELECT title, comment
FROM articles a, comments
WHERE a.id = comments.article_id AND author_id IN (
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

-- select article which has maximum comments
SELECT title
FROM articles a
INNER JOIN comments ON a.id = comments.article_id
GROUP BY a.id
HAVING COUNT(*) = (
	SELECT COUNT(*)
	FROM comments
	GROUP BY article_id
	ORDER BY COUNT(*) DESC
	LIMIT 1
);

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
