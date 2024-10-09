CREATE OR REPLACE PROCEDURE to_log(p_appl_proc IN VARCHAR2,
                        p_message IN VARCHAR2) IS
    PRAGMA autonomous_transaction;
BEGIN
    INSERT INTO logs(id, appl_proc, message)
    VALUES(log_seq.NEXTVAL, p_appl_proc, p_message);
    COMMIT;
END;
/
