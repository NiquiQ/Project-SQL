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

       PROCEDURE check_working_time IS
        v_work_time VARCHAR2(10);
        v_day_of_week VARCHAR2(10);
    BEGIN
        v_work_time := TO_CHAR(SYSDATE, 'HH24:MI');
        v_day_of_week := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');

        IF v_day_of_week IN ('SAT', 'SUN') OR v_work_time NOT BETWEEN '08:00' AND '18:00' THEN
            -- ������ ��������� ��������� �������
            log_util.to_log(
                p_appl_proc => 'check_working_time',
                p_message => '�� ������ �������� ����������� ���� � ������� ��� '
            );
            RAISE_APPLICATION_ERROR(-20002, '�� ������ �������� ����������� ���� � ������� ���');
        END IF;
    END check_working_time;


        -- ��������� fire_an_employee
    PROCEDURE fire_an_employee(p_employee_id IN NUMBER) IS
        v_first_name     VARCHAR2(20);
        v_last_name      VARCHAR2(25);
        v_job_id         VARCHAR2(10);
        v_department_id  NUMBER(4);
        v_error_message  VARCHAR2(100);
    BEGIN
        -- ������ ��������� ��������� �������
        log_util.log_start(p_proc_name => 'fire_an_employee');

        -- �������� �������� �����������
        BEGIN
            SELECT first_name, last_name, job_id, department_id
            INTO v_first_name, v_last_name, v_job_id, v_department_id
            FROM employees
            WHERE employee_id = p_employee_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20001, '��������� ���������� �� ����');
        END;

        -- �������� �������� ����
        check_working_time;

        -- ����� ����������� � ��������� ������� ����� ����������
        BEGIN
            INSERT INTO employees_history (employee_id, first_name, last_name, email, phone_number,
                                           hire_date, job_id, salary, commission_pct, manager_id,
                                           department_id, fire_date)
            SELECT employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary,
                   commission_pct, manager_id, department_id, SYSDATE
            FROM employees
            WHERE employee_id = p_employee_id;

            -- ��������� �����������
            DELETE FROM employees
            WHERE employee_id = p_employee_id;

            -- ���� ��� ������� ������, ������ ������� ���������
            log_util.log_finish(p_proc_name => 'fire_an_employee',
                                p_text => '���������� ' || v_first_name || ' ' || v_last_name ||
                                          ', ������: ' || v_job_id || ', ³���: ' || v_department_id || ' - ������ ���������.');
        EXCEPTION
            WHEN OTHERS THEN
                -- ��������� ������� � ��� ����-���� ���������
                v_error_message := SQLERRM;
                log_util.log_error(p_proc_name => 'fire_an_employee', p_sqlerrm => v_error_message);
                RAISE;
        END;

    END fire_an_employee;

    PROCEDURE change_attribute_employee (
        p_employee_id      IN NUMBER,
        p_first_name       IN VARCHAR2 DEFAULT NULL,
        p_last_name        IN VARCHAR2 DEFAULT NULL,
        p_email            IN VARCHAR2 DEFAULT NULL,
        p_phone_number     IN VARCHAR2 DEFAULT NULL,
        p_job_id           IN VARCHAR2 DEFAULT NULL,
        p_salary           IN NUMBER DEFAULT NULL,
        p_commission_pct   IN VARCHAR2 DEFAULT NULL,
        p_manager_id       IN NUMBER DEFAULT NULL,
        p_department_id    IN NUMBER DEFAULT NULL
    ) IS
        v_sql     VARCHAR2(4000);
        v_first   BOOLEAN := TRUE;
        v_error_message VARCHAR2(4000);
    BEGIN
        -- ������� ���������
        log_util.log_start(p_proc_name => 'change_attribute_employee');

        -- ��������, �� ���� � ���� ��������, ���� p_employee_id, �� � NULL
        IF p_first_name IS NULL AND p_last_name IS NULL AND p_email IS NULL AND p_phone_number IS NULL AND
           p_job_id IS NULL AND p_salary IS NULL AND p_commission_pct IS NULL AND p_manager_id IS NULL AND
           p_department_id IS NULL THEN
            log_util.log_finish(p_proc_name => 'change_attribute_employee',
                                p_text => '�� �������� ������ ������� ��� ���������');
            RAISE_APPLICATION_ERROR(-20001, '�� �������� ������ ������� ��� ���������');
        END IF;

        v_sql := 'UPDATE employees SET ';

        -- ��������� ���� ��� ������� ���������
        IF p_first_name IS NOT NULL THEN
            v_sql := v_sql || 'first_name = ''' || p_first_name || '''';
            v_first := FALSE;
        END IF;

        IF p_last_name IS NOT NULL THEN
            IF NOT v_first THEN
                v_sql := v_sql || ', ';
            END IF;
            v_sql := v_sql || 'last_name = ''' || p_last_name || '''';
            v_first := FALSE;
        END IF;

        IF p_email IS NOT NULL THEN
            IF NOT v_first THEN
                v_sql := v_sql || ', ';
            END IF;
            v_sql := v_sql || 'email = ''' || p_email || '''';
            v_first := FALSE;
        END IF;

        IF p_phone_number IS NOT NULL THEN
            IF NOT v_first THEN
                v_sql := v_sql || ', ';
            END IF;
            v_sql := v_sql || 'phone_number = ''' || p_phone_number || '''';
            v_first := FALSE;
        END IF;

        IF p_job_id IS NOT NULL THEN
            IF NOT v_first THEN
                v_sql := v_sql || ', ';
            END IF;
            v_sql := v_sql || 'job_id = ''' || p_job_id || '''';
            v_first := FALSE;
        END IF;

        IF p_salary IS NOT NULL THEN
            IF NOT v_first THEN
                v_sql := v_sql || ', ';
            END IF;
            v_sql := v_sql || 'salary = ' || p_salary;
            v_first := FALSE;
        END IF;

        IF p_commission_pct IS NOT NULL THEN
            IF NOT v_first THEN
                v_sql := v_sql || ', ';
            END IF;
            v_sql := v_sql || 'commission_pct = ' || p_commission_pct;
            v_first := FALSE;
        END IF;

        IF p_manager_id IS NOT NULL THEN
            IF NOT v_first THEN
                v_sql := v_sql || ', ';
            END IF;
            v_sql := v_sql || 'manager_id = ' || p_manager_id;
            v_first := FALSE;
        END IF;

        IF p_department_id IS NOT NULL THEN
            IF NOT v_first THEN
                v_sql := v_sql || ', ';
            END IF;
            v_sql := v_sql || 'department_id = ' || p_department_id;
        END IF;

        v_sql := v_sql || ' WHERE employee_id = ' || p_employee_id;

        -- ��������� �����������
        BEGIN
            EXECUTE IMMEDIATE v_sql;
            COMMIT;

            -- ��������� �������� ����������
            log_util.log_finish(p_proc_name => 'change_attribute_employee',
                                p_text => '� ����������� ' || p_employee_id || ' ������ ������� ��������');
        EXCEPTION
            WHEN OTHERS THEN
                v_error_message := SQLERRM;
                log_util.log_error(p_proc_name => 'change_attribute_employee', p_sqlerrm => v_error_message);
                RAISE;
        END;

    END change_attribute_employee;

END log_util;
/
