USE Lab1;



--1.
SELECT S.[name] AS song_name, A.[name] AS album_name, AR.[name] AS artist_name, R.rating
FROM Song S
JOIN Album A ON S.album_id = A.id
JOIN Artist AR ON A.artist_id = AR.id
JOIN Genre G ON A.genre_id = G.id
JOIN Review R ON S.id = R.song_id
WHERE G.[name] = 'HIP-HOP' AND R.rating >= ALL (
	SELECT R.rating
	FROM Song S
	JOIN Album A ON S.album_id = A.id
	JOIN Review R ON S.id = R.song_id
);



--2.
SELECT pl.id AS playlist_id, pl.[name] AS playlist_name, SUM(s.[length]) AS playlist_length
FROM Playlist pl
JOIN song_playlist sp ON pl.id = sp.playlist_id
JOIN Song s ON sp.song_id = s.id
GROUP BY pl.id, pl.[name]
ORDER BY playlist_length DESC;



--3.
SELECT COUNT(DISTINCT u.id) AS num_users  
FROM [User] u
JOIN Playlist p ON u.id = p.user_id
JOIN song_playlist sp ON p.id = sp.playlist_id
JOIN Song s ON sp.song_id = s.id
JOIN Album a ON s.album_id = a.id
WHERE a.release_date < u.birth_date;



--4.
SELECT TOP 3 p.id, p.[name], AVG(r.rating) as avg_rating
FROM Playlist p
JOIN song_playlist sp ON p.id = sp.playlist_id
JOIN Song s ON sp.song_id = s.id
JOIN Review r ON s.id = r.song_id
GROUP BY p.id, p.[name]
HAVING COUNT(sp.song_id) > 3
ORDER BY avg_rating DESC;



--5.
SELECT p.id AS playlist_id, CONCAT(u.first_name, ' ', u.last_name) AS user_name
FROM Playlist p
JOIN [User] u ON p.user_id = u.id
EXCEPT
SELECT p.id AS playlist_id, CONCAT(u.first_name, ' ', u.last_name) AS user_name
FROM Playlist p
JOIN [User] u ON p.user_id = u.id
JOIN song_playlist sp ON p.id = sp.playlist_id
JOIN Song s ON sp.song_id = s.id
JOIN Album a ON s.album_id = a.id
JOIN Genre g ON a.genre_id = g.id
WHERE g.[name] != 'HIP-HOP';



--6.
SELECT S.[name] --si id
FROM SONG S
JOIN song_playlist sp ON S.id = sp.song_id
JOIN Playlist p ON sp.playlist_id = p.id
JOIN Review r ON S.id = r.song_id
WHERE r.user_id = p.user_id
INTERSECT
SELECT S.[name]
FROM SONG S
WHERE S.id NOT IN (
    SELECT DISTINCT r.song_id
    FROM Review r
    JOIN song_playlist sp ON r.song_id = sp.song_id
    JOIN Playlist p ON sp.playlist_id = p.id
    WHERE r.user_id <> p.user_id
);



--7.
SELECT s.[name]
FROM Song s
JOIN Album a ON s.album_id = a.id
JOIN Genre g ON a.genre_id = g.id
WHERE g.[name] = 'POP'
AND s.id IN (
	SELECT s.id
	FROM Song s
	JOIN Review r ON s.id = r.song_id
	WHERE r.rating = 5
);



--8.
SELECT DISTINCT a.[name] AS ArtistName
FROM Artist a
JOIN Album al ON a.id = al.artist_id
JOIN Song s ON al.id = s.album_id
JOIN Review r ON s.id = r.song_id
WHERE r.rating = 5
UNION
SELECT DISTINCT a.[name] AS ArtistName
FROM Artist a
JOIN Album al ON a.id = al.artist_id
JOIN Song s ON al.id = s.album_id
JOIN Recommendation rec ON s.id = rec.song_id



--9.
SELECT DISTINCT u1.first_name AS Recommender, s.[name] AS SongName
FROM Recommendation rec1
JOIN [User] u1 ON rec1.from_user_id = u1.id
JOIN Song s ON rec1.song_id = s.id
WHERE rec1.song_id = ANY (
	SELECT rec2.song_id
	FROM Recommendation rec2
	WHERE rec2.from_user_id = rec1.from_user_id
	GROUP BY rec2.song_id
	HAVING COUNT(DISTINCT rec2.to_user_id) > 1
);




--10.
SELECT DISTINCT s.[name] AS song_name
FROM Song s
LEFT JOIN Review r ON s.id = r.song_id
JOIN Recommendation rec ON s.id = rec.song_id
WHERE r.song_id IS NULL
OR rec.from_user_id = rec.to_user_id
OR rec.reason IS NULL;


--11.
SELECT a.[name]
FROM Album a
JOIN Song s ON s.album_id = a.id
GROUP BY a.id
HAVING COUNT(s.id) >= 4 OR SUM(s.[length]) > (
	SELECT AVG(album_lengths) as average_length
	FROM (
		SELECT SUM(s.[length]) as album_lengths
		FROM Album a1
		JOIN Song s ON a1.id = s.album_id
		GROUP BY a1.id
	) as temp
);

