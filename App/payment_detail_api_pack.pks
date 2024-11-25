create or replace package payment_detail_api_pack is

-- Author  : Дегтянников К.А.
-- Created : 14.10.2024 18:52:13
-- Purpose : API по деталям платежа

-- проверка на прямой DML
procedure check_payment_detail_dml_allowed;

/*** 
* "Добавление/обновление данных по платежу"
* @param p_payment_id           - ID платежа
* @param p_payment_detail_data  - коллекция с деталями платежа
***/
procedure insert_or_update_payment_detail( p_payment_id              payment.payment_id%type
                                         , p_payment_detail_data     t_payment_detail_array
                                         );

/*** 
* "Удаление делатей платежа"
* @param p_payment_id              - ID платежа
* @param p_delete_payment_filelds  - массив из ID полей "детали платежа", которые надо удалить
***/
procedure delete_payment_detail( p_payment_id               payment.payment_id%type
                               , p_delete_payment_filelds   t_number_array
                               );
end payment_detail_api_pack;
/
