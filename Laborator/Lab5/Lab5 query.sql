-- Init tables ----------------------------------------------------------------------------------------------------------
create table Ta (
	idA int primary key identity(1, 1),
	a2 int,
	a3 int
)

create table Tb (
	idB int primary key identity(1, 1),
	b2 int,
	b3 int
)

create table Tc (
	idC int primary key identity(1, 1),
	idA int references Ta(idA),
	idB int references Tb(idB)
)

drop table Tc
drop table Tb
drop table Ta


-- Add data -----------------------------------------------------------------------------------------------------
create or alter procedure InsertData as
begin
	declare @Nr_tuples as int
	declare @Rand_value1 as int
	declare @Rand_value2 as int
	declare @Rand_value3 as int

	set @Nr_tuples = 1
	while @Nr_tuples <= 10000
		begin
			set @Rand_value1 = cast(rand() * 10000 as int) 
			set @Rand_value2 = cast(rand() * 10000 as int) 

			if not exists (select 1 from Ta where a2 = @Rand_value1)
				begin
					insert into Ta (a2, a3)
					values (@Rand_value1, @Rand_value2)

					set @Nr_tuples = @Nr_tuples + 1
				end
		end

	set @Nr_tuples = 1
	while @Nr_tuples <= 3000
		begin
			set @Rand_value1 = cast(rand() * 10000 as int)
			set @Rand_value2 = cast(rand() * 10000 as int)
			insert into Tb (b2, b3)
			values (@Rand_value1, @Rand_value2)
			set @Nr_tuples = @Nr_tuples + 1
		end

	set @Nr_tuples = 1
	while @Nr_tuples <= 10000
		begin
			set @Rand_value1 = cast(rand() * 3000 as int) + 1
			set @Rand_value2 = cast(rand() * 3000 as int) + 1 
			set @Rand_value3 = cast(rand() * 3000 as int) + 1

			if @Rand_value1 != @Rand_value2  and @Rand_value1 != @Rand_value3 and @Rand_value2 != @Rand_value3
				begin
					insert into Tc (idA, idB)
					values (@Nr_tuples, @Rand_value1),
							(@Nr_tuples, @Rand_value2),
							(@Nr_tuples, @Rand_value3)
					set @Nr_tuples = @Nr_tuples + 1
				end
		end
end
go

select a2, count(*) as nr_duplicates
from Ta
group by a2
having count(*) > 1;
go

exec InsertData

select * from Ta
select * from Tb
select * from Tc

select count(*) as x
from Ta
select count(*) as x
from Tb
select count(*) as x
from Tc