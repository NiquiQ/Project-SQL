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

END log_util;
/
