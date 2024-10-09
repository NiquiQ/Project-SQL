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
