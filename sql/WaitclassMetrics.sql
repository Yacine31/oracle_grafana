select
    n.wait_class,
    nvl(avg(m.time_waited / m.INTSIZE_CSEC),0) AVG_VALUE,
    nvl(min(m.time_waited / m.INTSIZE_CSEC),0) MIN_VALUE,
    nvl(max(m.time_waited / m.INTSIZE_CSEC),0) MAX_VALUE
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
    nvl(avg(value / 100),0) AVG_VALUE,
    nvl(min(value / 100),0) MIN_VALUE,
    nvl(max(value / 100),0) MAX_VALUE
from
    v$sysmetric_history
where
    metric_name = 'CPU Usage Per Sec'
    and group_id = 2
    and begin_time>sysdate - interval '129' SECOND