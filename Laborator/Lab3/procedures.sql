-- a)
create or alter procedure ChangeColumnType (
	@tableName varchar(50),
	@columnName varchar(50),
	@newType varchar(50),
	@newVersion int = 1)
as
	begin
		declare @oldColumnType as varchar(50)
		set @oldColumnType = (
			select T.DATA_TYPE 
			from INFORMATION_SCHEMA.COLUMNS T
			where TABLE_NAME = @tableName and COLUMN_NAME = @columnName
		)

		declare @length as varchar(50)
		set @length = (
			select T.CHARACTER_MAXIMUM_LENGTH
			from INFORMATION_SCHEMA.COLUMNS T
			where TABLE_NAME = @tableName and COLUMN_NAME = @columnName
		)

		if @length is not null
		set @oldColumnType = @oldColumnType + '(' + @length + ')'

		declare @query as varchar(max)
		set @query = 
			'alter table ' + @tableName +
			' alter column ' + @columnName + ' ' + @newType 
		exec(@query)

		if @newVersion = 1
			begin
				insert into VersionHistory (procedureName, tableName, columnName, columnType, oldColumnType)
				values ('changeColumnType', @tableName, @columnName, @newType, @oldColumnType)
		
				update CurrentVersion
				set currentVersion = (select max(versionId) from VersionHistory)
			end
	end
go

create or alter procedure RollbackChangeColumnType (
	@tableName varchar(50),
	@columnName varchar(50),
	@columnType varchar(50))
as
	begin
		declare @query as varchar(max)
		set @query = 
			'alter table ' + @tableName +
			' alter column ' + @columnName + ' ' + @columnType 
		exec(@query)
	end
go



-- b)
create or alter procedure CreateDefaultConstraint (
	@tableName varchar(50),
	@columnName varchar(50),
	@defaultConstraint varchar(max),
	@newVersion int = 1)
as
	begin
		declare @query as varchar(max)
		set @query = 
			'alter table ' + @tableName +
			' add constraint DF_' + @tableName + '_' + @columnName +
			' default ' + @defaultConstraint + 
			' for ' + @columnName
		exec(@query)

		if @newVersion = 1
			begin
				insert into VersionHistory (procedureName, tableName, columnName, defaultConstraint)
				values ('createDefaultConstraint', @tableName, @columnName, @defaultConstraint)

				update CurrentVersion
				set currentVersion = (select max(versionId) from VersionHistory)
			end
	end
go

create or alter procedure RollbackCreateDefaultConstraint (
	@tableName varchar(50),
	@columnName varchar(50))
as
	begin
		declare @query as varchar(max)
		set @query = 
			'alter table ' + @tableName + 
			' drop constraint DF_' + @tableName + '_' + @columnName
		exec(@query)
	end
go



-- c)
create or alter procedure TableCreator (
	@tableName varchar(50),
	@columnDefinition varchar(max),
	@newVersion int = 1)
as
	begin
		declare @query as varchar(max);
		set @query = 
			'create table ' + @tableName + '('
				+ @columnDefinition +
			');';
		exec(@query);

		if @newVersion = 1
			begin
				insert into VersionHistory (procedureName, tableName, columnDefinition)
				values ('tableCreator', @tableName, @columnDefinition)

				update CurrentVersion
				set currentVersion = (select max(versionId) from VersionHistory)
			end
	end
go


create or alter procedure RollbackTableCreator (
	@tableName varchar(50))
as
	begin
		declare @query as varchar(100)
		set @query = 'drop table ' + @tableName
		exec(@query)
	end
go



-- d)
create or alter procedure AddColumn (
	@tableName varchar(50),
	@columnName varchar(50), 
	@columnType varchar(50),
	@newVersion int = 1)
as
	begin
		declare @query as varchar(max)
		set @query = 
			'alter table ' + @tableName +
			' add ' + @columnName + ' ' + @columnType
		exec(@query)

		if @newVersion = 1
			begin
				insert into VersionHistory (procedureName, tableName, columnName, columnType)
				values ('addColumn', @tableName, @columnName, @columnType)

				update CurrentVersion
				set currentVersion = (select max(versionId) from VersionHistory)
			end
	end
go

create or alter procedure RollbackAddColumn (
	@tableName varchar(50), 
	@columnName varchar(50))
as
	begin
		declare @query as varchar(max)
		set @query =
			'alter table ' + @tableName +
			' drop column ' + @columnName
		exec(@query)
	end
go



-- e)
create or alter procedure CreateForeighKeyConstraint (
	@tableName varchar(50),
	@referencingColumn varchar(50),
	@foreignTable varchar(50),
	@foreignColumn varchar(50),
	@newVersion int = 1)
as
	begin
		declare @query as varchar(max)
		set @query = 
			'alter table ' + @tableName + 
			' add constraint FK_' + @tableName + '_' + @referencingColumn +
			' foreign key (' + @referencingColumn + ')' +
			' references ' + @foreignTable + '(' + @foreignColumn + ');'
		exec(@query)

		if @newVersion = 1
			begin
				insert into VersionHistory (procedureName, tableName, foreignTable, referencingColumn, foreignColumn)
				values ('createForeighKeyConstraint', @tableName, @foreignTable, @referencingColumn, @foreignColumn)

				update CurrentVersion
				set currentVersion = (select max(versionId) from VersionHistory)
			end
	end
go

create or alter procedure RollbackCreateForeighKeyConstraint (
	@tableName varchar(50),
	@referencingColumn varchar(50))
as
	begin 
		declare @query as varchar(max)
		set @query = 
			'alter table ' + @tableName +
			' drop constraint FK_' + @tableName + '_' + @referencingColumn
		exec(@query)
	end
go


-- Part 2
create or alter procedure initialize
as
	begin
		create table CurrentVersion (
			CurrentVersion int primary key
		);
		insert into CurrentVersion (CurrentVersion)
		values (0);
		create table VersionHistory (
			versionId int identity(1, 1) not null primary key,
			procedureName varchar(50),
			tableName varchar(50),
			columnName varchar(50),
			columnType varchar(50),
			oldColumnType varchar(50),
			defaultConstraint varchar(max),
			columnDefinition varchar(max),
			referencingColumn varchar(50),
			foreignTable varchar(50),
			foreignColumn varchar(50)
		)
	end
go

create or alter procedure rollbackInitialize
as
	begin
		drop table CurrentVersion
		drop table VersionHistory
	end
go

create or alter procedure goToVersion(@newVersion int)
as
	begin
		declare @procedureName varchar(50)
		declare @tableName varchar(50)
		declare @columnName varchar(50)
		declare @columnType varchar(50)
		declare @oldColumnType varchar(50)
		declare @defaultConstraint varchar(max)
		declare @columnDefinition varchar(max)
		declare @referencingColumn varchar(50)
		declare @foreignTable varchar(50)
		declare @foreignColumn varchar(50)

		declare @currentVersion int
		select @currentVersion = CurrentVersion from CurrentVersion

		if @newVersion < @currentVersion and @newVersion >= 0
			begin
				while @newVersion < @currentVersion
					begin
						select @procedureName = procedureName from VersionHistory where versionId = @currentVersion
						select @tableName = tableName from VersionHistory where versionId = @currentVersion
						select @columnName = columnName from VersionHistory where versionId = @currentVersion
						
						declare @rollbackProcedureName varchar(100)
						set @rollbackProcedureName = 'Rollback' + @procedureName

						if @procedureName = 'ChangeColumnType'
							begin
								select @oldColumnType = oldColumnType from VersionHistory where versionId = @currentVersion
								exec @rollbackProcedureName @tableName, @columnName, @oldColumnType
							end
						else if @procedureName = 'CreateDefaultConstraint'
							begin
								exec @rollbackProcedureName @tableName, @columnName
							end
						else if @procedureName = 'TableCreator'
							begin
								exec @rollbackProcedureName @tableName
							end
						else if @procedureName = 'AddColumn'
							begin
								exec @rollbackProcedureName @tableName, @columnName
							end
						else if @procedureName = 'CreateForeighKeyConstraint'
							begin
								select @referencingColumn = referencingColumn from VersionHistory where versionId = @currentVersion
								exec @rollbackProcedureName @tableName, @referencingColumn
							end
						
						set @currentVersion = @currentVersion - 1

						update CurrentVersion
						set currentVersion = @currentVersion
					end
			end
		else if @newVersion > @currentVersion and @newVersion <= (select max(versionId) from VersionHistory)
			begin
				while @currentVersion < @newVersion
					begin
						select @procedureName = procedureName from VersionHistory where versionId = (@currentVersion + 1)
						select @tableName = tableName from VersionHistory where versionId = (@currentVersion + 1)
						select @columnName = columnName from VersionHistory where versionId = (@currentVersion + 1)
						
						if @procedureName = 'ChangeColumnType'
							begin
								select @columnType = columnType from VersionHistory where versionId = (@currentVersion + 1)
								exec @procedureName @tableName, @columnName, @columnType, 0
							end
						else if @procedureName = 'CreateDefaultConstraint'
							begin
								select @defaultConstraint = defaultConstraint from VersionHistory where versionId = (@currentVersion + 1)
								exec @procedureName @tableName, @columnName, @defaultConstraint, 0
							end
						else if @procedureName = 'TableCreator'
							begin
								select @columnDefinition = columnDefinition from VersionHistory where versionId = (@currentVersion + 1)
								exec @procedureName @tableName, @columnDefinition, 0
							end
						else if @procedureName = 'AddColumn'
							begin
								select @columnType = columnType from VersionHistory where versionId = (@currentVersion + 1)
								exec @procedureName @tableName, @columnName, @columnType, 0
							end
						else if @procedureName = 'CreateForeighKeyConstraint'
							begin
								select @referencingColumn = referencingColumn from VersionHistory where versionId = (@currentVersion + 1)
								select @foreignTable = foreignTable from VersionHistory where versionId = (@currentVersion + 1)
								select @foreignColumn = foreignColumn from VersionHistory where versionId = (@currentVersion + 1)
								exec @procedureName @tableName, @referencingColumn, @foreignTable, @foreignColumn, 0
							end

						set @currentVersion = @currentVersion + 1

						update CurrentVersion
						set currentVersion = @currentVersion
					end
			end
	end
go
