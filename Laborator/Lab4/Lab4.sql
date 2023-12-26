-- UB 1

create or alter procedure InsertDataBooks(
	@tile varchar(100),
	@authorId int,
	@price int)
as
	begin
		if dbo.ValidateTitle(@tile) = 0
			begin
				print 'Validation error: @tile has an invalid value'
				return
			end
		if dbo.ValidateAuthor(@authorId) = 0
			begin
				print 'Validation error: @authorId has an invalid value'
				return
			end
		if dbo.ValidatePrice(@price) = 0
			begin
				print 'Validation error: @price has an invalid value'
				return
			end

		insert into Books (title, authorID, price)
		values (@tile, @authorID, @price)

		print 'Data successfully inserted'
	end
go

create or alter function ValidateTitle(@tile varchar(100))
returns bit
as
	begin
		declare @result as bit
		if @tile = ''
			set @result = 0
		else 
			set @result = 1
		return @result
	end
go

create or alter function ValidatePrice(@price int)
returns bit
as
	begin
		declare @result as bit
		if @price <= 0
			set @result = 0
		else 
			set @result = 1
		return @result
	end
go

create or alter function ValidateAuthor(@authorID int)
returns bit
as
	begin
		declare @result as bit
		if exists (select 1 from Authors where AuthorID = @authorId)
			set @result = 1
		else 
			set @result = 0
		return @result
	end
go

select *
from Books

select * 
from authors

print dbo.ValidatePrice(-11)
print dbo.validateTitle('')
print dbo.validateAuthor(1)
exec InsertDataBooks 'hhhhhhh', 1003, 3


--UB 2-------------------------------------------------------------------------------------------------------------------------------------------



CREATE OR ALTER FUNCTION GetOrderDetailsForCustomer (@customerID INT)
RETURNS TABLE
AS
RETURN (
    SELECT
		Books.BookID,
        OrderDetails.Quantity,
        Books.Price * OrderDetails.Quantity AS TotalPrice
    FROM
        OrderDetails
    JOIN Books ON OrderDetails.BookID = Books.BookID
    JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
    WHERE
        Orders.CustomerID = @customerID
);
GO



CREATE OR ALTER VIEW BookAuthorView AS
SELECT
    Books.BookID,
    Books.Title,
    Authors.AuthorName,
    Books.Price
FROM
    Books
JOIN Authors ON Books.AuthorID = Authors.AuthorID;
GO



DECLARE @CustomerID INT = 1;
SELECT TOP 1
    bav.AuthorName,
	bav.Title,
	bav.Price
FROM
    BookAuthorView as bav
JOIN GetOrderDetailsForCustomer(@CustomerID) godfc ON bav.BookID = godfc.BookID
ORDER BY
	godfc.TotalPrice DESC
go


--UB 3------------------------------------------------------------------------------------------------------
create table LogTable (
	ID int primary key identity(1, 1),
	ExecDateTime datetime,
	StatementType varchar(1),
	TableName varchar(100),
	AffectedTupleCount int
)
go

alter trigger On_Book_Insert
	on Books
	after insert
as
begin
	set nocount on

	declare @AffectedTupleCount as int
	select @AffectedTupleCount = count(*) from inserted

	insert into LogTable (ExecDateTime, StatementType, TableName, AffectedTupleCount)
	select GETDATE(), 'I', 'Books', @AffectedTupleCount
end
go

create trigger On_Book_Delete
	on Books
	after delete
as
begin
	set nocount on

	declare @AffectedTupleCount as int
	select @AffectedTupleCount = count(*) from deleted

	insert into LogTable (ExecDateTime, StatementType, TableName, AffectedTupleCount)
	select GETDATE(), 'D', 'Books', @AffectedTupleCount
end
go

create trigger On_Book_Update
	on Books
	after update
as
begin
	set nocount on

	declare @AffectedTupleCount as int
	select @AffectedTupleCount = COUNT(*) 
		from deleted d
		join inserted i on d.BookID = i.BookID
		where 
			d.AuthorID != i.AuthorID or 
			d.Price != i.Price or 
			d.Title != i.Title

	insert into LogTable (ExecDateTime, StatementType, TableName, AffectedTupleCount)
	select GETDATE(), 'U', 'Books', @AffectedTupleCount
end
go

select * from Books
select * from LogTable

insert into Books (Title, AuthorID, Price)
values ('test', 1, 10),
	   ('test2', 2, 11)

delete from Books
where BookID = 28 or BookID = 27

update Books
set Price = 99
where BookID > 10

drop table LogTable
go

--UB 4-----------------------------------------------------------------------------------------------------------------------------
create or alter procedure UpdatePrice (
	@BookID int,
	@Quantity int)
as
begin
	if @Quantity > 10
		begin
			update Books
			set Price = Price + 1
			where @BookID = BookID
		end
	else 
		begin
			update Books
			set Price = Price - 1
			where @BookID = BookID
		end
end
go

select * from Books

declare Book_Cursor cursor for
	select b.BookID, o.Quantity
	from Books b
	join OrderDetails o on b.BookID = o.BookID

declare @BookID as int
declare @Quantity as int

open Book_Cursor

fetch Book_Cursor into @BookID, @Quantity
while @@FETCH_STATUS = 0
	begin
		exec UpdatePrice @BookID, @Quantity
		fetch Book_Cursor into @BookID, @Quantity
	end

close Book_Cursor
deallocate Book_Cursor

go

select * from Books