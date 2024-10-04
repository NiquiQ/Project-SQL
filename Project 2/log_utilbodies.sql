CREATE OR REPLACE PACKAGE BODY log_util IS

    --��������� to_log
    PROCEDURE to_log(p_appl_proc IN VARCHAR2, p_message IN VARCHAR2) IS
        PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO logs(id, appl_proc, message)
        VALUES(log_seq.NEXTVAL, p_appl_proc, p_message);
        COMMIT;
    END to_log;

    -- ��������� log_start
    PROCEDURE log_start(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL) IS
        v_text VARCHAR2(5000);
    BEGIN
        IF p_text IS NULL THEN
            v_text := '����� ���������, ����� ������� = ' || p_proc_name;
        ELSE
            v_text := p_text;
        END IF;

        to_log(p_appl_proc => p_proc_name, p_message => v_text);
    END log_start;

    -- ��������� log_finish
    PROCEDURE log_finish(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL) IS
        v_text VARCHAR2(5000);
    BEGIN
        IF p_text IS NULL THEN
            v_text := '���������� ���������, ����� ������� = ' || p_proc_name;
        ELSE
            v_text := p_text;
        END IF;

        to_log(p_appl_proc => p_proc_name, p_message => v_text);
    END log_finish;

    -- ��������� log_error
    PROCEDURE log_error(p_proc_name IN VARCHAR2, p_sqlerrm IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL) IS
        v_text VARCHAR2(5000);
    BEGIN
        IF p_text IS NULL THEN
            v_text := '� �������� ' || p_proc_name || ' ������� �������. ' || p_sqlerrm;
        ELSE
            v_text := p_text;
        END IF;

        to_log(p_appl_proc => p_proc_name, p_message => v_text);
    END log_error;

    PROCEDURE add_employee(
    p_first_name     IN VARCHAR2,
    p_last_name      IN VARCHAR2,
    p_email          IN VARCHAR2,
    p_phone_number   IN VARCHAR2,
    p_hire_date      IN DATE DEFAULT TRUNC(SYSDATE, 'DD'),
    p_job_id         IN VARCHAR2,
    p_salary         IN NUMBER,
    p_commission_pct IN VARCHAR2 DEFAULT NULL,
    p_manager_id     IN NUMBER,
    p_department_id  IN NUMBER DEFAULT 100
) IS
    v_max_employee_id NUMBER;
    v_min_salary      NUMBER;
    v_max_salary      NUMBER;
    v_department_name VARCHAR2(100);
    v_job_title       VARCHAR2(100);
    v_work_time       VARCHAR2(100);
    v_error_message   VARCHAR2(1000);
BEGIN
    -- ������ ��������� ��������� �������
    log_util.log_start(p_proc_name => 'add_employee');

    -- �������� �������� p_job_id � ������� jobs
    BEGIN
        SELECT job_title, min_salary, max_salary
        INTO v_job_title, v_min_salary, v_max_salary
        FROM jobs
        WHERE job_id = p_job_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, '������� ��������� ��� ������');
    END;

    -- �������� �������� p_department_id � ������� departments
    BEGIN
        SELECT department_name
        INTO v_department_name
        FROM departments
        WHERE department_id = p_department_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, '������� ��������� ������������� �����');
    END;

    -- �������� ���������� ��������
    IF p_salary < v_min_salary OR p_salary > v_max_salary THEN
        RAISE_APPLICATION_ERROR(-20003, '�������� �� ������� �������� ��� ���� ������');
    END IF;
    
    -- �������� �������� ����
    v_work_time := TO_CHAR(SYSDATE, 'HH24:MI');
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN') OR v_work_time NOT BETWEEN '08:00' AND '18:00' THEN
       RAISE_APPLICATION_ERROR(-20004, '�� �� ������ ������ ������ ����������� � ����������� ���');
    END IF;


    -- ����������� ������������� employee_id ��� ������ �����������
    SELECT MAX(employee_id) + 1 INTO v_max_employee_id FROM employees;

    -- ������� ������ �����������
    INSERT INTO employees (
        employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, 
        commission_pct, manager_id, department_id
    ) VALUES (
        v_max_employee_id, p_first_name, p_last_name, p_email, p_phone_number, p_hire_date, 
        p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id
    );

    -- ���� ��� ������� ������, ������ ������� ���������
    log_util.log_finish(p_proc_name => 'add_employee', p_text => '���������� �������: ' || 
        p_first_name || ' ' || p_last_name || ', ������: ' || p_job_id || ', ³���: ' || p_department_id);

EXCEPTION
    WHEN OTHERS THEN
        -- ��������� ������� � ��� ����-���� ���������
        v_error_message := SQLERRM;
        log_util.log_error(p_proc_name => 'add_employee', p_sqlerrm => v_error_message);
        RAISE;
END add_employee;


END log_util;
/
