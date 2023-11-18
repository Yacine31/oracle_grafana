select
    name,
    value
from
    (
        select
            name,
            value,
            isdefault,
            min(isdefault) over (partition by name) as mindef
        from
            (
                select
                    name,
                    value,
                    0 as isdefault
                from
                    v$rman_configuration rc
                union
                    (
                        select
                            objectschema name,
                            objectname value,
                            1 as isdefault
                        from
                            table(
                                sys.ODCIObjectList(
                                    sys.odciobject('CONTROLFILE AUTOBACKUP', 'OFF # default'),
                                    sys.odciobject('ARCHIVELOG DELETION POLICY','TO NONE # default'),
                                    sys.odciobject('DEFAULT DEVICE TYPE', 'TO DISK # default'),
                                    sys.odciobject('ENCRYPTION FOR DATABASE', 'OFF # default'),
                                    sys.odciobject('MAXSETSIZE', 'TO UNLIMITED # default'),
                                    sys.odciobject('BACKUP OPTIMIZATION', 'OFF # default'),
                                    sys.odciobject('RETENTION POLICY', 'TO REDUNDANCY 1 # default')
                                )
                            )
                    )
            )
    )
where
    isdefault = mindef
order by
    name
