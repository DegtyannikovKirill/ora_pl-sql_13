create or replace trigger payment_b_iu_tech_fields
  before insert or update on payment
  for each row
declare
  c_current_timestamp payment.create_dtime_tech%type := systimestamp;
begin
  if inserting then
    :new.create_dtime_tech := c_current_timestamp;
  end if;
  
  :new.update_dtime_tech := c_current_timestamp;

end;
/
