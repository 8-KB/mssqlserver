Please note:

!! You will need to add SET STATISTICS PROFILE ON; or SET STATISTICS XML ON; in the query batch that is doing the CREATE INDEX (and placed before the CREATE INDEX statement, if that wasn't obvious), else no rows will show up in this DMV for that SPID / session_id !!

The IN operator is used to filter out the Index Insert row that, if included, will increase the TotalRows values, which will skew the calculations since that row never shows any rows processed.

The row count displayed here (i.e. TotalRows) is double the row count of the table due to the operation taking two steps, each one operating on all of the rows: first is a "Table Scan" or "Clustered Index Scan", and second is the "Sort". You will see "Table Scan" when creating a Clustered Index or creating a NonClustered Index on a Heap. You will see "Clustered Index Scan" when creating a NonClustered Index on a Clustered Index.

This query does not seem to work when creating Filtered Indexes. For some reason, Filtered Indexes a) do not have the "Sort" step, and b) the row_count field never increases from 0.
Not sure what I was testing before, but my tests now indicate that Filtered Indexes are captured by this query. Sweet. Though just beware that row counts might be off (I will see if I can fix that someday).

When creating a Clustered Index on a Heap that already has NonClustered Indexes on it, the NonClustered Indexes need to be rebuilt (to swap out the RID -- RowID -- for the Clustered Index Key(s)), and each NonClustered Index rebuild will be a separate operation and hence not reflected in the stats returned by this query during the creation of the Clustered Index.

This query has been tested against:

Creating:
NonClustered Indexes on a Heap
a Clustered Index (no NonClustered Indexes exist)
NonClustered Indexes on the Clustered Index/Table
a Clustered Index when NonClustered Indexes already exist
Unique NonClustered Indexes on the Clustered Index/Table
Rebuilding (table with Clustered Index and one NonClustered Index; tested on SQL Server 2014, 2016, 2017, and 2019) via:

ALTER TABLE [schema_name].[table_name] REBUILD; (only Clustered Index shows up when using this method)
ALTER INDEX ALL ON [schema_name].[table_name] REBUILD;
ALTER INDEX [index_name] ON [schema_name].[table_name] REBUILD;

```sql
DECLARE @SPID INT = 51;

;WITH agg AS
(
     SELECT SUM(qp.[row_count]) AS [RowsProcessed],
            SUM(qp.[estimate_row_count]) AS [TotalRows],
            MAX(qp.last_active_time) - MIN(qp.first_active_time) AS [ElapsedMS],
            MAX(IIF(qp.[close_time] = 0 AND qp.[first_row_time] > 0,
                    [physical_operator_name],
                    N'<Transition>')) AS [CurrentStep]
     FROM sys.dm_exec_query_profiles qp
     WHERE qp.[physical_operator_name] IN (N'Table Scan', N'Clustered Index Scan',
                                           N'Index Scan',  N'Sort')
     AND   qp.[session_id] = @SPID
), comp AS
(
     SELECT *,
            ([TotalRows] - [RowsProcessed]) AS [RowsLeft],
            ([ElapsedMS] / 1000.0) AS [ElapsedSeconds]
     FROM   agg
)
SELECT [CurrentStep],
       [TotalRows],
       [RowsProcessed],
       [RowsLeft],
       CONVERT(DECIMAL(5, 2),
               (([RowsProcessed] * 1.0) / [TotalRows]) * 100) AS [PercentComplete],
       [ElapsedSeconds],
       (([ElapsedSeconds] / [RowsProcessed]) * [RowsLeft]) AS [EstimatedSecondsLeft],
       DATEADD(SECOND,
               (([ElapsedSeconds] / [RowsProcessed]) * [RowsLeft]),
               GETDATE()) AS [EstimatedCompletionTime]
FROM   comp;
```
Sample output:

                        Rows                 Percent   Elapsed  Estimated    Estimated
CurrentStep  TotalRows  Processed  RowsLeft  Complete  Seconds  SecondsLeft  CompletionTime
-----------  ---------  ---------  --------  --------  -------  -----------  --------------
Clustered    11248640   4786937    6461703   42.56     4.89400  6.606223     2016-05-23
Index Scan                                                                   14:32:40.547
