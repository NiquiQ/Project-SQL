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
        -- Початок логування
        log_util.log_start(p_proc_name => 'change_attribute_employee');

        -- Перевірка, що хоча б один параметр, окрім p_employee_id, не є NULL
        IF p_first_name IS NULL AND p_last_name IS NULL AND p_email IS NULL AND p_phone_number IS NULL AND
           p_job_id IS NULL AND p_salary IS NULL AND p_commission_pct IS NULL AND p_manager_id IS NULL AND
           p_department_id IS NULL THEN
            log_util.log_finish(p_proc_name => 'change_attribute_employee',
                                p_text => 'Не передано жодних значень для оновлення');
            RAISE_APPLICATION_ERROR(-20001, 'Не передано жодних значень для оновлення');
        END IF;

        v_sql := 'UPDATE employees SET ';

        -- Додавання умов для кожного параметра
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

        -- Оновлення співробітника
        BEGIN
            EXECUTE IMMEDIATE v_sql;
            COMMIT;

            -- Логування успішного результату
            log_util.log_finish(p_proc_name => 'change_attribute_employee',
                                p_text => 'У співробітника ' || p_employee_id || ' успішно оновлені атрибути');
        EXCEPTION
            WHEN OTHERS THEN
                v_error_message := SQLERRM;
                log_util.log_error(p_proc_name => 'change_attribute_employee', p_sqlerrm => v_error_message);
                RAISE;
        END;

    END change_attribute_employee;
