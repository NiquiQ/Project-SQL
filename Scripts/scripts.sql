select * from logs 
order by LOG_DATE desc

delete logs
where trunc(LOG_DATE) = to_date(sysdate)

select * from employees
select * from jobs
select * from DEPARTMENTS


-- Перевірка процедури add_employee
BEGIN
    log_util.add_employee(
        p_first_name     => 'Peter',
        p_last_name      => 'Parker',
        p_email          => 'parker',
        p_phone_number   => '555.458.1234',
        p_hire_date      => SYSDATE,
        p_job_id         => 'AD_PRES',
        p_salary         => 40000,
        p_commission_pct => NULL,
        p_manager_id     => 108,
        p_department_id  => 100
    );
END;
/

-- Перевірка процедури fire_an_employee
BEGIN
    log_util.fire_an_employee(p_employee_id => 228);
END;

select * from employees_history

-- Перевірка процедури change_attribute_employee
select * from employees

BEGIN
    log_util.change_attribute_employee(
        p_employee_id    => 223,
        p_last_name     => 'Prosto'
    );
END;
/

