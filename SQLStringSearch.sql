----Simple MS SQL Object Search----
DECLARE @Search VARCHAR(255) = 'Sales' --Edit value to search for different strings

SELECT DISTINCT o.[name] AS [ObjectName]
	   ,o.type_desc [ObjectType]
  FROM sys.sql_modules m
       JOIN sys.objects o
	   ON m.object_id = o.object_id
 WHERE m.[definition] LIKE '%' + @Search + '%'
ORDER BY 2,1;
GO