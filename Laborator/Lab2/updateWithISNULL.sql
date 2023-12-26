USE Lab1;

--IS [NOT] NULL
DELETE FROM Recommendation
WHERE reason IS NULL OR from_user_id = to_user_id