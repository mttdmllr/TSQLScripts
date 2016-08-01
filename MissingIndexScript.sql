-- Missing Indexes in current database
SELECT  user_seeks * avg_total_user_cost * ( avg_user_impact * 0.01 ) AS [index_advantage] ,
        migs.last_user_seek ,
        mid.[statement] AS [Database.Schema.Table] ,
        mid.equality_columns ,
        mid.inequality_columns ,
        mid.included_columns ,
        migs.unique_compiles ,
        migs.user_seeks ,
        migs.avg_total_user_cost ,
        migs.avg_user_impact ,
        N'CREATE NONCLUSTERED INDEX [IX_' + SUBSTRING(mid.statement,
                                                      CHARINDEX('.',
                                                              mid.statement,
                                                              CHARINDEX('.',
                                                              mid.statement)
                                                              + 1) + 2,
                                                      LEN(mid.statement) - 3
                                                      - CHARINDEX('.',
                                                              mid.statement,
                                                              CHARINDEX('.',
                                                              mid.statement)
                                                              + 1) + 1) + '_'
        + REPLACE(REPLACE(REPLACE(CASE WHEN mid.equality_columns IS NOT NULL
                                            AND mid.inequality_columns IS NOT NULL
                                            AND mid.included_columns IS NOT NULL
                                       THEN mid.equality_columns + '_'
                                            + mid.inequality_columns
                                            + '_Includes'
                                       WHEN mid.equality_columns IS NOT NULL
                                            AND mid.inequality_columns IS NOT NULL
                                            AND mid.included_columns IS NULL
                                       THEN mid.equality_columns + '_'
                                            + mid.inequality_columns
                                       WHEN mid.equality_columns IS NOT NULL
                                            AND mid.inequality_columns IS NULL
                                            AND mid.included_columns IS NOT NULL
                                       THEN mid.equality_columns + '_Includes'
                                       WHEN mid.equality_columns IS NOT NULL
                                            AND mid.inequality_columns IS NULL
                                            AND mid.included_columns IS NULL
                                       THEN mid.equality_columns
                                       WHEN mid.equality_columns IS NULL
                                            AND mid.inequality_columns IS NOT NULL
                                            AND mid.included_columns IS NOT NULL
                                       THEN mid.inequality_columns
                                            + '_Includes'
                                       WHEN mid.equality_columns IS NULL
                                            AND mid.inequality_columns IS NOT NULL
                                            AND mid.included_columns IS NULL
                                       THEN mid.inequality_columns
                                  END, ', ', '_'), ']', ''), '[', '') + '] '
        + N'ON ' + mid.[statement] + N' (' + ISNULL(mid.equality_columns, N'')
        + CASE WHEN mid.equality_columns IS NULL
               THEN ISNULL(mid.inequality_columns, N'')
               ELSE ISNULL(', ' + mid.inequality_columns, N'')
          END + N') ' + ISNULL(N'INCLUDE (' + mid.included_columns + N');',
                               ';') AS CreateStatement
FROM    sys.dm_db_missing_index_group_stats AS migs WITH ( NOLOCK )
        INNER JOIN sys.dm_db_missing_index_groups AS mig WITH ( NOLOCK ) ON migs.group_handle = mig.index_group_handle
        INNER JOIN sys.dm_db_missing_index_details AS mid WITH ( NOLOCK ) ON mig.index_handle = mid.index_handle
WHERE   mid.database_id = DB_ID()
ORDER BY index_advantage DESC;