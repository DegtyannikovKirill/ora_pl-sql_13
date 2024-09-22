/*
* Автор: Дегтянников К.А.
* Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
*/
-- Создание платежа
declare
  c_payment_create_discription constant varchar2(200 char) := 'Платеж создан';
  с_payment_create_status constant number(10) := 0;
  v_current_dtime date := sysdate;
begin
  dbms_output.put_line(c_payment_create_discription||'. Статус: '||с_payment_create_status);
  dbms_output.put_line(to_char(v_current_dtime,'dd.mm.yyyy'));
end;
/
-- Ошибка проведения платежа
declare
  c_payment_error_discription constant varchar2(200 char) := 'Сброс платежа в "ошибочный статус" с указанием причины.';
  с_payment_error_status constant number(10) := 2;
  v_payment_error_reason varchar2(200 char);
  v_current_dtime date := sysdate;
begin
  v_payment_error_reason := 'недостаточно средств';

  dbms_output.put_line(c_payment_error_discription||' Статус: '||с_payment_error_status||'. Причина: '||v_payment_error_reason);
  dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi'));
end;
/
-- Отмена платежа
declare
  c_payment_cancel_discription constant varchar2(200 char) := 'Отмена платежа с указанием причины.';
  с_payment_cancel_status constant number(10) := 3;
  v_payment_cancel_reason varchar2(200 char);
  v_current_dtime date := sysdate;
begin
  v_payment_cancel_reason := 'ошибка пользователя';

  dbms_output.put_line(c_payment_cancel_discription||' Статус: '||с_payment_cancel_status||'. Причина: '||v_payment_cancel_reason);
  dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));
end;
/
-- Успешное завершение платежа
declare
  c_payment_success_discription constant varchar2(200 char) := 'Успешное завершение платежа';
  c_payment_success_status constant number(10) := 1;
  v_current_dtime timestamp := systimestamp;
begin
  dbms_output.put_line(c_payment_success_discription||'. Статус: '||c_payment_success_status);
  dbms_output.put_line(to_char(v_current_dtime, 'DD Mon YYYY'));
end;
/
-- Добавление/обновление данных по платежу 
declare
  c_payment_update_discription constant varchar2(200 char) := 'Данные платежа добавлены или обновлены';
  v_current_dtime timestamp := systimestamp;
begin
  dbms_output.put_line(c_payment_update_discription||' по списку id_поля/значение');
  dbms_output.put_line(to_char(v_current_dtime, 'hh24:mi:ss.ff'));
end;
/
-- Удаление делатей платежа
declare
  c_payment_delete_discription constant varchar2(200 char) := 'Детали платежа удалены';
  v_current_dtime timestamp := systimestamp;
begin
  dbms_output.put_line(c_payment_delete_discription||' по списку id_полей');
  dbms_output.put_line(to_char(v_current_dtime, 'yyyy-mm-dd hh24:mi:ss.ff9'));
end;
/
