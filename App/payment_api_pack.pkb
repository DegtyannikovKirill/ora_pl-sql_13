create or replace package body payment_api_pack  is

/*** 
* "Создание платежа"
* @param p_payment_from_client_id - ОТ КАКОГО клиента платеж
* @param p_payment_to_client_id   - КАКОМУ клиенту плаатеж
* @param p_payment_sum            - сумма платежа
* @param p_currency_id            - валюта
* @param p_payment_detail_data    - коллекция с деталями платежа
* 
* @return NUMBER                  - ID созданного платежа
***/
function create_payment( p_payment_from_client_id   payment.from_client_id%type
                       , p_payment_to_client_id     payment.to_client_id%type
                       , p_payment_sum              payment.summa%type
                       , p_currency_id              payment.currency_id%type
                       , p_payment_date             timestamp
                       , p_payment_detail_data      t_payment_detail_array
                       )
return payment.payment_id%type
is
  c_discription_create          constant varchar2(200 char) := 'Платеж создан';
  v_payment_id                  payment.payment_id%type;
  v_error_message               varchar2(200 char);
  e_error_input_param           exception;

begin
  -- проверка входных паарметров
  if p_payment_from_client_id is null 
    or p_payment_to_client_id is null
    or p_payment_sum is null
    or p_currency_id is null
    or p_payment_date is null
  then
    v_error_message := c_object_value_is_null;
    raise e_error_input_param;
  end if;

  if p_payment_detail_data is not empty then
    for rec in p_payment_detail_data.first .. p_payment_detail_data.last loop
      if p_payment_detail_data(rec).field_id is null then
        v_error_message := c_field_id_is_null;
        raise e_error_input_param;
      end if;

      if p_payment_detail_data(rec).field_value is null then
        v_error_message := c_field_valie_is_null;
        raise e_error_input_param;
      end if;

    end loop;
  else
    v_error_message := c_array_is_empty;
    raise e_error_input_param;
  end if;

  -- создание платежа
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
    ( payment_seq.nextval
    , p_payment_date
    , p_payment_sum
    , p_currency_id
    , p_payment_from_client_id
    , p_payment_to_client_id
    , с_status_create
    )
  returning payment_id into v_payment_id;

  -- создание деталей платежа
  insert into payment_detail
    ( payment_id
    , field_id
    , field_value
    )
  select v_payment_id
       , value(t).field_id
       , value(t).field_value
  from table(p_payment_detail_data) t;

  dbms_output.put_line(c_discription_create||'. Статус: '||с_status_create||'. Payment_id: '||v_payment_id);
  dbms_output.put_line(to_char(p_payment_date,'dd.mm.yyyy'));

  return v_payment_id;

exception
  when e_error_input_param then
    raise_application_error(c_error_code_invalid_parameter, v_error_message);
  when others then
    raise_application_error(-20001,'payment_api_pack.create_payment: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace);
end create_payment;

/*** 
* "Успешное завершение платежа"
* @param p_payment_id  - ID платежа
***/
procedure successful_finish_payment(p_payment_id payment.payment_id%type)
is
  c_discription_success           constant varchar2(200 char) := 'Успешное завершение платежа';
  v_current_dtime                 timestamp := systimestamp;
  v_error_message                 varchar2(200 char);
  e_error_input_param             exception;
begin
  if p_payment_id is null then
    v_error_message := c_object_id_is_null;
    raise e_error_input_param;
  end if;

  update payment p
  set p.status = c_status_success
    , p.status_change_reason = null
  where p.payment_id = p_payment_id
    and p.status = с_status_create;

  dbms_output.put_line(c_discription_success||'. Статус: '||c_status_success||'. Payment_id: '||p_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'DD Mon YYYY'));
exception
  when e_error_input_param then
    raise_application_error(c_error_code_invalid_parameter, v_error_message);
  when others then
    raise_application_error(-20001,'payment_api_pack.successful_finish_payment: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace);
end successful_finish_payment;

/*** 
* "сброс платежа в ошибочный статус"
* @param p_payment_id             - ID платежа
* @param p_payment_error_reason   - Причина перевода в ошибочный статус
***/
procedure fail_payment( p_payment_id            payment.payment_id%type
                      , p_payment_error_reason  payment.status_change_reason%type
                      )
is
  c_discription_error           constant varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  v_current_dtime               date := sysdate;
  v_error_message               varchar2(200 char);
  e_error_input_param           exception;
begin
  if p_payment_id is null then
    v_error_message := c_object_id_is_null;
    raise e_error_input_param;
  end if;

  if p_payment_error_reason is null then
    v_error_message := c_payment_reason_is_null;
    raise e_error_input_param;
  end if;

  update payment p
  set p.status = с_status_error
    , p.status_change_reason = p_payment_error_reason
  where p.payment_id = p_payment_id
    and p.status = с_status_create;

  dbms_output.put_line(c_discription_error||' Статус: '||с_status_error||'. Причина: '||p_payment_error_reason||'. Payment_id: '||p_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi'));
exception
  when e_error_input_param then
    raise_application_error(c_error_code_invalid_parameter, v_error_message);
  when others then
    raise_application_error(-20001,'payment_api_pack.fail_payment: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace);
end fail_payment;

/*** 
* "Отмена платежа"
* @param p_payment_id              - ID платежа
* @param p_payment_cancel_reason   - Причина отмены платежа
***/
procedure cancel_payment( p_payment_id              payment.payment_id%type
                        , p_payment_cancel_reason   payment.status_change_reason%type
                        )
is
  c_discription_cancel           constant varchar2(200 char) := 'Отмена платежа с указанием причины.';
  v_current_dtime                date := sysdate;
  v_error_message                varchar2(200 char);
  e_error_input_param            exception;
begin
  if p_payment_id is null then
    v_error_message := c_object_id_is_null;
    raise e_error_input_param;
  end if;

  if p_payment_cancel_reason is null then
    v_error_message := c_payment_reason_is_null;
    raise e_error_input_param;
  end if;

  update payment p
  set p.status = с_status_cancel
    , p.status_change_reason = p_payment_cancel_reason
  where p.payment_id = p_payment_id
    and p.status = с_status_create;

  dbms_output.put_line(c_discription_cancel||' Статус: '||с_status_cancel||'. Причина: '||p_payment_cancel_reason||'. Payment_id: '||p_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));
exception
  when e_error_input_param then
    raise_application_error(c_error_code_invalid_parameter, v_error_message);
  when others then
    raise_application_error(-20001,'payment_api_pack.cancel_payment: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace);
end cancel_payment;

end payment_api_pack ;
/
