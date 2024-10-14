create or replace package body payment_detail_api_pack is

/*** 
* "Добавление/обновление данных по платежу"
* @param p_payment_id           - ID платежа
* @param p_payment_detail_data  - коллекция с деталями платежа
***/
procedure insert_or_update_payment_detail( p_payment_id              payment.payment_id%type
                                         , p_payment_detail_data     t_payment_detail_array
                                         )
is
  v_current_dtime                 timestamp := systimestamp;
begin
  if p_payment_id is null then
    dbms_output.put_line(payment_api_pack.c_object_id_is_null);
  end if;

  if p_payment_detail_data is not empty then
    for rec in p_payment_detail_data.first .. p_payment_detail_data.last loop
      if p_payment_detail_data(rec).field_id is null then
        dbms_output.put_line(payment_api_pack.c_field_id_is_null);
      end if;

      if p_payment_detail_data(rec).field_value is null then
        dbms_output.put_line(payment_api_pack.c_field_valie_is_null);
      end if;
    end loop;
  else
    dbms_output.put_line(payment_api_pack.c_array_is_empty);
  end if;

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

  dbms_output.put_line(c_update_discription||' по списку id_поля/значение. Payment_id: '||p_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'hh24:mi:ss.ff'));

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
  v_current_dtime               timestamp := systimestamp;
begin
  if p_payment_id is null then
    dbms_output.put_line(payment_api_pack.c_object_id_is_null);
  end if;

  if p_delete_payment_filelds is empty or p_delete_payment_filelds is null then
    dbms_output.put_line(payment_api_pack.c_array_is_empty);
  end if;

  delete payment_detail pd
  where pd.payment_id = p_payment_id
    and pd.field_id in ( select column_value 
                         from table(p_delete_payment_filelds));

  dbms_output.put_line(c_delete_discription||' по списку id_полей. Payment_id: '||p_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'yyyy-mm-dd hh24:mi:ss.ff9'));
  dbms_output.put_line('Колличество удаляемых полей: '||p_delete_payment_filelds.count);

end delete_payment_detail;

end payment_detail_api_pack ;
/
