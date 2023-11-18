SELECT
    owner,
    table_name,
    round (SUM (table_bytes) / 1024 / 1024) MB_TABLE,
    round (SUM (bytes) / 1024 / 1024) MB_TOTAL,
    round (SUM (EST_TAB_SPACE) / 1024 / 1024) MB_TABLE_EST,
    sum(num_rows) NUM_ROWS,
    decode (sum(LOBS),0,'NO','YES') HAS_LOBS
FROM
    (
        SELECT
            table_name,
            owner,
            0 bytes,
            0 table_bytes,
            avg_row_len * num_rows EST_TAB_SPACE,
            num_rows,
            0 LOBS
        FROM
            dba_tab_Statistics
        UNION ALL
        SELECT
            segment_name table_name,
            owner,
            bytes,
            bytes,
            0,
            0,
            0
        FROM
            dba_segments
        WHERE
            segment_type = 'TABLE'
        UNION ALL
        SELECT
            i.table_name,
            i.owner,
            s.bytes,
            0,
            0,
            0,
            0
        FROM
            dba_indexes i,
            dba_segments s
        WHERE
            s.segment_name = i.index_name
            AND s.owner = i.owner
            AND s.segment_type = 'INDEX'
        UNION ALL
        SELECT
            l.table_name,
            l.owner,
            s.bytes,
            s.bytes,
            0,
            0,
            1
        FROM
            dba_lobs l,
            dba_segments s
        WHERE
            s.segment_name = l.segment_name
            AND s.owner = l.owner
            AND s.segment_type = 'LOBSEGMENT'
        UNION ALL
        SELECT
            l.table_name,
            l.owner,
            s.bytes,
            0,
            0,
            0,
            0
        FROM
            dba_lobs l,
            dba_segments s
        WHERE
            s.segment_name = l.index_name
            AND s.owner = l.owner
            AND s.segment_type = 'LOBINDEX'
    ) s
WHERE
    owner NOT IN (
        select
            username
        from
            dba_users
        where
            DEFAULT_TABLESPACE in (
                'SYSTEM',
                'SYSAUX',
                'USERS',
                'XDB',
                'DRSYS',
                'ODM',
                'CWMLITE',
                'TOOLS'
            )
    )
GROUP BY
    table_name,
    owner
having
    round (SUM (table_bytes) / 1024 / 1024) > 0