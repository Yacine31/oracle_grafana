select
    n.wait_class,
    avg(m.time_waited / m.INTSIZE_CSEC) AVG_VALUE,
    min(m.time_waited / m.INTSIZE_CSEC) MIN_VALUE,
    max(m.time_waited / m.INTSIZE_CSEC) MAX_VALUE
from
    v$waitclassmetric m, --v$waitclassmetric_history m,
    v$system_wait_class n
where
    m.wait_class_id = n.wait_class_id
group by
    n.wait_class
union
select
    'CPU',
    avg(value / 100) AVG_VALUE,
    min(value / 100) MIN_VALUE,
    max(value / 100) MAX_VALUE
from
    v$sysmetric_history
where
    metric_name = 'CPU Usage Per Sec'
    and group_id = 2
    and begin_time>sysdate - interval '129' SECOND