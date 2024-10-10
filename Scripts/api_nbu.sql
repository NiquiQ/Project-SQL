select * from logs 
order by LOG_DATE desc

CREATE TABLE sys_params (
    param_name    VARCHAR2(150),
    value_date    DATE,
    value_text    VARCHAR2(2000),
    value_number  NUMBER,
    param_descr   VARCHAR2(200)
);

select * from sys_params


INSERT INTO sys_params (param_name, value_date, value_text, param_descr)
VALUES ('list_currencies', TRUNC(SYSDATE), 'USD,EUR,KZT,AMD,GBP,ILS', 'Список валют для синхронізації в процедурі util.api_nbu_sync');

select * from cur_exchange

BEGIN
    api_nbu_sync;
END;

BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'JOB_CUR_EXCHANGE',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN log_util.api_nbu_sync; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=6; BYMINUTE=0',
        enabled         => TRUE
    );
END;



BEGIN
DBMS_SCHEDULER.RUN_JOB(job_name => 'JOB_CUR_EXCHANGE');
END;
/
