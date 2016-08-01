USE tempdb;  --Insert DB of choice here
GO

DECLARE	@l_CutOffDate VARCHAR(10) = CAST(CONVERT(DATE,GETDATE()) AS VARCHAR(10))
		,@l_SQL NVARCHAR(MAX);

DECLARE @SQL_CMDS TABLE (ObjName NVARCHAR(128), SQL_CMDS NVARCHAR(MAX));

SET @l_SQL = N'
USE [?];
IF DB_NAME() NOT IN (''master'', ''msdb'', ''model'', ''tempdb'', ''ReportServer'', ''ReportServerTempDB'')
BEGIN
	WITH MODIFIED_TABLES AS (
		SELECT	o.object_id
				,OBJECT_SCHEMA_NAME(o.object_id) + ''.'' + o.name AS tblname
		FROM	sys.objects o
		WHERE	o.modify_date >= ' + '''' + @l_CutOffDate + '''' + '
		AND		o.type = ''U'' -- Table (user-defined)
	)
	, MODIFIED_VIEWS AS (
		SELECT	o.object_id
				,OBJECT_SCHEMA_NAME(o.object_id) + ''.'' + o.name AS viewname
				,1 AS RecompileView
		FROM	sys.objects o
		WHERE	o.modify_date >= ' + '''' + @l_CutOffDate + '''' + '
		AND		o.type = ''V'' -- View
		UNION
		SELECT	v.object_id
				,OBJECT_SCHEMA_NAME(v.object_id) + ''.'' + v.name AS viewname
				,0 AS RecompileView
		FROM	MODIFIED_TABLES t
				INNER JOIN sys.sql_dependencies d ON d.object_id = t.object_id
				INNER JOIN sys.views v ON v.object_id = d.referenced_major_id
	)

	SELECT	MODIFIED_TABLES.tblname
			,''USE '' + DB_NAME() + ''; EXEC sp_recompile '' + '''' + DB_NAME() + ''.'' + MODIFIED_TABLES.tblname + '''' + '';''
	FROM	MODIFIED_TABLES
	UNION
	SELECT	MODIFIED_VIEWS.viewname
			,''USE '' + DB_NAME() + ''; EXEC sp_refreshview '' + '''' + DB_NAME() + ''.'' + MODIFIED_VIEWS.viewname + '''' + '';''
				+ CASE WHEN MODIFIED_VIEWS.RecompileView = 1 THEN '' EXEC sp_recompile '' + '''' + DB_NAME() + ''.'' + MODIFIED_VIEWS.viewname + '''' + '';''
						ELSE ''''
					END
	FROM	MODIFIED_VIEWS;
END;
'

INSERT INTO @SQL_CMDS (ObjName, SQL_CMDS)
EXEC sys.sp_MSforeachdb @command1 = @l_SQL;

SELECT	ObjName
       ,SQL_CMDS
FROM	@SQL_CMDS;
