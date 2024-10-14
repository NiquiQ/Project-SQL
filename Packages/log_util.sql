CREATE OR REPLACE PACKAGE log_util IS
    PROCEDURE log_start(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL);
    PROCEDURE log_finish(p_proc_name IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL);
    PROCEDURE log_error(p_proc_name IN VARCHAR2, p_sqlerrm IN VARCHAR2, p_text IN VARCHAR2 DEFAULT NULL);
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
        p_department_id  IN NUMBER DEFAULT 100);
     PROCEDURE check_working_time;
     PROCEDURE fire_an_employee(p_employee_id IN NUMBER);
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
        p_department_id    IN NUMBER DEFAULT NULL);
      PROCEDURE api_nbu_sync;     
      PROCEDURE copy_table(
        p_source_scheme IN VARCHAR2,
        p_target_scheme IN VARCHAR2 DEFAULT USER,
        p_list_table    IN VARCHAR2,
        p_copy_data     IN BOOLEAN DEFAULT FALSE,
        po_result       OUT VARCHAR2); 
END log_util;
