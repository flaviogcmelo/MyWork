SET LINESIZE 145
SET PAGESIZE 9999
SET VERIFY off
col group_name FORMAT a20 HEAD 'Disk Group|Name'
col sector_size FORMAT 99,999 HEAD 'Sector|Size'
col block_size FORMAT 99,999 HEAD 'Block|Size'
col allocation_unit_size FORMAT 999,999,999 HEAD 'Allocation|Unit Size'
col state FORMAT a11 HEAD 'State'
col type FORMAT a6 HEAD 'Type'
col total_mb FORMAT 999,999,999 HEAD 'Total Size (MB)'
col used_mb FORMAT 999,999,999 HEAD 'Used Size (MB)'
col pct_used FORMAT 999.99 HEAD 'Pct. Used'

break on report on disk_group_name skip 1
compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
name group_name
, sector_size sector_size
, block_size block_size
, allocation_unit_size allocation_unit_size
, state state
, type type
, total_mb total_mb
, (total_mb - free_mb) used_mb
, ROUND((1- (free_mb / total_mb))*100, 2) pct_used
FROM
v$asm_diskgroup
ORDER BY
name
/


select d.group_number,
       d.disk_number,
       d.os_mb,
       d.free_mb,
       d.total_mb,
       name
  from v$asm_disk d
 where group_number > 1
 order by group_number, disk_number;


select directory_name, directory_path from dba_directories;