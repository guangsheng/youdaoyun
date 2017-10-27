```
postgres=# \d pg_stat_archiver
            View "pg_catalog.pg_stat_archiver"
       Column       |           Type           | Modifiers
--------------------+--------------------------+-----------
 archived_count     | bigint                   |   --已经成功归档的WAL文件的数量
 last_archived_wal  | text                     |   --最后成功归档的WAL文件的名字
 last_archived_time | timestamp with time zone |   --最后成功归档操作的时间
 failed_count       | bigint                   |   --尝试归档WAL文件失败的次数
 last_failed_wal    | text                     |   --最后失败归档操作的WAL文件的名字
 last_failed_time   | timestamp with time zone |   --最后失败归档操作的时间
 stats_reset        | timestamp with time zone |   --这些状态统计最后重置的时间

postgres=#
```