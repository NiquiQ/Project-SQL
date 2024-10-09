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
