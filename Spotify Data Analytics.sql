create database Spotify;
Use spotify;
SET SESSION sql_mode = '';
CREATE TABLE spotify (
    artist TEXT,
    track TEXT,
    album TEXT,
    album_type TEXT,
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title TEXT,
    channel TEXT,
    views BIGINT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on TEXT
);

TRUNCATE TABLE spotify;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/final_cleaned_2.csv'
INTO TABLE spotify
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from spotify;
-- SELECT artist, track, views
-- FROM spotify
-- ORDER BY views asc
-- LIMIT 10;

-- SELECT id, artist, track
-- FROM spotify
-- LIMIT 10;

ALTER TABLE spotify
DROP COLUMN id;

-- SET @num = 0;
-- UPDATE spotify
-- SET id = (@num := @num + 1);

SET @num = 0;
UPDATE spotify
SET id = (@num := @num + 1)
ORDER BY artist;

SELECT COUNT(id), COUNT(*)
FROM spotify;

SELECT ROW_NUMBER() OVER () AS id,artist,track FROM spotify;

-- EDA
select count(*) from spotify;
select count(distinct artist) from spotify;
select count(distinct album) from spotify;
select distinct album_type from spotify;
select max(duration_min) from spotify;
select min(duration_min) from spotify;
select * from spotify where duration_min = 0;

delete from spotify where duration_min = 0;

-- Q1. Retrieve the names of all tracks that have more than 1 billion streams.
 select * from spotify where stream > 1000000000;
 
 -- Q2. List all albums along with their respective artists.
 select album, artist from spotify;
 select distinct album, artist from spotify; 
 
-- Q3. Get the total number of comments for tracks where licensed = TRUE
select * from spotify where licensed = 'true';
select comments from spotify where licensed = 'true';

-- Q4. Find all tracks that belong to the album type single
select * from spotify where album_type = 'single';

-- Q5, Count the total number of tracks by each artist.
select artist, count(*) as total_no_songs from spotify group by artist;
select artist, count(*) as total_no_songs from spotify group by artist order by 2 desc;
select artist, count(*) as total_no_songs from spotify group by artist order by 2 asc;

-- Q6. Calculate the average danceability of tracks in each album
-- select danceability from spotify;
select album, avg(danceability) as avg_danceability from spotify group by 1 order by 2 desc;

-- Q7. Find the top 5 tracks with the highest energy values.
select distinct track from spotify;
select round((energy_liveness),2) as highest_energy_values, track from spotify order by highest_energy_values desc limit 5;

-- Q8. List all tracks along with their views and likes where official_video = TRUE
SELECT
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM spotify where official_video = 'true'
GROUP BY 1
order by 2 desc
limit 10;

-- Q9. For each album, calculate the total views of all associated tracks.
select album, track, 
	sum(views)
	from spotify
group by 1,2 order by 3 desc;

-- Q10. Retrieve the track names that have been streamed on Spotify more than YouTube.
select track, stream, views
from spotify
where stream > views
order by stream DESC;

-- Q11. Find the top 3 most-viewed tracks for each artist using window functions.
select 
    artist,
    track,
    views,
    rank_num
from (
    select 
        artist,
        track,
        views,
        rank() over (
            partition by artist
            order by views desc
        ) as rank_num
    from spotify
) ranked_tracks
where rank_num <= 3
order by artist, rank_num;

-- Q12. Write a query to find tracks where the liveness score is above the average.
select track, artist, liveness
from spotify
where liveness > (
    select avg(liveness)
    from spotify
);

-- Q13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
with energy_stats as (
    select 
        album,
        MAX(energy) AS highest_energy,
        MIN(energy) AS lowest_energy
    from spotify
    group by album
)
select 
    album,
    highest_energy,
    lowest_energy,
    highest_energy - lowest_energy AS energy_diff
from energy_stats
order by energy_diff desc;

-- Q14. Find tracks where the energy-to-liveness ratio is greater than 1.2
select 
    track,
    artist,
    energy,
    liveness,
    energy / NULLIF(liveness, 0) AS energy_liveness_ratio
from spotify
where energy / NULLIF(liveness, 0) > 1.2
order by energy_liveness_ratio asc;

-- Q15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
select 
    track,
    artist,
    views,
    likes,
    sum(likes) over (
        order by views desc
        rows between unbounded preceding and current row
    ) as cumulative_likes
from spotify
order by views desc;