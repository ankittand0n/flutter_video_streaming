-- Fix genre_ids to use consistent JSON array format
-- Run this AFTER the migrate-movies.sql

-- Update all genre_ids to proper JSON array format
UPDATE movies SET genre_ids = '[22,16,12]' WHERE id = 1;  -- Antervyathaa: Thriller, Horror, Drama
UPDATE movies SET genre_ids = '[22,16,12]' WHERE id = 2;  -- Firauti: Thriller, Horror, Drama
UPDATE movies SET genre_ids = '[22,16,12]' WHERE id = 3;  -- Pahal Kaun Karega: Thriller, Horror, Drama
UPDATE movies SET genre_ids = '[22,16,12]' WHERE id = 4;  -- Katputali: Thriller, Horror, Drama
UPDATE movies SET genre_ids = '[19,12]' WHERE id = 5;     -- Love Story 1998: Romance, Drama
UPDATE movies SET genre_ids = '[22,12]' WHERE id = 6;     -- Jaala: Thriller, Drama
UPDATE movies SET genre_ids = '[12,22]' WHERE id = 7;     -- Jagamemaya: Drama, Thriller
UPDATE movies SET genre_ids = '[16,22]' WHERE id = 8;     -- Skull: The Mask: Horror, Thriller
UPDATE movies SET genre_ids = '[16]' WHERE id = 9;        -- Barbarous Mexico: Horror
UPDATE movies SET genre_ids = '[9,16]' WHERE id = 10;     -- Ghost Killers: Comedy, Horror
UPDATE movies SET genre_ids = '[16]' WHERE id = 11;       -- The Barge People: Horror
UPDATE movies SET genre_ids = '[6,12]' WHERE id = 12;     -- Bangkok Hell: Action, Drama
UPDATE movies SET genre_ids = '[22,12]' WHERE id = 13;    -- Antervyathaa (old): Thriller, Drama

-- Verify the changes
SELECT id, title, genre_ids FROM movies ORDER BY id;

-- Show genre mapping reference
SELECT 
    id,
    title,
    genre_ids,
    CASE 
        WHEN genre_ids LIKE '%6%' THEN 'Action'
        WHEN genre_ids LIKE '%9%' THEN 'Comedy'
        WHEN genre_ids LIKE '%12%' THEN 'Drama'
        WHEN genre_ids LIKE '%16%' THEN 'Horror'
        WHEN genre_ids LIKE '%19%' THEN 'Romance'
        WHEN genre_ids LIKE '%22%' THEN 'Thriller'
        ELSE 'Mixed'
    END as primary_genre
FROM movies 
ORDER BY id;
