/*
* Автор: Дегтянников К.А.
* Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
*/
-- Создание платежа
declare
  c_payment_create_discription constant varchar2(200 char) := 'Платеж создан';
  с_payment_create_status constant payment.status%type := 0;
  v_current_dtime date := sysdate;
  v_payment_id payment.payment_id%type;
  v_payment_detail_data t_payment_detail_array := t_payment_detail_array( t_payment_detail(1, 'Мобильное приложение банка XYZ')
                                                                        , t_payment_detail(2, '192.168.1.1')
                                                                        , t_payment_detail(3, 'Оплата за услуги связи за сентябрь')
                                                                        );
begin
  dbms_output.put_line(c_payment_create_discription||'. Статус: '||с_payment_create_status||'. Payment_id: '||v_payment_id);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy'));
end;
/
-- Ошибка проведения платежа
declare
  c_payment_error_discription constant varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  с_payment_error_status constant payment.status%type := 2;
  v_payment_error_reason payment.status_change_reason%type := 'недостаточно средств';
  v_current_dtime date := sysdate;
  v_payment_id payment.payment_id%type;
begin
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  end if;

  if v_payment_error_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  end if;

  dbms_output.put_line(c_payment_error_discription||' Статус: '||с_payment_error_status||'. Причина: '||v_payment_error_reason||'. Payment_id: '||v_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi'));
end;
/
-- Отмена платежа
declare
  c_payment_cancel_discription constant varchar2(200 char) := 'Отмена платежа с указанием причины.';
  с_payment_cancel_status constant payment.status%type := 3;
  v_payment_cancel_reason payment.status_change_reason%type := 'ошибка пользователя';
  v_current_dtime date := sysdate;
  v_payment_id payment.payment_id%type := 1;
begin
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  end if;

  if v_payment_cancel_reason is null then
    dbms_output.put_line('Причина не может быть пустой');
  end if;

  dbms_output.put_line(c_payment_cancel_discription||' Статус: '||с_payment_cancel_status||'. Причина: '||v_payment_cancel_reason||'. Payment_id: '||v_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));
end;
/
-- Успешное завершение платежа
declare
  c_payment_success_discription constant varchar2(200 char) := 'Успешное завершение платежа';
  c_payment_success_status constant payment.status%type := 1;
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type := 2;
begin
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  end if;

  dbms_output.put_line(c_payment_success_discription||'. Статус: '||c_payment_success_status||'. Payment_id: '||v_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'DD Mon YYYY'));
end;
/
-- Добавление/обновление данных по платежу 
declare
  c_payment_update_discription constant varchar2(200 char) := 'Данные платежа добавлены или обновлены';
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type := 3;
  v_payment_detail_data t_payment_detail_array := t_payment_detail_array( t_payment_detail(1, 'Сайт банка XYZ')
                                                                        , t_payment_detail(3, 'Оплата за услуги связи')
                                                                        );
begin
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  end if;

  dbms_output.put_line(c_payment_update_discription||' по списку id_поля/значение. Payment_id: '||v_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'hh24:mi:ss.ff'));
end;
/
-- Удаление делатей платежа
declare
  c_payment_delete_discription constant varchar2(200 char) := 'Детали платежа удалены';
  v_current_dtime timestamp := systimestamp;
  v_payment_id payment.payment_id%type := 4;
  v_delete_payment_filelds t_number_array := t_number_array(1,4);
begin
  if v_payment_id is null then
    dbms_output.put_line('ID объекта не может быть пустым');
  end if;

  dbms_output.put_line(c_payment_delete_discription||' по списку id_полей. Payment_id: '||v_payment_id);
  dbms_output.put_line(to_char(v_current_dtime, 'yyyy-mm-dd hh24:mi:ss.ff9'));
end;
/
