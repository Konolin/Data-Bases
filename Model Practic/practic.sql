create database practic

use practic

-- Ex. 1 --------------------------------------------------------------------------------------------------------
create table TrainType(
	TrainTypeID int primary key,
	[Description] varchar(50)
)

create table Train(
	TrainID int primary key,
	[Name] varchar(50),
	TrainTypeID int foreign key references TrainType(TrainTypeID)
)

create table TrainStation(
	TrainStationID int primary key,
	[Name] varchar(50)
)

create table TrainRoute(
	TrainRouteID int primary key,
	[Name] varchar(50),
	TrainID int foreign key references Train(TrainID)
)

create table RouteStop(
	ArrivalTime time,
	DepartureTime time,
	RouteID int foreign key references TrainRoute(TrainRouteID),
	TrainStationID int foreign key references TrainStation(TrainStationID)
	primary key (RouteID, TrainStationID)
)

insert into TrainType(TrainTypeID, [Description])
values  (1, 'Electric'),
		(2, 'Gas'),
		(3, 'Hybrid')

insert into Train(TrainID, [Name], TrainTypeID)
values  (1, 'Bob', 1),
		(2, 'Dob', 2),
		(3, 'Lob', 3),
		(4, 'Zob', 1)

insert into TrainStation(TrainStationID, [Name])
values  (1, 'Cluj'),
		(2, 'Danes'),
		(3, 'Sighisoara'),
		(4, 'Hetiur')

insert into TrainRoute(TrainRouteID, [Name], TrainID)
values  (1, 'Ruta 1', 1),
		(2, 'Regional N', 2),
		(3, 'Ruta 3', 4)

insert into RouteStop(ArrivalTime, DepartureTime, RouteID, TrainStationID)
values  ('12:10:00', '12:15:00', 1, 1),
		('12:40:00', '12:45:00', 1, 3),
		('13:10:00', '13:13:00', 1, 2),
		('15:10:00', '15:13:00', 1, 4),
		('8:10:00', '8:15:00', 2, 3),
		('15:10:00', '15:15:00', 2, 4),
		('12:30:00', '12:45:00', 3, 3),
		('15:10:00', '15:25:00', 3, 4)

-- Ex 2. -----------------------------------------------------------------------------------------------------
create or alter procedure EditRoute(
	@RouteID int,
	@TrainStationID int,
	@ArrivalTime time,
	@DepartureTime time
) as
begin
	if exists (select * from RouteStop rs where rs.RouteID = @RouteID and rs.TrainStationID = @TrainStationID)
		begin
			update RouteStop
			set ArrivalTime = @ArrivalTime,
				DepartureTime = @DepartureTime
			where RouteID = @RouteID and TrainStationID = @TrainStationID
		end
	else
		begin
			insert into RouteStop(ArrivalTime, DepartureTime, RouteID, TrainStationID)
			values  (@ArrivalTime, @DepartureTime, @RouteID, @TrainStationID)
		end
end
go

select * from RouteStop
-- edit existing stop
exec EditRoute 1, 2, '14:00:00', '14:04:00'
-- add new stop
exec EditRoute 2, 1, '17:00:00', '17:04:00'
go

-- Ex 3. -----------------------------------------------------------------------------------------------------
create or alter function MultipleTrainsAtATime(@Time time)
returns table as
return(
	select ts.TrainStationID, ts.[Name]
	from RouteStop rs
	inner join TrainStation ts on ts.TrainStationID = rs.TrainStationID
	where @Time between rs.ArrivalTime and rs.DepartureTime
	group by ts.TrainStationID, ts.[Name]
	having count(*) > 1
)
go

select * from RouteStop
-- has 2+ trains at a time
select * from MultipleTrainsAtATime('15:10:00')
-- does not have 2+ trains at a time
select * from MultipleTrainsAtATime('17:00:00')
go

-- Ex 4. ------------------------------------------------------------------------------------------------------
create or alter view [Routes] as
select r.TrainRouteID, r.[Name], count(rs.TrainStationID) as StopsCount
from TrainRoute r
inner join RouteStop rs on rs.RouteID = r.TrainRouteID
group by r.TrainRouteID, r.[Name]
having count(rs.TrainStationID) <= 5
go

select top 1 with ties *
from [Routes]
order by StopsCount asc
go

-- Ex 5. ------------------------------------------------------------------------------------------------------
select * from RouteStop
select * from TrainStation

select tr.[Name]
from TrainRoute tr
inner join RouteStop rs on rs.RouteID = tr.TrainRouteID
group by tr.[Name], tr.TrainRouteID
having count(distinct rs.TrainStationID) = (
	select count(*)
	from TrainStation
)

-- Ex 7. ------------------------------------------------------------------------------------------------------
alter trigger BeforeInsertRouteStop
on RouteStop
after insert
as
begin
    if exists (
        select 1
        from inserted
        where ArrivalTime between '03:00:00' and '05:00:00'
           or DepartureTime between '03:00:00' and '05:00:00'
    )
    begin
		RAISERROR ('Illegal times', 16, 1)
        rollback
    end
end

insert into RouteStop (ArrivalTime, DepartureTime, RouteID, TrainStationID)
values ('3:00:00', '4:00:00', 3, 1)

select * from RouteStop

delete from RouteStop
where RouteID = 3 and TrainStationID = 1