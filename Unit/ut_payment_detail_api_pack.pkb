create or replace package body ut_payment_detail_api_pack is

procedure create_payment_check_payment_detail_filds is
  v_payment_id                  payment.payment_id%type;
  v_compare_payment_detail      t_payment_detail_array;
  v_payment_detail_data         t_payment_detail_array;
begin
  v_payment_detail_data := ut_common_payment_pack.get_random_payment_detail_data();
  v_payment_id := ut_common_payment_pack.create_default_payment(v_payment_detail_data);

  v_compare_payment_detail := ut_common_payment_pack.get_payment_datail_data(v_payment_id);
  -- проверка правильного заполнения полей
  if v_compare_payment_detail.count != v_payment_detail_data.count then
    ut_common_pack.ut_failed();
  else
    for rec in(
      select field_id, field_value from table(v_compare_payment_detail)
      minus
      select field_id, field_value from table(v_payment_detail_data))
    loop
      ut_common_pack.ut_failed();
    end loop;
  end if;
end create_payment_check_payment_detail_filds;

procedure update_payment_detail_check_field_value is
  v_payment_id             payment.payment_id%type;
  v_payment_detail_after   t_payment_detail_array;
  v_payment_detail         t_payment_detail_array;
  
  v_count_not_matched_rows integer;
begin
  v_payment_id := ut_common_payment_pack.create_default_payment;

  v_payment_detail := ut_common_payment_pack.get_random_payment_detail_data();

  payment_detail_api_pack.insert_or_update_payment_detail( p_payment_id           => v_payment_id
                                                         , p_payment_detail_data  => v_payment_detail
                                                         );

  v_payment_detail_after := ut_common_payment_pack.get_payment_datail_data(v_payment_id);

  begin
    select count(1)
    into v_count_not_matched_rows
    from table(v_payment_detail) t1
       , table(v_payment_detail_after) t2
    where t1.field_id = t2.field_id
      and t1.field_value != t2.field_value;
  exception
    when no_data_found then
      v_count_not_matched_rows := 0;
  end;
  
  if v_count_not_matched_rows > 0 then
   ut_common_pack.ut_failed();
  end if;

end update_payment_detail_check_field_value;

/***************************************************************************
**************************    Негативные кейсы     *************************
****************************************************************************/

procedure create_payment_empty_payment_detail is

  v_payment_id                  payment.payment_id%type;
  v_payment_sum                 payment.summa%type;
  v_currency_id                 payment.currency_id%type;
  v_payment_from_client_id      payment.from_client_id%type;
  v_payment_to_client_id        payment.to_client_id%type;
  v_current_dtime               timestamp := systimestamp;

  v_payment_detail_data         t_payment_detail_array;

begin
  v_payment_from_client_id := ut_common_client_pack.create_default_client();
  v_payment_to_client_id := ut_common_client_pack.create_default_client();
  v_payment_sum := ut_common_payment_pack.get_random_payment_sum();
  v_currency_id := ut_common_payment_pack.get_random_currency();
  v_payment_detail_data := t_payment_detail_array();

  v_payment_id := payment_api_pack.create_payment( p_payment_from_client_id => v_payment_from_client_id
                                                 , p_payment_to_client_id   => v_payment_to_client_id
                                                 , p_payment_sum            => v_payment_sum
                                                 , p_currency_id            => v_currency_id
                                                 , p_payment_date           => v_current_dtime
                                                 , p_payment_detail_data    => v_payment_detail_data
                                                 );
  ut_common_pack.ut_failed();
exception
  when common_pack.e_invalid_parameter then
    null;
end create_payment_empty_payment_detail;

end ut_payment_detail_api_pack;
/
