Alter TRIGGER [dbo].[trgUdpDel_Rollback] ON [dbo].[tab]
FOR UPDATE, DELETE AS
BEGIN
   
    DECLARE @rows INT = @@ROWCOUNT,
            @table_rows INT = (SELECT SUM(row_count) FROM sys.dm_db_partition_stats WHERE [object_id] = OBJECT_ID('tab') AND (index_id <= 1))
  
 IF @rows >= @table_rows
    BEGIN
         
        DECLARE @sql nvarchar(max), @login nvarchar(max)
 
        SELECT @login = SUSER_NAME()
 
        SET @sql = 'DBCC INPUTBUFFER(' + CAST(@@SPID AS nvarchar(100)) + ')'
        CREATE TABLE #SQL (
            EventType varchar(100),
            Parameters int,
            EventInfo nvarchar(max)
        )
        INSERT INTO #SQL
        EXEC sp_executesql @sql
 
        SELECT @sql = EventInfo FROM #SQL
 
        SELECT @sql
        DROP TABLE #SQL
         
        -- Transforma o conteúdo da query em HTML
        DECLARE @HTML VARCHAR(MAX);  
 
        SET @HTML = '
        <html>
        <head>
            <title>Tentativa de update/delete sem where</title>
        </head>
 
        <br><br><h2>O usuário ' + @login + ' tentou fazer um update/delete sem where.</h2>
        <br/><br/>
        Segue Comando:
        <br/><br/>
        ' + @sql + '
        <br/><br/>
 
        <br/>
        DGA Solutions';
 
        ROLLBACK TRANSACTION; 
        RAISERROR ('Verifique se a sua instrução update ou delete está correta, e se estiver entre em contato com o DBA', 15, 1); 
         
            -- Envia o e-mail
        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'profile', -- sysname
            @recipients = 'email-destinatario', -- varchar(max)
            @subject = N'Tentativa de update/delete sem where', -- nvarchar(255)
            @body = @HTML, -- nvarchar(max)
            @body_format = 'html'
             
        RETURN;
    END
END;