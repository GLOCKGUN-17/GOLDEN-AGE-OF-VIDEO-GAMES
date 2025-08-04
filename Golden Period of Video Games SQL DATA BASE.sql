CREATE DATABASE video_games_db;
USE video_games_db;

CREATE TABLE video_games (
    name VARCHAR(255),
    platform VARCHAR(100),
    year_of_release INT,
    genre VARCHAR(100),
    publisher VARCHAR(50),
    global_sales FLOAT,
    critic_score FLOAT,
    user_score FLOAT,
    developer VARCHAR(50),
    rating VARCHAR(10)
    
);

SHOW VARIABLES LIKE 'secure_file_priv';

SELECT * FROM video_games LIMIT 5;

SELECT COUNT(*) AS total_rows FROM video_games;


CREATE TABLE top_games AS
SELECT * FROM video_games
ORDER BY sales DESC
LIMIT 368;

SELECT COUNT(*) AS total_rows FROM top_games;


SELECT 

    COUNT(*) AS total_rows,
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS missing_name,
	SUM(CASE WHEN platform IS NULL THEN 1 ELSE 0 END) AS missing_platform,
	SUM(CASE WHEN year_of_release IS NULL THEN 1 ELSE 0 END) AS missing_year,
    SUM(CASE WHEN genre IS NULL THEN 1 ELSE 0 END) AS missing_genre,
    SUM(CASE WHEN publisher IS NULL THEN 1 ELSE 0 END) AS missing_publisher,
    SUM(CASE WHEN global_sales IS NULL THEN 1 ELSE 0 END) AS missing_global_sales,
    SUM(CASE WHEN critic_score IS NULL THEN 1 ELSE 0 END) AS missing_critic,
    SUM(CASE WHEN user_score IS NULL THEN 1 ELSE 0 END) AS missing_user,
    SUM(CASE WHEN developer IS NULL THEN 1 ELSE 0 END) AS missing_developer,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_rating
       
    
FROM top_games;

   
   
UPDATE top_games
SET critic_score = (
    SELECT AVG(critic_score)
    FROM video_games
    WHERE critic_score IS NOT NULL
)
WHERE critic_score IS NULL;
UPDATE top_games
SET user_score = (
    SELECT AVG(user_score)
    FROM video_games
    WHERE user_score IS NOT NULL
)
WHERE user_score IS NULL;

SET SQL_SAFE_UPDATES = 0;



DELETE FROM top_games
WHERE critic_score IS NULL OR user_score IS NULL OR global_sales IS NULL OR year_of_release IS NULL;


SELECT COUNT(*) AS total_rows FROM top_games;


SELECT MAX(user_score) AS max_user_score, MIN(user_score) AS min_user_score
FROM top_games;


UPDATE top_games
SET user_score = user_score * 10
WHERE user_score <= 10;


SELECT name, year_of_release, COUNT(*) AS count
FROM top_games
GROUP BY name, year_of_release
HAVING count > 1;


CREATE TABLE cleaned_games AS
SELECT name, year_of_release, MAX(platform) AS platform, MAX(genre) AS genre, MAX(global_sales) AS global_sales, AVG (critic_score) AS critic_score, AVG (user_score) AS user_score, AVG (developer) AS developer , AVG (rating) AS rating 
FROM top_games
GROUP BY name, year_of_release ;



WITH sorted_global_sales AS (
    SELECT global_sales,
           ROW_NUMBER() OVER (ORDER BY global_sales) AS row_num,
           COUNT(*) OVER () AS total_rows
    FROM cleaned_games
)
SELECT global_sales
FROM sorted_global_sales
WHERE row_num = CEIL(total_rows * 0.75);

SELECT name, year_of_release , global_sales
FROM cleaned_games
ORDER BY global_sales DESC
LIMIT 10;


SELECT 
    year_of_release,
    ROUND(AVG(critic_score), 2) AS avg_critic_score,
    SUM(CASE WHEN critic_score >= 80 THEN 1 ELSE 0 END) AS hit_games
FROM cleaned_games
GROUP BY year_of_release
HAVING COUNT(*) > 0
ORDER BY avg_critic_score DESC
LIMIT 10;



SELECT 
    year_of_release,
    ROUND(AVG(user_score), 2) AS avg_user_score,
    SUM(CASE WHEN user_score >= 80 THEN 1 ELSE 0 END) AS hit_games
FROM cleaned_games
GROUP BY year_of_release
HAVING COUNT(*) > 0
ORDER BY avg_user_score DESC
LIMIT 10;


SELECT 
    year_of_release,
    ROUND(AVG((critic_score + user_score) / 2), 2) AS avg_combined_score,
    SUM(CASE WHEN critic_score >= 80 OR user_score >= 80 THEN 1 ELSE 0 END) AS hit_games
FROM cleaned_games
GROUP BY year_of_release
HAVING COUNT(*) > 0
ORDER BY avg_combined_score DESC
LIMIT 10;


SELECT 
    year_of_release,
    ROUND(SUM(global_sales), 2) AS total_sales,
    COUNT(*) AS game_count
FROM cleaned_games
WHERE year_of_release IN (
    SELECT year_of_release FROM (
        SELECT year_of_release
        FROM cleaned_games
        GROUP BY year_of_release
        ORDER BY AVG(critic_score) DESC
        LIMIT 10
    ) AS t1
    UNION
    SELECT year_of_release FROM (
        SELECT year_of_release
        FROM cleaned_games
        GROUP BY year_of_release
        ORDER BY AVG(user_score) DESC
        LIMIT 10
    ) AS t2
    UNION
    SELECT year_of_release FROM (
        SELECT year_of_release
        FROM cleaned_games
        GROUP BY year_of_release
        ORDER BY AVG((critic_score + user_score) / 2) DESC
        LIMIT 10
    ) AS t3
)
GROUP BY year_of_release
ORDER BY total_sales DESC;


SELECT name, year_of_release , global_sales, critic_score, user_score
FROM cleaned_games
WHERE global_sales > 50 OR critic_score > 100 OR user_score > 100;



SELECT 
    platform,
    ROUND(AVG(critic_score), 2) AS avg_critic_score,
    ROUND(AVG(user_score), 2) AS avg_user_score,
    SUM(global_sales) AS total_sales,
    COUNT(CASE WHEN critic_score >= 80 OR user_score >= 80 THEN 1 ELSE 0 END) AS hit_games
FROM cleaned_games
GROUP BY platform
ORDER BY total_sales DESC
LIMIT 10;



SELECT 
    genre,
    ROUND(AVG(critic_score), 2) AS avg_critic_score,
    ROUND(AVG(user_score), 2) AS avg_user_score,
    SUM(global_sales) AS total_sales
FROM cleaned_games
GROUP BY genre
ORDER BY total_sales DESC
LIMIT 10;



SELECT 
    FLOOR(year_of_release / 10) * 10 AS decade,
    ROUND(AVG(critic_score), 2) AS avg_critic_score,
    ROUND(AVG(user_score), 2) AS avg_user_score,
    SUM(global_sales) AS total_sales
FROM cleaned_games
GROUP BY decade
ORDER BY decade;


SELECT 
    name,
    platform,
    genre,
    ROUND(global_sales, 2) AS global_sales
FROM cleaned_games
ORDER BY global_sales DESC
LIMIT 300;