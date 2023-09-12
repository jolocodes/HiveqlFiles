CREATE MATERIALIZED VIEW mv_recently_hired AS
 SELECT empid, name, deptname, hire_date FROM emps
 JOIN depts ON (emps.deptno = depts.deptno)
 WHERE hire_date >= '2020-01-01 00:00:00';

SELECT empid, name FROM emps
JOIN depts ON (emps.deptno = depts.deptno)
WHERE hire_date >= '2020-03-01 00:00:00' AND deptname = 'finance';


CREATE SCHEDULED QUERY scheduled_rebuild
EVERY 10 MINUTES AS
ALTER MATERIALIZED VIEW mv_recently_hired REBUILD;

SELECT *
FROM information_schema.scheduled_queries
WHERE schedule_name = 'scheduled_rebuild'; 
