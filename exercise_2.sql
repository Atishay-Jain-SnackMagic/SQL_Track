CREATE DATABASE vtapp;
CREATE USER vtapp_user WITH PASSWORD 'testing';
ALTER DATABASE vtapp OWNER TO vtapp_user;

-- Another way
CREATE USER vtapp_user WITH PASSWORD 'testing';
CREATE DATABASE vtapp OWNER vtapp_user;
