create or replace package ut_common_payment_pack is

  -- Детали платежа
  c_detail_client_software    payment_detail_field.field_id%type := 1;
  c_detail_ip                 payment_detail_field.field_id%type := 2;
  c_detail_note               payment_detail_field.field_id%type := 3;
  c_detail_is_checked_fraud   payment_detail_field.field_id%type := 4;

  function get_random_payment_sum return payment.summa%type;
  function get_random_currency return payment.currency_id%type;
  function get_random_payment_detail_data return t_payment_detail_array;
  function get_random_reason return payment.status_change_reason%type;

  function get_payment_data(p_payment payment.payment_id%type) return payment%rowtype;
  function get_payment_datail_data(p_payment payment.payment_id%type) return t_payment_detail_array;

  function create_default_payment(p_payment_detail_data t_payment_detail_array := t_payment_detail_array()) return payment.payment_id%type;

end ut_common_payment_pack;
/
