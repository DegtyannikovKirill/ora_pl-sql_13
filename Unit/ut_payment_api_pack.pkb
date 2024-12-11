create or replace package body ut_payment_api_pack is

procedure create_payment_check_payment_filds is
  v_payment_id                  payment.payment_id%type;
  v_payment_sum                 payment.summa%type;
  v_currency_id                 payment.currency_id%type;
  v_payment_from_client_id      payment.from_client_id%type;
  v_payment_to_client_id        payment.to_client_id%type;
  v_current_dtime               timestamp := systimestamp;
  v_payment_detail_data         t_payment_detail_array;
  --
  v_compare_payment_data        payment%rowtype;

begin
  --setup
  v_payment_from_client_id := ut_common_client_pack.create_default_client();
  v_payment_to_client_id := ut_common_client_pack.create_default_client();
  v_payment_sum := ut_common_payment_pack.get_random_payment_sum();
  v_currency_id := ut_common_payment_pack.get_random_currency();
  v_payment_detail_data := ut_common_payment_pack.get_random_payment_detail_data();

  -- выполнение
  v_payment_id := payment_api_pack.create_payment( p_payment_from_client_id => v_payment_from_client_id
                                                 , p_payment_to_client_id   => v_payment_to_client_id
                                                 , p_payment_sum            => v_payment_sum
                                                 , p_currency_id            => v_currency_id
                                                 , p_payment_date           => v_current_dtime
                                                 , p_payment_detail_data    => v_payment_detail_data
                                                 );
  -- проверка результатов
  v_compare_payment_data := ut_common_payment_pack.get_payment_data(v_payment_id);
  -- проверка правильного заполнения полей
  if v_compare_payment_data.create_dtime != v_current_dtime
    or v_compare_payment_data.summa != v_payment_sum
    or v_compare_payment_data.currency_id != v_currency_id
    or v_compare_payment_data.from_client_id != v_payment_from_client_id
    or v_compare_payment_data.to_client_id != v_payment_to_client_id
    or v_compare_payment_data.status != payment_api_pack.с_status_create
    or v_compare_payment_data.status_change_reason is not null
  then
    ut_common_pack.ut_failed();
  end if;

end create_payment_check_payment_filds;

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

procedure create_payment_check_dtime_tech is
  v_payment_id                  payment.payment_id%type;
  v_compare_payment_data        payment%rowtype;
begin
  v_payment_id := ut_common_payment_pack.create_default_payment;

  v_compare_payment_data := ut_common_payment_pack.get_payment_data(v_payment_id);

  if v_compare_payment_data.create_dtime_tech != v_compare_payment_data.update_dtime_tech then
    ut_common_pack.ut_failed();
  end if;
end create_payment_check_dtime_tech;

procedure fail_payment_check_status_and_resons is
  v_payment_id                  payment.payment_id%type;
  v_compare_payment_data        payment%rowtype;
  v_payment_error_reason        payment.status_change_reason%type;
begin
  v_payment_id := ut_common_payment_pack.create_default_payment;
  v_payment_error_reason :=  ut_common_payment_pack.get_random_reason();
  -- выполнение
  payment_api_pack.fail_payment( p_payment_id           => v_payment_id
                               , p_payment_error_reason => v_payment_error_reason
                               );
  -- проверка результатов
  v_compare_payment_data := ut_common_payment_pack.get_payment_data(v_payment_id);

  if v_compare_payment_data.status_change_reason != v_payment_error_reason
    or v_compare_payment_data.status != payment_api_pack.с_status_error
  then
    ut_common_pack.ut_failed();
  end if;
end fail_payment_check_status_and_resons;

procedure fail_payment_check_dtime_tech is
  v_payment_id                  payment.payment_id%type;
  v_compare_payment_data        payment%rowtype;
  v_payment_error_reason        payment.status_change_reason%type;
begin
  v_payment_id := ut_common_payment_pack.create_default_payment;
  v_payment_error_reason :=  ut_common_payment_pack.get_random_reason();

  payment_api_pack.fail_payment( p_payment_id           => v_payment_id
                               , p_payment_error_reason => v_payment_error_reason
                               );

  v_compare_payment_data := ut_common_payment_pack.get_payment_data(v_payment_id);

  if v_compare_payment_data.create_dtime_tech = v_compare_payment_data.update_dtime_tech then
    ut_common_pack.ut_failed();
  end if;

end fail_payment_check_dtime_tech; 


procedure update_payment_detail_check_field_value is
  v_payment_id             payment.payment_id%type;
  v_payment_detail_before  t_payment_detail_array;
  v_payment_detail_after   t_payment_detail_array;
  v_payment_detail         t_payment_detail_array;
  
begin
  v_payment_id := ut_common_payment_pack.create_default_payment;
  v_payment_detail_before := ut_common_payment_pack.get_payment_datail_data(v_payment_id);  

  v_payment_detail := ut_common_payment_pack.get_random_payment_detail_data();

  payment_detail_api_pack.insert_or_update_payment_detail( p_payment_id           => v_payment_id
                                                         , p_payment_detail_data  => v_payment_detail
                                                         );

  v_payment_detail_after := ut_common_payment_pack.get_payment_datail_data(v_payment_id);

  -- тяжелый кейс, из-за MERGE однозначное не получится расписать. так что только UPDATE распишем
  for rec in ( 
    select t1.field_value as field_value_before, t2.field_value as field_value_after
    from table(v_payment_detail_before)t1
       , table(v_payment_detail_after) t2
    where t1.field_id = t2.field_id)
  loop
    if rec.field_value_before = rec.field_value_after then
       ut_common_pack.ut_failed();
    end if;
  end loop;
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

procedure create_payment_empty_payment_sum is
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
  v_payment_sum := null;
  v_currency_id := ut_common_payment_pack.get_random_currency();
  v_payment_detail_data := ut_common_payment_pack.get_random_payment_detail_data();

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
end create_payment_empty_payment_sum;

end ut_payment_api_pack;
/
