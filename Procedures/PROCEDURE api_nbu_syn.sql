CREATE OR REPLACE PROCEDURE api_nbu_sync IS
    v_list_currencies  VARCHAR2(2000);
    v_error_message    VARCHAR2(1000);
BEGIN
    -- Витягуємо список валют із sys_params
    BEGIN
        SELECT value_text
        INTO v_list_currencies
        FROM sys_params
        WHERE param_name = 'list_currencies';

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Якщо параметр не знайдений, викликаємо помилку
            log_util.log_error(p_proc_name => 'api_nbu_sync', p_sqlerrm => 'Параметр list_currencies не знайдено');
            RAISE_APPLICATION_ERROR(-20001, 'Параметр list_currencies не знайдено');
        WHEN OTHERS THEN
            -- Логування помилки
            v_error_message := SQLERRM;
            log_util.log_error(p_proc_name => 'api_nbu_sync', p_sqlerrm => v_error_message);
            RAISE;
    END;

    -- Прокручуємо список валют і оновлюємо таблицю cur_exchange
    FOR cc IN (SELECT value_list AS curr
               FROM TABLE(util.table_from_list(p_list_val => v_list_currencies))) 
    LOOP
        BEGIN
    -- Оновлення даних у таблиці cur_exchange
            INSERT INTO cur_exchange (r030, txt, rate, cur, exchangedate)
            SELECT r030, txt, rate, cur, exchangedate
            FROM TABLE(util.get_currency(p_currency => cc.curr));

            -- Логування якщо успішно
            log_util.log_finish(p_proc_name => 'api_nbu_sync', p_text => 'Курс для валюти ' || cc.curr || ' успішно оновлено.');

        EXCEPTION
            WHEN OTHERS THEN
                v_error_message := SQLERRM;
                log_util.log_error(p_proc_name => 'api_nbu_sync', p_sqlerrm => 'Помилка для валюти ' || cc.curr || ': ' || v_error_message);
                -- Продовжуємо обробку інших валют навіть у разі помилки
        END;
    END LOOP;

    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SQLERRM;
        log_util.log_error(p_proc_name => 'api_nbu_sync', p_sqlerrm => v_error_message);
        RAISE;
END api_nbu_sync;
/
