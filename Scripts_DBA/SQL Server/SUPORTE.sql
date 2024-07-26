SELECT
    name,
    size,
    size * 8/1024 'Size (MB)',
    max_size
FROM sys.master_files
WHERE name not like '%log'
  and name not like 'temp%';

exec sp_helpdb;

exec sp_databases;