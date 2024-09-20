/*
* Автор: Дегтянников К.А.
* Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
*/
-- Создание платежа
declare
  c_payment_create_discription constant varchar2(200) := 'Платеж создан';
  с_payment_create_status constant number := 0;
begin
  dbms_output.put_line(c_payment_create_discription||'. Статус: '||с_payment_create_status);
end;
/
-- Ошибка проведения платежа
declare
  c_payment_error_discription constant varchar2(200) := 'Сброс платежа в "ошибочный статус"';
  с_payment_error_status constant number := 2;
  v_payment_error_reason varchar2(200);
begin
  v_payment_error_reason := 'недостаточно средств';

  dbms_output.put_line(c_payment_error_discription||' с указанием причины. '||
                      'Статус: '||с_payment_error_status||'. Причина: '||v_payment_error_reason);
end;
/
-- Отмена платежа
declare
  c_payment_cancel_discription constant varchar2(200) := 'Отмена платежа';
  с_payment_cancel_status constant number := 3;
  v_payment_cancel_reason varchar2(200);
begin
  v_payment_cancel_reason := 'ошибка пользователя';

  dbms_output.put_line(c_payment_cancel_discription||' с указанием причины. '||
                      'Статус: '||с_payment_cancel_status||'. Причина: '||v_payment_cancel_reason);
end;
/
-- Успешное завершение платежа
declare
  c_payment_success_discription constant varchar2(200) := 'Успешное завершение платежа';
  c_payment_success_status constant number := 1;
begin

  dbms_output.put_line(c_payment_success_discription||'. Статус: '||c_payment_success_status);
end;
/
-- Добавление/обновление данных по платежу 
declare
  c_payment_update_discription constant varchar2(200) := 'Данные платежа добавлены или обновлены';
begin
  dbms_output.put_line(c_payment_update_discription||' по списку id_поля/значение');
end;
/
-- Удаление делатей платежа
declare
  c_payment_delete_discription constant varchar2(200) := 'Детали платежа удалены';
begin
  dbms_output.put_line(c_payment_delete_discription||' по списку id_полей');
end;
/
