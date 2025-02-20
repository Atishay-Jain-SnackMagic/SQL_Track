-- DROP TABLE IF EXISTS users, friends, images, tags;
CREATE TABLE users(
	id INT PRIMARY KEY,
	name TEXT
);

CREATE TABLE friends(
	user_id INT REFERENCES users(id),
	friend INT REFERENCES users(id),
	PRIMARY KEY(user_id, friend)
);

CREATE TABLE images(
	id INT PRIMARY KEY,
	image_user INT REFERENCES users(id)
);

CREATE TABLE tags(
	image_id INT REFERENCES images(id),
	tagged INT REFERENCES users(id),
	PRIMARY KEY(image_id, tagged)
);

INSERT INTO users(id, name) VALUES
	(1, 'userA'),
	(2, 'Bob'),
	(3, 'Charlie'),
	(4, 'David'),
	(5, 'Eve');

INSERT INTO friends(user_id, friend) VALUES
	(1, 2),
	(1, 3),
	(2, 1),
	(2, 4),
	(3, 1),
	(4, 2),
	(5, 3);

INSERT INTO images(id, image_user) VALUES
	(1, 1),
	(2, 2),
	(3, 3),
	(4, 4),
	(5, 5),
	(6, 5);

INSERT INTO tags(image_id, tagged) VALUES
	(1, 2),
	(1, 3),
	(2, 4),
	(3, 5),
	(4, 2),
	(5, 1),
	(2, 1),
	(3, 1),
	(6, 1);

CREATE INDEX idx_users_name ON users(name);
CREATE INDEX idx_friends_user_id ON friends(user_id);
CREATE INDEX idx_images_image_user ON images(image_user);
CREATE INDEX idx_tags_image_id ON tags(image_id);


-- Find image that has been tagged most no of times.
SELECT image_id
FROM tags
GROUP BY image_id
HAVING COUNT(*) = (
	SELECT COUNT(*)
	FROM tags
	GROUP BY image_id
	ORDER BY COUNT(*) DESC
	LIMIT 1
);

-- Find image that has been tagged most no of times. (2ND APPROACH)
SELECT image_id
FROM (
	SELECT image_id, RANK() OVER (ORDER BY COUNT(*) DESC) as rnk
	FROM tags
	GROUP BY image_id
)
WHERE rnk = 1;


-- Find all images belonging to the friends of a particular user
SELECT i.id
FROM images i
INNER JOIN friends f ON f.friend = i.image_user
WHERE f.user_id = 1;

-- Find all images belonging to the friends of a particular user (using subquery)
SELECT id
FROM images
WHERE image_user in (
	SELECT friend
	FROM friends
	WHERE user_id = 1
);

-- Find all friends of a particular user (Say, userA) who has tagged him in all of his pics
SELECT f.friend
FROM friends f
INNER JOIN users u ON u.id = f.user_id
INNER JOIN images i ON f.friend = i.image_user
LEFT JOIN tags t ON t.image_id = i.id AND tagged = f.user_id
WHERE u.name= 'userA'
GROUP BY f.friend
HAVING COUNT(i.id) = COUNT(tagged);

-- Find all friends of a particular user (Say, userA) who has tagged him in all of his pics (using subquery)
SELECT f.friend
FROM friends f
WHERE user_id = (
		SELECT id
		FROM users
		WHERE name = 'userA'
	)
	AND 
	friend IN (
		SELECT image_user
		FROM images i2
		WHERE i2.image_user = f.friend AND EXISTS (
			SELECT 1
			FROM tags
			WHERE image_id = i2.id AND tagged = f.user_id
	)
);

-- Find friend of a particular user (Say, userA) who have tagged him most no. of times.
SELECT friend
FROM 
(
    SELECT f.friend,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk,
           COUNT(*) AS cnt
    FROM friends f
    INNER JOIN users u ON u.id = f.user_id
    INNER JOIN images i ON f.friend = i.image_user
    INNER JOIN tags t ON t.image_id = i.id AND t.tagged = u.id
    WHERE u.name = 'userA'
    GROUP BY f.friend
) AS ranked_friends
WHERE rnk = 1;
