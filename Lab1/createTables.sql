USE Lab1;

CREATE TABLE [User] (
    id INT PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    birth_date DATE,
	email VARCHAR(30)
);

CREATE TABLE Playlist (
	id INT PRIMARY KEY,
	[name] VARCHAR(20),
	[user_id] INT FOREIGN KEY REFERENCES [User](id)
);

CREATE TABLE Lable (
	id INT PRIMARY KEY,
	[name] VARCHAR(20),
	est_date DATE
);

CREATE TABLE Artist (
	id INT PRIMARY KEY,
	[name] VARCHAR(20),
	lable_id INT FOREIGN KEY REFERENCES Lable(id)
);

CREATE TABLE Genre (
	id INT PRIMARY KEY,
	[name] VARCHAR(20)
);

CREATE TABLE Album (
	id INT PRIMARY KEY,
	[name] VARCHAR(20),
	artist_id INT FOREIGN KEY REFERENCES Artist(id),
	genre_id INT FOREIGN KEY REFERENCES Genre(id),
	release_date DATE
);

CREATE TABLE Song (
	id INT PRIMARY KEY,
	[name] VARCHAR(20),
	album_id INT FOREIGN KEY REFERENCES Album(id),
	[length] INT  
);

CREATE TABLE song_playlist (
	song_id INT FOREIGN KEY REFERENCES Song(id),
	playlist_id INT FOREIGN KEY REFERENCES Playlist(id),
	PRIMARY KEY (song_id, playlist_id),
	addition_date DATE
);

CREATE TABLE Review (
	[user_id] INT FOREIGN KEY REFERENCES [User](id),
	song_id INT FOREIGN KEY REFERENCES Song(id),
	PRIMARY KEY ([user_id], song_id),
	rating INT,
	CONSTRAINT	CHK_rating CHECK (rating >= 1 AND rating <= 5)
);

CREATE TABLE Recommendation (
	from_user_id INT FOREIGN KEY REFERENCES [User](id),
	to_user_id INT FOREIGN KEY REFERENCES [User](id),
	song_id INT FOREIGN KEY REFERENCES Song(id),
	PRIMARY KEY (from_user_id, to_user_id, song_id),
	reason VARCHAR(200)
);