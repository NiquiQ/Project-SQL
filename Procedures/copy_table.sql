PROCEDURE copy_table(p_source_scheme  IN VARCHAR2,
                     p_target_scheme  IN VARCHAR2 DEFAULT USER,
                     p_list_table     IN VARCHAR2,
                     p_copy_data      IN BOOLEAN DEFAULT FALSE,
                     po_result        OUT VARCHAR2) IS
                     
    v_sql_create VARCHAR2(4000);  
    v_sql_copy   VARCHAR2(4000);  
    v_table_name    VARCHAR2(100); 
    
    BEGIN

    to_log('copy_table', 'Початок копіювання таблиць '||p_list_table||' з '|| p_source_scheme ||' до '|| p_target_scheme);
        
    -- Перебираємо всі таблиці, передані в параметрі p_list_table
        FOR cc IN (
            SELECT table_name, 
                   'CREATE TABLE ' || p_target_scheme || '.' || table_name || ' (' ||
                   LISTAGG(column_name || ' ' || data_type || count_symbol, ', ') WITHIN GROUP(ORDER BY column_id) || ')' AS ddl_code
            FROM (
                SELECT table_name,
                       column_name,
                       data_type,
                       CASE 
                           WHEN data_type IN ('VARCHAR2', 'CHAR') THEN '(' || data_length || ')'
                           WHEN data_type = 'DATE' THEN NULL 
                           WHEN data_type = 'NUMBER' THEN REPLACE('(' || data_precision || ',' || data_scale || ')', '(,)', NULL)
                       END AS count_symbol,
                       column_id
                FROM all_tab_columns
                WHERE owner = p_source_scheme
                  AND table_name IN (SELECT * FROM TABLE(util.table_from_list(p_list_table))) 
                  AND table_name NOT IN (SELECT table_name FROM all_tables WHERE owner = p_target_scheme)
                ORDER BY table_name, column_id
            )
            GROUP BY table_name
        ) LOOP
    
        BEGIN
        
        v_table_name := cc.table_name;
        v_sql_create := cc.ddl_code;

        to_log('copy_table', 'Обробка таблиці: ' || v_table_name); 
        
        EXECUTE IMMEDIATE v_sql_create;
        to_log('copy_table', 'Таблицю ' || v_table_name || ' успішно створено в схемі ' || p_target_scheme);

            IF p_copy_data = TRUE THEN
                v_sql_copy := 'INSERT INTO ' || p_target_scheme || '.' || v_table_name || 
                                 ' SELECT * FROM ' || p_source_scheme || '.' || v_table_name;
                EXECUTE IMMEDIATE v_sql_copy;
                to_log('copy_table', 'Дані з таблиці ' || p_source_scheme || '.' || v_table_name || ' успішно скопійовані в ' || p_target_scheme || '.' || v_table_name);
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                to_log('copy_table', 'Помилка під час копіювання таблиці ' || v_table_name || ': ' || sqlerrm);
                CONTINUE;
        END;
    END LOOP;

    to_log('copy_table', 'Копіювання таблиць '||p_list_table||' з '||p_source_scheme||' до '||p_target_scheme||' завершено');
    po_result := 'Таблиці '||p_list_table||' успішно скопійовані з '||p_source_scheme||' до '||p_target_scheme;
    
    EXCEPTION
        WHEN OTHERS THEN
            to_log('copy_table', 'Помилка під час копіювання таблиць: ' || sqlerrm);
            po_result := 'Помилка під час копіювання таблиць: ' || sqlerrm;
            
END copy_table;
