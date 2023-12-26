USE Lab6;

-- create base database
CREATE TABLE Student (
	id INT PRIMARY KEY,
	[name] VARCHAR(30),
	birthdate DATE
);

CREATE TABLE Course (
	id INT PRIMARY KEY,
	[name] VARCHAR(20),
	credits INT
);

CREATE TABLE Enrolled (
	student_id INT FOREIGN KEY REFERENCES Student(id),
	course_id INT FOREIGN KEY REFERENCES Course(id),
	PRIMARY KEY (student_id, course_id),
	grade INT
);

-- Insert data into database
INSERT INTO Student (id, [name], birthdate)
VALUES 
  (1, 'John Doe', '2000-01-15'),
  (2, 'Jane Smith', '1999-08-22'),
  (3, 'Bob Johnson', '2001-03-10');

INSERT INTO Course (id, [name], credits)
VALUES 
  (101, 'Math 101', 3),
  (102, 'History 101', 4),
  (103, 'Science 101', 3);

INSERT INTO Enrolled (student_id, course_id, grade)
VALUES 
  (1, 101, 85),
  (1, 102, 75),
  (2, 101, 90),
  (2, 103, 88),
  (3, 102, 70);