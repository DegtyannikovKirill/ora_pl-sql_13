create or replace package body ut_payment_detail_api_pack is

-- Создание платежа. Проверка значений в таблице payment_detail
procedure create_payment_check_payment_detail_filds is
  v_compare_payment_detail t_payment_detail_array;
begin

  ut_payment_api_pack.create_payment_on_global_parameters;

  v_compare_payment_detail := ut_common_payment_pack.get_payment_datail_data(ut_payment_api_pack.g_payment_info.payment_id);
  
  for rec in (select t1.field_value as before_value, t2.field_value as after_value
              from table(ut_payment_api_pack.g_payment_info.payment_detail_data) t1
                 , table(v_compare_payment_detail) t2
              where t1.field_id = t2.field_id )
  loop
    ut.expect( rec.before_value, 'Детали платежа не совпадают').to_equal(rec.after_value);
  end loop;

end create_payment_check_payment_detail_filds;

-- Добавление/обновление данных по платежу. Проверка, что поля обновились
procedure update_payment_detail_check_field_value is
  v_payment_id             payment.payment_id%type := ut_payment_api_pack.g_payment_info.payment_id;
  v_payment_detail_before  t_payment_detail_array;
  v_payment_detail_after   t_payment_detail_array;  

begin

  v_payment_detail_before := ut_common_payment_pack.get_payment_datail_data(v_payment_id);

  payment_detail_api_pack.insert_or_update_payment_detail( p_payment_id           => v_payment_id
                                                         , p_payment_detail_data  => ut_common_payment_pack.get_random_payment_detail_data(0)
                                                         );

  v_payment_detail_after := ut_common_payment_pack.get_payment_datail_data(v_payment_id);

  for rec in (select t1.field_value as before_value, t2.field_value as after_value
              from table(v_payment_detail_before) t1
                 , table(v_payment_detail_after) t2
              where t1.field_id = t2.field_id )
  loop
    ut.expect(rec.before_value, 'Детали платежа не обновились').not_to_equal(rec.after_value);
  end loop;

end update_payment_detail_check_field_value;

-- Создание платежа. Создание с пустыми деталями платежа
procedure create_payment_empty_payment_detail is

begin
  ut_payment_api_pack.g_payment_info.payment_detail_data := t_payment_detail_array();
  ut_payment_api_pack.create_payment_on_global_parameters;

end create_payment_empty_payment_detail;

-- Добавление/обновление данных по платежу. Создание с пустым payment_id
procedure update_payment_detail_empty_payment_id is
begin
  payment_detail_api_pack.insert_or_update_payment_detail( p_payment_id           => null
                                                         , p_payment_detail_data  => ut_common_payment_pack.get_random_payment_detail_data(1)
                                                         );
end update_payment_detail_empty_payment_id;

procedure setup_random_payment_detail_data is
begin
  ut_payment_api_pack.g_payment_info.payment_detail_data := ut_common_payment_pack.get_random_payment_detail_data(1);
end setup_random_payment_detail_data;

end ut_payment_detail_api_pack;
/
