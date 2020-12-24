USE master;
GO

CREATE RESOURCE POOL restrict_io_pool;
GO

CREATE WORKLOAD GROUP restrict_io_group USING restrict_io_pool;
GO

CREATE FUNCTION dbo.fn_restrict_io()
RETURNS SYSNAME WITH SCHEMABINDING
AS
BEGIN
       DECLARE @GroupName SYSNAME
          IF SUSER_NAME() = 'backup_user'
            BEGIN
              SET @GroupName = 'restrict_io_group'
           END
       ELSE
       BEGIN
              SET @GroupName = 'default'
       END
       RETURN @GroupName;
END
GO

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.fn_restrict_io);

ALTER RESOURCE POOL restrict_io_pool WITH (MAX_IOPS_PER_VOLUME=30);

ALTER RESOURCE GOVERNOR RECONFIGURE;
/*
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
GO
ALTER RESOURCE GOVERNOR DISABLE
GO
*/
