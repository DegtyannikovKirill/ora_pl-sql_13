create or replace package body ut_payment_api_pack is

procedure cleanap_g_data is
begin
  --dbms_output.put_line(g_payment_info.current_dtime||'  проверка =)');
  g_payment_info := null;
end;

procedure create_payment_on_global_parameters is
begin 
  -- выполнение
  g_payment_info.payment_id := payment_api_pack.create_payment( p_payment_from_client_id => g_payment_info.payment_from_client_id
                                                              , p_payment_to_client_id   => g_payment_info.payment_to_client_id
                                                              , p_payment_sum            => g_payment_info.payment_sum
                                                              , p_currency_id            => g_payment_info.currency_id
                                                              , p_payment_date           => g_payment_info.current_dtime
                                                              , p_payment_detail_data    => g_payment_info.payment_detail_data
                                                              );

  
end create_payment_on_global_parameters;

--Создание платежа. Проверка значений в таблице payment
procedure create_payment_check_payment_filds is  
  v_compare_payment_data        payment%rowtype;
begin
  create_payment_on_global_parameters;

  v_compare_payment_data := ut_common_payment_pack.get_payment_data(g_payment_info.payment_id);

  -- проверка результатов
  ut.expect( v_compare_payment_data.create_dtime, 'Дата создания платежа не совпадает').to_equal(g_payment_info.current_dtime);
  ut.expect( v_compare_payment_data.summa, 'Сумма платежа не совпадает').to_equal(g_payment_info.payment_sum);
  ut.expect( v_compare_payment_data.currency_id, 'Валюта платежа не совпадает').to_equal(g_payment_info.currency_id);
  ut.expect( v_compare_payment_data.from_client_id, 'Клиент С которого был платеж не совпадает').to_equal(g_payment_info.payment_from_client_id);
  ut.expect( v_compare_payment_data.to_client_id, 'Клиент К которому был платеж не совпадает').to_equal(g_payment_info.payment_to_client_id);
  ut.expect( v_compare_payment_data.status, 'Статус платежа не совпадает').to_equal(payment_api_pack.с_status_create);
  ut.expect( v_compare_payment_data.status_change_reason, 'Дата создания платежа не совпадает').to_be_null;
  ut.expect( v_compare_payment_data.create_dtime_tech, 'Технические поля не совпадают').to_equal(v_compare_payment_data.update_dtime_tech);

end create_payment_check_payment_filds;

-- Перевод платежа в статус "ошибочный". Проверка статуса, причины и тех.даты
procedure fail_payment_check_status_and_resons is
  v_compare_payment_data        payment%rowtype;
begin

  payment_api_pack.fail_payment( p_payment_id           => g_payment_info.payment_id
                               , p_payment_error_reason => g_payment_info.payment_reason
                               );
  -- проверка результатов
  v_compare_payment_data := ut_common_payment_pack.get_payment_data(g_payment_info.payment_id);

  ut.expect( v_compare_payment_data.status_change_reason, 'Причины изменения статуса не совпадают').to_equal(g_payment_info.payment_reason);
  ut.expect( v_compare_payment_data.status, 'Не соответсвующий статус').to_equal(payment_api_pack.с_status_error);
  ut.expect( v_compare_payment_data.create_dtime_tech, 'Технические поля совпадают').not_to_equal(v_compare_payment_data.update_dtime_tech);

end fail_payment_check_status_and_resons;

-- Создание платежа. Создание с пустым значением "payment_sum"
procedure create_payment_empty_payment_sum is
begin
  g_payment_info.payment_sum := null;

  create_payment_on_global_parameters;

end create_payment_empty_payment_sum;

-- Перевод платежа в статус "ошибочный". Создание с пустым значением "payment_id"
procedure fail_payment_empty_payment_id is
begin
  payment_api_pack.fail_payment( p_payment_id           => null
                               , p_payment_error_reason => g_payment_info.payment_reason
                               );
end fail_payment_empty_payment_id;


/***************************************************************************
**************************    Служебные функции     *************************
****************************************************************************/

procedure setup_random_payment_reason is
begin
  g_payment_info.payment_reason := ut_common_payment_pack.get_random_reason();
end setup_random_payment_reason;

procedure setup_random_data_for_payment is
begin
  g_payment_info.payment_from_client_id := ut_common_client_pack.create_default_client();
  g_payment_info.payment_to_client_id := ut_common_client_pack.create_default_client();
  g_payment_info.payment_sum := ut_common_payment_pack.get_random_payment_sum();
  g_payment_info.currency_id := ut_common_payment_pack.get_random_currency();
  g_payment_info.current_dtime := systimestamp;
end setup_random_data_for_payment;

procedure setup_random_data_for_payment_detail is
begin
  g_payment_info.payment_detail_data := ut_common_payment_pack.get_random_payment_detail_data();
end setup_random_data_for_payment_detail; 

end ut_payment_api_pack;
/
