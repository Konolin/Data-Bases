exec initialize
exec rollbackInitialize

exec TableCreator 'T1', 'id INT PRIMARY KEY IDENTITY(1,1), [name] VARCHAR(30)'
exec AddColumn 'T1', 'rating', 'INT'
exec ChangeColumnType 'T1', 'name', 'CHAR(20)'
exec CreateDefaultConstraint 'T1', 'name', '''test'''
exec CreateDefaultConstraint 'T1', 'rating', '0'
exec TableCreator 'T2', 'id INT PRIMARY KEY'
exec AddColumn 'T2', 'T1_id', 'INT'
exec CreateForeighKeyConstraint 'T2', 'T1_id', 'T1', 'id'


select *
from VersionHistory

select *
from CurrentVersion

exec goToVersion 0
exec goToVersion 8
