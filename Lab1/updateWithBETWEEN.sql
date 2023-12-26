USE Lab1;

--BETWEEN
UPDATE Review 
SET rating = rating + 1
WHERE rating BETWEEN 1 AND 4