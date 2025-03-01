create or replace package body payment_api_pack  is

-- флажок на DML
g_payment_dml_allowed boolean := false;

-- проверка на прямой DML
procedure check_payment_dml_allowed is
begin
  if not(g_payment_dml_allowed) and not common_pack.is_manual_changes_allowed() then
    raise_application_error( common_pack.c_error_code_payment_dml_disallow
                           , common_pack.c_error_msg_payment_dml_disallow);
  end if;
end;

procedure allow_dml is
begin
  g_payment_dml_allowed := true;
end allow_dml;

procedure disallow_dml is
begin
  g_payment_dml_allowed := false;
end disallow_dml;


-- проверка на возможность удаления данных
procedure check_payment_delete
is
begin
  if not common_pack.is_manual_changes_allowed() then
    raise_application_error( common_pack.c_error_code_delete_forbidden
                       , common_pack.c_error_msg_delete_forbidden);
  end if;

end;

-- блокировка объекта "платеж"
procedure try_lock_payment(p_payment_id payment.payment_id%type)
is
  v_payment_status payment.status%type;
  e_inactive_state  exception;
begin

  select t.status
  into v_payment_status
  from payment t 
  where t.payment_id = p_payment_id
  for update nowait;

  -- платеж уже в финальном статусе
  if v_payment_status <> с_status_create then
    raise e_inactive_state;
  end if;

exception
  when e_inactive_state then
    raise_application_error(common_pack.c_error_code_inactive_object_state, common_pack.c_error_msg_inactive_object_state);
  when no_data_found then
    raise_application_error(common_pack.c_error_code_object_notfound, common_pack.c_error_msg_object_notfound);
  when common_pack.e_row_locked then
    raise_application_error(common_pack.c_error_code_object_locked, common_pack.c_error_msg_object_locked);
  when others then
    raise_application_error(-20001,'payment_api_pack.try_lock_payment: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace);
end try_lock_payment;

/*** 
* "Создание платежа"
* @param p_payment_from_client_id - ОТ КАКОГО клиента платеж
* @param p_payment_to_client_id   - КАКОМУ клиенту плаатеж
* @param p_payment_sum            - сумма платежа
* @param p_currency_id            - валюта
* @param p_payment_date           - время занесения платежа
* @param p_payment_detail_data    - коллекция с деталями платежа
* 
* @return NUMBER                  - ID созданного платежа
***/
function create_payment( p_payment_from_client_id   payment.from_client_id%type
                       , p_payment_to_client_id     payment.to_client_id%type
                       , p_payment_sum              payment.summa%type
                       , p_currency_id              payment.currency_id%type
                       , p_payment_date             payment.create_dtime%type
                       , p_payment_detail_data      t_payment_detail_array
                       )
return payment.payment_id%type
is
  v_payment_id                  payment.payment_id%type;
begin
  -- проверка входных паарметров
  if p_payment_from_client_id is null 
    or p_payment_to_client_id is null
    or p_payment_sum is null
    or p_currency_id is null
    or p_payment_date is null
  then
    raise_application_error(common_pack.c_error_code_invalid_parameter, common_pack.c_error_msg_object_value_is_null);
  end if;


  allow_dml;
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

  disallow_dml;

  -- создание деталей платежа
  payment_detail_api_pack.insert_or_update_payment_detail( p_payment_id => v_payment_id
                                                         , p_payment_detail_data => p_payment_detail_data);

  return v_payment_id;

exception
  when others then
    disallow_dml;
    raise;
end create_payment;

/*** 
* "Успешное завершение платежа"
* @param p_payment_id  - ID платежа
***/
procedure successful_finish_payment(p_payment_id payment.payment_id%type)
is
begin
  if p_payment_id is null then
    raise_application_error(common_pack.c_error_code_invalid_parameter, common_pack.c_error_msg_object_id_is_null);
  end if;
  

  -- заблокируем платеж
  try_lock_payment(p_payment_id);
  
  allow_dml;

  update payment p
  set p.status = c_status_success
    , p.status_change_reason = null
  where p.payment_id = p_payment_id
    and p.status = с_status_create;

  disallow_dml;

exception
  when others then
    disallow_dml;
    raise;
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
begin

  if p_payment_id is null then
    raise_application_error( common_pack.c_error_code_invalid_parameter
                           , common_pack.c_error_msg_object_id_is_null );
  end if;

  if p_payment_error_reason is null then
    raise_application_error( common_pack.c_error_code_invalid_parameter
                           , common_pack.c_error_msg_payment_reason_is_null );
  end if;


  -- заблокируем платеж
  try_lock_payment(p_payment_id);
  
  allow_dml;

  update payment p
  set p.status = с_status_error
    , p.status_change_reason = p_payment_error_reason
  where p.payment_id = p_payment_id
    and p.status = с_status_create;

  disallow_dml;

exception
  when others then
    disallow_dml;
    raise;
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
begin
  if p_payment_id is null then
    raise_application_error( common_pack.c_error_code_invalid_parameter
                           , common_pack.c_error_msg_object_id_is_null );
  end if;

  if p_payment_cancel_reason is null then
    raise_application_error( common_pack.c_error_code_invalid_parameter
                           , common_pack.c_error_msg_payment_reason_is_null );
  end if;

  -- заблокируем платеж
  try_lock_payment(p_payment_id);
  
  allow_dml;

  update payment p
  set p.status = с_status_cancel
    , p.status_change_reason = p_payment_cancel_reason
  where p.payment_id = p_payment_id
    and p.status = с_status_create;

  disallow_dml;

exception
  when others then
    disallow_dml;
    raise;
end cancel_payment;

end payment_api_pack;
/
