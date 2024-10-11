-- Заготовка под тесты
select * from payment p where p.payment_id = 23
/
select * from payment_detail pd where pd.payment_id = 23
/

-- Проверка "Создание клиенат"
declare
  v_payment_id                  payment.payment_id%type;
  v_payment_sum                 payment.summa%type := 100;
  v_currency_id                 payment.currency_id%type := 643;
  v_payment_from_client_id      payment.from_client_id%type := 1;
  v_payment_to_client_id        payment.to_client_id%type := 2;

  v_payment_detail_data         t_payment_detail_array := t_payment_detail_array( t_payment_detail(1, 'Мобильное приложение банка XYZ')
                                                                                , t_payment_detail(2, '192.168.1.1')
                                                                                , t_payment_detail(3, 'Оплата за услуги связи за сентябрь')
                                                                                );

begin
  v_payment_id := create_payment( p_payment_from_client_id => v_payment_from_client_id
                                , p_payment_to_client_id   => v_payment_to_client_id
                                , p_payment_sum            => v_payment_sum
                                , p_currency_id            => v_currency_id
                                , p_payment_detail_data    => v_payment_detail_data
                                );
  dbms_output.put_line('v_payment_id: '|| v_payment_id);
end;
/

-- Проверка "Cброс платежа в ошибочный статус"
declare
  v_payment_id                  payment.payment_id%type := 23;
  v_payment_error_reason        payment.status_change_reason%type := 'недостаточно средств';
begin
  fail_payment( p_payment_id           => v_payment_id
              , p_payment_error_reason => v_payment_error_reason
              );
end;
/
-- Проверка "Отмена платежа"
declare
  v_payment_id                  payment.payment_id%type := 23;
  v_payment_cancel_reason       payment.status_change_reason%type := 'ошибка пользователя';
begin
  cancel_payment( p_payment_id => v_payment_id
                , p_payment_cancel_reason => v_payment_cancel_reason
                );
end;
/

-- Проверка "Успешное завершение платежа"
declare
  v_payment_id                  payment.payment_id%type := 23;
begin 
  successful_finish_payment(v_payment_id);
end;
/

-- Проверка "Добавление/обновление данных по платежу"
declare
  v_payment_id                  payment.payment_id%type := 23;

  v_payment_detail_data         t_payment_detail_array := t_payment_detail_array( t_payment_detail(1, 'Сайт банка XYZ')
                                                                                , t_payment_detail(3, 'Оплата за услуги связи')
                                                                                );
begin
  insert_or_update_payment_detail( p_payment_id           => v_payment_id
                                 , p_payment_detail_data  => v_payment_detail_data
                                 );
end;
/

-- Проверка "Удаление делатей платежа"
declare
  v_payment_id                  payment.payment_id%type := 23;
  v_delete_payment_filelds      t_number_array := t_number_array(2,3);
begin
  delete_payment_detail( p_payment_id             => v_payment_id
                       , p_delete_payment_filelds => v_delete_payment_filelds
                       );
end;
