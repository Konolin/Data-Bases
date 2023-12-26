CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY IDENTITY(1, 1),
    AuthorName VARCHAR(100)
);

CREATE TABLE Books (
    BookID INT PRIMARY KEY IDENTITY(1, 1),
    Title VARCHAR(100),
    AuthorID INT FOREIGN KEY REFERENCES Authors(AuthorID),
    Price INT
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1, 1),
    CustomerName VARCHAR(100),
    Email VARCHAR(100)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1, 1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATE
);

CREATE TABLE OrderDetails (
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    BookID INT FOREIGN KEY REFERENCES Books(BookID),
    Quantity INT,
    PRIMARY KEY (OrderID, BookID)
);
