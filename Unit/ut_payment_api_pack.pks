create or replace package ut_payment_api_pack is

--%suite UNIT-тесты для объекта "Платеж"

--%test(Создание платежа. Проверка значений в таблице payment)
procedure create_payment_check_payment_filds;

--%test(Создание платежа. Проверка технических дат)
procedure create_payment_check_dtime_tech;

--%test(Перевод платежа в статус "ошибочный". Проверка статуса и причины)
procedure fail_payment_check_status_and_resons;

--%test(Перевод платежа в статус "ошибочный". Проверка технических дат)
procedure fail_payment_check_dtime_tech;


/***************************************************************************
**************************    Негативные кейсы     *************************
****************************************************************************/


--%test(Создание платежа. Создание с пустым значением "сумма платежа")
procedure create_payment_empty_payment_sum;


end ut_payment_api_pack;
/
