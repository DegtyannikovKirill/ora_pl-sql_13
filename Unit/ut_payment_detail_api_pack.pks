create or replace package ut_payment_detail_api_pack is

--%suite UNIT-тесты для объекта "Детали платежа"

--%test(Создание платежа. Проверка значений в таблице payment_detail)
procedure create_payment_check_payment_detail_filds;

--%test(update_payment_detail. Проверка, что поля обновились)
procedure update_payment_detail_check_field_value;

/***************************************************************************
**************************    Негативные кейсы     *************************
****************************************************************************/
procedure create_payment_empty_payment_detail;

end ut_payment_detail_api_pack;
/
