DECLARE
    v_result VARCHAR2(100);
BEGIN
    log_util.copy_table(
        p_source_scheme => 'HR',  
        p_target_scheme => 'OLEKSIYI_VO0',  
        p_list_table    => 'PRODUCTS',  
        p_copy_data     => TRUE, 
        po_result       => v_result  
    );
    DBMS_OUTPUT.PUT_LINE('Результат: ' || v_result);
END;
/

select * from logs 
order by LOG_DATE desc



SELECT * FROM all_tables WHERE owner = 'HR' AND table_name IN ('PRODUCTS');
SELECT * FROM all_tables WHERE owner = 'OLEKSIYI_VO0' AND table_name IN ('PRODUCTS');
