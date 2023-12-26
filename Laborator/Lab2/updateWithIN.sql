USE Lab1;

UPDATE Review
SET rating = 5
WHERE song_id IN (3, 4)