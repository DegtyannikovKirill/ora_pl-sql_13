create or replace package body payment_detail_api_pack is

-- флажок на DML
g_payment_detail_dml_allowed boolean := false;

-- проверка на прямой DML
procedure check_payment_detail_dml_allowed is
begin
  if not(g_payment_detail_dml_allowed) and not common_pack.is_manual_changes_allowed() then
    raise_application_error( common_pack.c_error_code_payment_detail_dml_disallow
                           , common_pack.c_error_msg_payment_detail_dml_disallow
                           );
  end if;
end;

procedure allow_dml is
begin
  g_payment_detail_dml_allowed := true;
end allow_dml;

procedure disallow_dml is
begin
  g_payment_detail_dml_allowed := false;
end disallow_dml;

/*** 
* "Добавление/обновление данных по платежу"
* @param p_payment_id           - ID платежа
* @param p_payment_detail_data  - коллекция с деталями платежа
***/
procedure insert_or_update_payment_detail( p_payment_id              payment.payment_id%type
                                         , p_payment_detail_data     t_payment_detail_array
                                         )
is
  v_error_message                 varchar2(200 char);
  e_error_input_param             exception;
begin
  if p_payment_id is null then
    v_error_message := common_pack.c_error_msg_object_id_is_null;
    raise e_error_input_param;
  end if;

  if p_payment_detail_data is not empty then
    for rec in p_payment_detail_data.first .. p_payment_detail_data.last loop
      if p_payment_detail_data(rec).field_id is null then
        v_error_message := common_pack.c_error_msg_field_id_is_null;
        raise e_error_input_param;
      end if;

      if p_payment_detail_data(rec).field_value is null then
        v_error_message := common_pack.c_error_msg_field_valie_is_null;
        raise e_error_input_param;
      end if;
    end loop;
  else
    v_error_message := common_pack.c_error_msg_array_is_empty;
    raise e_error_input_param;
  end if;

  begin
    allow_dml;
  
    merge into payment_detail pd
    using ( select p_payment_id as payment_id
                 , value(v).field_id as field_id
                 , value(v).field_value as field_value
            from table(p_payment_detail_data) v ) v_arr
       on (pd.payment_id = v_arr.payment_id and pd.field_id = v_arr.field_id)
    when matched then
      update set pd.field_value = v_arr.field_value
    when not matched then
      insert (payment_id, field_id, field_value)
      values (v_arr.payment_id, v_arr.field_id, v_arr.field_value);

    disallow_dml;
  exception
    when others then
      disallow_dml;
      raise;
  end;

exception
  when e_error_input_param then
    raise_application_error(common_pack.c_error_code_invalid_parameter, v_error_message);
  when others then
    raise_application_error(-20001,'payment_detail_api_pack.insert_or_update_payment_detail: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace);
end insert_or_update_payment_detail;

/*** 
* "Удаление делатей платежа"
* @param p_payment_id              - ID платежа
* @param p_delete_payment_filelds  - массив из ID полей "детали платежа", которые надо удалить
***/
procedure delete_payment_detail( p_payment_id               payment.payment_id%type
                               , p_delete_payment_filelds   t_number_array
                               )
is
  v_error_message               varchar2(200 char);
  e_error_input_param           exception;
begin
  if p_payment_id is null then
    v_error_message := common_pack.c_error_msg_object_id_is_null;
    raise e_error_input_param;
  end if;

  if p_delete_payment_filelds is empty or p_delete_payment_filelds is null then
    v_error_message := common_pack.c_error_msg_array_is_empty;
    raise e_error_input_param;
  end if;

  begin
    allow_dml;
  
    delete payment_detail pd
    where pd.payment_id = p_payment_id
      and pd.field_id in ( select column_value 
                           from table(p_delete_payment_filelds));

    disallow_dml;
  exception
    when others then
      disallow_dml;
      raise;
  end;

exception
  when e_error_input_param then
    raise_application_error(common_pack.c_error_code_invalid_parameter, v_error_message);
  when others then
    raise_application_error(-20001,'payment_detail_api_pack.delete_payment_detail: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace);
end delete_payment_detail;

end payment_detail_api_pack ;
/
