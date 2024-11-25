-- Заготовка под тесты
select * from payment p where p.payment_id = 3
/
select * from payment_detail pd where pd.payment_id = 41
/

-- Проверка "Создание клиенат"
declare
  v_payment_id                  payment.payment_id%type;
  v_payment_sum                 payment.summa%type := 100;
  v_currency_id                 payment.currency_id%type := 643;
  v_payment_from_client_id      payment.from_client_id%type := 1;
  v_payment_to_client_id        payment.to_client_id%type := 2;
  v_current_dtime               timestamp := systimestamp;

  v_payment_detail_data         t_payment_detail_array := t_payment_detail_array( t_payment_detail(1, 'Мобильное приложение банка XYZ')
                                                                                , t_payment_detail(2, '192.168.1.1')
                                                                                , t_payment_detail(3, 'Оплата за услуги связи за сентябрь')
                                                                                );

begin
  v_payment_id := payment_api_pack.create_payment( p_payment_from_client_id => v_payment_from_client_id
                                                 , p_payment_to_client_id   => v_payment_to_client_id
                                                 , p_payment_sum            => v_payment_sum
                                                 , p_currency_id            => v_currency_id
                                                 , p_payment_date           => v_current_dtime
                                                 , p_payment_detail_data    => v_payment_detail_data
                                                 );
  dbms_output.put_line('v_payment_id: '|| v_payment_id);
end;
/

-- Проверка технических полей ( при создании равны)
declare
  v_payment_id                  payment.payment_id%type;
  v_payment_sum                 payment.summa%type := 100;
  v_currency_id                 payment.currency_id%type := 643;
  v_payment_from_client_id      payment.from_client_id%type := 1;
  v_payment_to_client_id        payment.to_client_id%type := 2;
  v_current_dtime               timestamp := systimestamp;
  
  v_create_dtime_tech           payment.create_dtime_tech%type;
  v_update_dtime_tech           payment.update_dtime_tech%type;

  v_payment_detail_data         t_payment_detail_array := t_payment_detail_array( t_payment_detail(1, 'Мобильное приложение банка XYZ')
                                                                                , t_payment_detail(2, '192.168.1.1')
                                                                                , t_payment_detail(3, 'Оплата за услуги связи за сентябрь')
                                                                                );

begin
  v_payment_id := payment_api_pack.create_payment( p_payment_from_client_id => v_payment_from_client_id
                                                 , p_payment_to_client_id   => v_payment_to_client_id
                                                 , p_payment_sum            => v_payment_sum
                                                 , p_currency_id            => v_currency_id
                                                 , p_payment_date           => v_current_dtime
                                                 , p_payment_detail_data    => v_payment_detail_data
                                                 );

  dbms_output.put_line('v_payment_id: '|| v_payment_id);

  select p.create_dtime_tech
       , p.update_dtime_tech
  into v_create_dtime_tech
     , v_update_dtime_tech
  from payment p
  where p.payment_id = v_payment_id;

  if v_create_dtime_tech <> v_update_dtime_tech then
    raise_application_error(-20998, 'Технические даты не совпадают!');
  end if;
end;
/
-- Проверка "Cброс платежа в ошибочный статус"
declare
  v_payment_id                  payment.payment_id%type := 41;
  v_payment_error_reason        payment.status_change_reason%type := 'недостаточно средств';
begin
  payment_api_pack.fail_payment( p_payment_id           => v_payment_id
                               , p_payment_error_reason => v_payment_error_reason
                               );
end;
/
-- Проверка технических полей ( при изменеии различаются) 
declare
  v_payment_id                  payment.payment_id%type := 41;
  v_payment_error_reason        payment.status_change_reason%type := 'недостаточно средств';
begin
  payment_api_pack.fail_payment( p_payment_id           => v_payment_id
                               , p_payment_error_reason => v_payment_error_reason
                               );
end;
/

-- Проверка "Отмена платежа"
declare
  v_payment_id                  payment.payment_id%type := 3;
  v_payment_cancel_reason       payment.status_change_reason%type := 'ошибка пользователя';
  v_create_dtime_tech           payment.create_dtime_tech%type;
  v_update_dtime_tech           payment.update_dtime_tech%type;
begin
  payment_api_pack.cancel_payment( p_payment_id => v_payment_id
                                 , p_payment_cancel_reason => v_payment_cancel_reason
                                 );

  select p.create_dtime_tech
       , p.update_dtime_tech
  into v_create_dtime_tech
     , v_update_dtime_tech
  from payment p
  where p.payment_id = v_payment_id;

  if v_create_dtime_tech = v_update_dtime_tech then
    raise_application_error(-20998, 'Технические даты совпадают!');
  end if;
end;
/

-- Проверка "Успешное завершение платежа"
declare
  v_payment_id                  payment.payment_id%type := 41;
begin 
  payment_api_pack.successful_finish_payment(v_payment_id);
end;
/

-- Проверка "Добавление/обновление данных по платежу"
declare
  v_payment_id                  payment.payment_id%type := 41;

  v_payment_detail_data         t_payment_detail_array := t_payment_detail_array( t_payment_detail(1, 'Сайт банка XYZ')
                                                                                , t_payment_detail(3, 'Оплата за услуги связи')
                                                                                );
begin
  payment_detail_api_pack.insert_or_update_payment_detail( p_payment_id           => v_payment_id
                                                         , p_payment_detail_data  => v_payment_detail_data
                                                         );
end;
/

-- Проверка "Удаление делатей платежа"
declare
  v_payment_id                  payment.payment_id%type := 45;
  v_delete_payment_filelds      t_number_array := t_number_array(1, 2, 3);
begin
  payment_detail_api_pack.delete_payment_detail( p_payment_id             => v_payment_id
                                               , p_delete_payment_filelds => v_delete_payment_filelds
                                               );
end;
/
-- Удаление записи по платежу
declare
 v_payment_id    payment.payment_id%type := 45;
begin
  common_pack.enable_manual_changes();
  delete from payment p where p.payment_id = v_payment_id;
  common_pack.disable_manual_changes();
exception
  when others then
    common_pack.disable_manual_changes();
    raise;
end;
/

-- Проверка запрета на прямой DML PAYMENT_DETAIL(UPDATE)
declare
   v_payment_id                  payment_detail.payment_id%type := 45;
   v_field_id                    payment_detail.field_id%type := 1;
   v_field_value                 payment_detail.field_value%type := 'Мобильное приложение банка XYZ';
begin
  common_pack.enable_manual_changes();

  update payment_detail pd
  set pd.field_value = v_field_value
  where pd.payment_id = v_payment_id
    and pd.field_id = v_field_id;

  common_pack.disable_manual_changes();

exception
  when others then
    common_pack.disable_manual_changes();
    raise;
end;
/
-- Проверка запрета на прямой DML PAYMENT(UPDATE)
declare
   v_payment_id                  payment.payment_id%type := 45;
begin
  common_pack.enable_manual_changes();

  update payment p
  set p.status = payment_api_pack.c_status_success
  where p.payment_id = v_payment_id;

  common_pack.disable_manual_changes();

exception
  when others then
    common_pack.disable_manual_changes();
    raise;
end;
/



------ Негативные тесты
-- "Создание клиента": Пустая коллекия
declare
  v_payment_id                  payment.payment_id%type;
  v_payment_sum                 payment.summa%type := 100;
  v_currency_id                 payment.currency_id%type := 643;
  v_payment_from_client_id      payment.from_client_id%type := 1;
  v_payment_to_client_id        payment.to_client_id%type := 2;
  v_current_dtime               timestamp := systimestamp;

  v_payment_detail_data         t_payment_detail_array;

begin
  v_payment_id := payment_api_pack.create_payment( p_payment_from_client_id => v_payment_from_client_id
                                                 , p_payment_to_client_id   => v_payment_to_client_id
                                                 , p_payment_sum            => v_payment_sum
                                                 , p_currency_id            => v_currency_id
                                                 , p_payment_date           => v_current_dtime
                                                 , p_payment_detail_data    => v_payment_detail_data
                                                 );
  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_invalid_parameter then
    dbms_output.put_line('Создание клиента. Возбуждено исключение. Ошибка: '||sqlerrm);    
end;
/
-- "Создание клиенат": пустое значние поля (v_payment_sum)
declare
  v_payment_id                  payment.payment_id%type;
  v_payment_sum                 payment.summa%type;
  v_currency_id                 payment.currency_id%type := 643;
  v_payment_from_client_id      payment.from_client_id%type := 1;
  v_payment_to_client_id        payment.to_client_id%type := 2;
  v_current_dtime               timestamp := systimestamp;

  v_payment_detail_data         t_payment_detail_array := t_payment_detail_array( t_payment_detail(1, 'Мобильное приложение банка XYZ')
                                                                                , t_payment_detail(2, '192.168.1.1')
                                                                                , t_payment_detail(3, 'Оплата за услуги связи за сентябрь')
                                                                                );

begin
  v_payment_id := payment_api_pack.create_payment( p_payment_from_client_id => v_payment_from_client_id
                                                 , p_payment_to_client_id   => v_payment_to_client_id
                                                 , p_payment_sum            => v_payment_sum
                                                 , p_currency_id            => v_currency_id
                                                 , p_payment_date           => v_current_dtime
                                                 , p_payment_detail_data    => v_payment_detail_data
                                                 );
  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_invalid_parameter then
    dbms_output.put_line('Создание клиента. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- "Cброс платежа в ошибочный статус": пустой v_payment_id
declare
  v_payment_id                  payment.payment_id%type;
  v_payment_error_reason        payment.status_change_reason%type := 'недостаточно средств';
begin
  payment_api_pack.fail_payment( p_payment_id           => v_payment_id
                               , p_payment_error_reason => v_payment_error_reason
                               );
  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_invalid_parameter then
    dbms_output.put_line('Cброс платежа в ошибочный статус. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- "Cброс платежа в ошибочный статус": пустой v_payment_error_reason
declare
  v_payment_id                  payment.payment_id%type := 41;
  v_payment_error_reason        payment.status_change_reason%type;
begin
  payment_api_pack.fail_payment( p_payment_id           => v_payment_id
                               , p_payment_error_reason => v_payment_error_reason
                               );
  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_invalid_parameter then
    dbms_output.put_line('Cброс платежа в ошибочный статус. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- "Успешное завершение платежа": пустой v_payment_id
declare
  v_payment_id                  payment.payment_id%type;
begin 
  payment_api_pack.successful_finish_payment(v_payment_id);
  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_invalid_parameter then
    dbms_output.put_line('Успешное завершение платежа. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/

-- "Добавление/обновление данных по платежу": пустой v_payment_id
declare
  v_payment_id                  payment.payment_id%type;

  v_payment_detail_data         t_payment_detail_array := t_payment_detail_array( t_payment_detail(1, 'Сайт банка XYZ')
                                                                                , t_payment_detail(3, 'Оплата за услуги связи')
                                                                                );
begin
  payment_detail_api_pack.insert_or_update_payment_detail( p_payment_id           => v_payment_id
                                                         , p_payment_detail_data  => v_payment_detail_data
                                                         );
  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_invalid_parameter then
    dbms_output.put_line('Добавление/обновление данных по платежу. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- "Добавление/обновление данных по платежу": пустой v_payment_detail_data
declare
  v_payment_id                  payment.payment_id%type := 41;

  v_payment_detail_data         t_payment_detail_array;
begin
  payment_detail_api_pack.insert_or_update_payment_detail( p_payment_id           => v_payment_id
                                                         , p_payment_detail_data  => v_payment_detail_data
                                                         );
  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_invalid_parameter then
    dbms_output.put_line('Добавление/обновление данных по платежу. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- "Удаление делатей платежа": пустой v_payment_id
declare
  v_payment_id                  payment.payment_id%type;
  v_delete_payment_filelds      t_number_array := t_number_array(2, 3);
begin
  payment_detail_api_pack.delete_payment_detail( p_payment_id             => v_payment_id
                                               , p_delete_payment_filelds => v_delete_payment_filelds
                                               );
  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_invalid_parameter then
    dbms_output.put_line('Удаление делатей платежа. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- "Удаление делатей платежа": пустой v_delete_payment_filelds
declare
  v_payment_id                  payment.payment_id%type := 41;
  v_delete_payment_filelds      t_number_array;
begin
  payment_detail_api_pack.delete_payment_detail( p_payment_id             => v_payment_id
                                               , p_delete_payment_filelds => v_delete_payment_filelds
                                               );
  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_invalid_parameter then
    dbms_output.put_line('Удаление делатей платежа. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- Удаление записи по платежу
declare
 v_payment_id    payment.payment_id%type := 3;
begin
  delete from payment p where p.payment_id = v_payment_id;

  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_delete_forbidden then
    dbms_output.put_line('Удаление платежа. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- Проверка запрета на прямой DML PAYMENT(INSERT)
declare
  v_payment_id                  payment.payment_id%type := 3;
  v_payment_sum                 payment.summa%type := 100;
  v_currency_id                 payment.currency_id%type := 643;
  v_payment_from_client_id      payment.from_client_id%type := 1;
  v_payment_to_client_id        payment.to_client_id%type := 2;
  v_current_dtime               timestamp := systimestamp;
begin
  insert into payment
    ( payment_id
    , create_dtime
    , summa
    , currency_id
    , from_client_id
    , to_client_id
    , status
    )
  values
    ( v_payment_id
    , v_current_dtime
    , v_payment_sum
    , v_currency_id
    , v_payment_from_client_id
    , v_payment_to_client_id
    , payment_api_pack.с_status_create
    );

  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_payment_dml_disallow then
    dbms_output.put_line('Создание платежа. Прямой INSERT. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- Проверка запрета на прямой DML PAYMENT(UPDATE)
declare
   v_payment_id                  payment.payment_id%type := 3;
begin
  update payment p
  set p.status = payment_api_pack.c_status_success
  where p.payment_id = 3;

  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_payment_dml_disallow then
    dbms_output.put_line('Изменение платежа. Прямой UPDATE. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/

-- Проверка запрета на прямой DML PAYMENT_DETAIL(INSETR)
declare
   v_payment_id                  payment_detail.payment_id%type := 3;
   v_field_id                    payment_detail.field_id%type := 1;
   v_field_value                 payment_detail.field_value%type := 'Мобильное приложение банка XYZ';
begin
  insert into payment_detail
    ( payment_id
    , field_id
    , field_value
    )
  values
    ( v_payment_id
    , v_field_id
    , v_field_value
    );

  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_payment_detail_dml_disallow then
    dbms_output.put_line('Создание деталей платежа. Прямой INSERT. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- Проверка запрета на прямой DML PAYMENT_DETAIL(UPDATE)
declare
   v_payment_id                  payment_detail.payment_id%type := 3;
   v_field_id                    payment_detail.field_id%type := 1;
   v_field_value                 payment_detail.field_value%type := 'Мобильное приложение банка XYZ';
begin
  update payment_detail pd
  set pd.field_value = v_field_value
  where pd.payment_id = v_payment_id
    and pd.field_id = v_field_id;

  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_payment_detail_dml_disallow then
    dbms_output.put_line('Изменение деталей платежа. Прямой INSERT. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
-- Проверка запрета на прямой DML PAYMENT_DETAIL(UPDATE)
declare
   v_payment_id                  payment_detail.payment_id%type := 3;
   v_field_id                    payment_detail.field_id%type := 1;
   v_field_value                 payment_detail.field_value%type := 'Мобильное приложение банка XYZ';
begin
  delete payment_detail pd
  where pd.payment_id = v_payment_id
    and pd.field_id = v_field_id;

  raise_application_error(-20999, 'Unit-тест или API работают неккоректно');
exception
  when common_pack.e_payment_detail_dml_disallow then
    dbms_output.put_line('Удаление деталей платежа. Прямой DELETE. Возбуждено исключение. Ошибка: '||sqlerrm); 
end;
/
