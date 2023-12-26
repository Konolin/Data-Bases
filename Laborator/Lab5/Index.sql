exec sys.sp_helpindex @objname = N'Ta'
exec sys.sp_helpindex @objname = N'Tb'
exec sys.sp_helpindex @objname = N'Tc'

select * from sys.indexes where object_id = OBJECT_ID('Ta')
select * from sys.indexes where object_id = OBJECT_ID('Tb')
select * from sys.indexes where object_id = OBJECT_ID('Tc')

create unique nonclustered index A2Index on Ta(a2)

-- Ub 4 a)
select idA from Ta order by idA DESC
select * from Ta where idA >= 300
select a2 from Ta where a2 % 2 = 0
select a2 from Ta where a2 = 800

drop index Ta.A2Index



-- Ub 4 b)
select a3 from Ta where a2 = 300



-- Ub 4 c)
drop index Tb.B2Index
create nonclustered index B2Index on Tb(b2)
select * from Tb where b2 = 999



-- Ub 4 d)
select * 
from Ta
inner join Tc on Ta.idA = Tc.idA
where Ta.idA = 700

select * 
from Tb
inner join Tc on Tb.idB = Tc.idB
where Tb.idB = 700

create nonclustered index idAIndex on Tc(idA)
create nonclustered index idBIndex on Tc(idB)

drop index Tc.idAIndex 
drop index Tc.idBIndex