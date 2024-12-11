create or replace package body ut_common_payment_pack is
  
  type payment_field_value_array is table of varchar2(200 char);

  function get_random_payment_sum return payment.summa%type is
  begin
    return round(dbms_random.value(0, 100000), 2);
  end get_random_payment_sum;

  function get_random_currency return payment.currency_id%type is
    v_random_currency_id payment.currency_id%type;
  begin
    select max(currency_id)
    into v_random_currency_id 
    from (select c.currency_id
          from currency c
          order by dbms_random.value) 
     where rownum = 1;

     return v_random_currency_id;
  end get_random_currency;

  function get_random_software return payment_detail.field_value%type
  is
    t_platform_array payment_field_value_array;
    v_random_index number;
  begin
    t_platform_array := payment_field_value_array('Android', 'iOS', 'Windows', 'Linux', 'Web', 'MacOS', 'BlackBerry', 'Windows Phone', 'Smart TV', 'Game Console');
    
    v_random_index := trunc(dbms_random.value(1, t_platform_array.count + 1));
    
    return t_platform_array(v_random_index);
  end get_random_software;

  function get_random_ip return payment_detail.field_value%type
  is
    v_ip payment_detail.field_value%type;
  begin
    v_ip :=  trunc(dbms_random.value(0, 256))||'.'||
             trunc(dbms_random.value(0, 256))||'.'||
             trunc(dbms_random.value(0, 256))||'.'||
             trunc(dbms_random.value(0, 256));

    return v_ip;
  end get_random_ip;

  procedure get_random_strings(p_count_word number, result_string in out varchar2)
  is
  begin
    if p_count_word > 0 then
      for rec in 1 .. p_count_word loop
        result_string := result_string||dbms_random.string('a', trunc(dbms_random.value(5, 10)))||' ';
      end loop;
    end if;
  end;

  function get_random_note return payment_detail.field_value%type
  is
    v_note payment_detail.field_value%type;
  begin
    get_random_strings(trunc(dbms_random.value(1, 15)), v_note);
    return v_note;
  end get_random_note;
  
  function get_random_fraud return payment_detail.field_value%type
  is 
  begin
    return to_char(round(dbms_random.value(0, 1)));
  end get_random_fraud;

 function get_random_payment_detail_data return t_payment_detail_array is
    t_payment_detail_data t_payment_detail_array;
  begin
    t_payment_detail_data := t_payment_detail_array( t_payment_detail(c_detail_client_software, get_random_software())
                                                   , t_payment_detail(c_detail_ip, get_random_ip())
                                                   , t_payment_detail(c_detail_note, get_random_note())
                                                   , t_payment_detail(c_detail_is_checked_fraud, get_random_fraud())
                                                   );

    return t_payment_detail_data;
  end get_random_payment_detail_data;

  function get_payment_data(p_payment payment.payment_id%type) return payment%rowtype is
    v_payment_data payment%rowtype;
  begin
    begin
      select *
      into v_payment_data
      from payment
      where payment_id = p_payment;
    exception
      when no_data_found then
        v_payment_data := null;
    end;

    return v_payment_data;
  end get_payment_data;

  function get_payment_datail_data(p_payment payment.payment_id%type) return t_payment_detail_array is
    t_payment_detail_data t_payment_detail_array;
  begin
    select t_payment_detail(pd.field_id, pd.field_value)
    bulk collect into t_payment_detail_data
    from payment_detail pd
    where pd.payment_id = p_payment;

    return t_payment_detail_data;
  end get_payment_datail_data; 

  function get_random_reason return payment.status_change_reason%type is
    v_reason payment.status_change_reason%type;
  begin
    get_random_strings(trunc(dbms_random.value(1, 25)), v_reason);

    return v_reason;
  end get_random_reason;
  
  function create_default_payment(p_payment_detail_data t_payment_detail_array := t_payment_detail_array()) return payment.payment_id%type is
    v_payment_id                  payment.payment_id%type;
    v_payment_sum                 payment.summa%type;
    v_currency_id                 payment.currency_id%type;
    v_payment_from_client_id      payment.from_client_id%type;
    v_payment_to_client_id        payment.to_client_id%type;
    v_current_dtime               timestamp := systimestamp;
    v_payment_detail_data         t_payment_detail_array;
  begin
    --setup
    v_payment_from_client_id := ut_common_client_pack.create_default_client();
    v_payment_to_client_id := ut_common_client_pack.create_default_client();
    v_payment_sum := get_random_payment_sum();
    v_currency_id := get_random_currency();

    if p_payment_detail_data is not empty then
      v_payment_detail_data := p_payment_detail_data;
    else
      v_payment_detail_data := get_random_payment_detail_data();
    end if;

    v_payment_id := payment_api_pack.create_payment( p_payment_from_client_id => v_payment_from_client_id
                                                   , p_payment_to_client_id   => v_payment_to_client_id
                                                   , p_payment_sum            => v_payment_sum
                                                   , p_currency_id            => v_currency_id
                                                   , p_payment_date           => v_current_dtime
                                                   , p_payment_detail_data    => v_payment_detail_data
                                                   );

    return v_payment_id;
  end create_default_payment;

end ut_common_payment_pack;
/
