declare
  type t_my_rec is record( test_id number(38)
                         , test_discription varchar2(200) not null := 'test'
                         , test_status number(10) := 0
                         );
  v_first t_my_rec;
  v_second t_my_rec;
begin
  v_first.test_id := 1;
  v_second.test_id := 2;

  dbms_output.put_line('values from v_first: test_id = '||v_first.test_id||', test_discription = '||v_first.test_discription||', test_status = '||v_first.test_status);
  dbms_output.put_line('values from v_second: test_id = '||v_second.test_id||', test_discription = '||v_second.test_discription||', test_status = '||v_second.test_status);

  v_first := null;

  if v_first.test_id is null and v_first.test_discription is null and v_first.test_status is null then
    dbms_output.put_line('v_first It’s null');
  else
    dbms_output.put_line('v_first It’s not null');
  end if;

  if v_second.test_id is null and v_second.test_discription is null and v_second.test_status is null then
    dbms_output.put_line('v_second It’s null');
  else
    dbms_output.put_line('v_second It’s not null');
  end if;
end;
/
declare
  v_payment_detail_field_rec payment_detail_field%rowtype;
begin
  begin
    select *
    into v_payment_detail_field_rec
    from payment_detail_field t
    where rownum = 1;
  exception
    when no_data_found then
      v_payment_detail_field_rec := null;
  end;

  if v_payment_detail_field_rec.field_id is null
    and v_payment_detail_field_rec.name is null
    and v_payment_detail_field_rec.description is null
  then
    dbms_output.put_line('v_payment_detail_field_rec It’s null');
  else
   dbms_output.put_line('v_payment_detail_field_rec: field_id = '||v_payment_detail_field_rec.field_id||', '||
                                                    'name = '||v_payment_detail_field_rec.name||', '||
                                                    'description = '||v_payment_detail_field_rec.description
                       );
  end if;
end;
/
