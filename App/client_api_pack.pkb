create or replace package body client_api_pack is

  g_is_api boolean := false; -- признак, выполняется ли изменение через API

  -- разрешение менять данные
  procedure allow_changes is
  begin
    g_is_api := true;
  end;

  -- запрет менять данные
  procedure disallow_changes is
  begin
    g_is_api := false;
  end;

  -- Создание клиента
  function create_client(p_client_data t_client_data_array)
    return client.client_id%type is
    v_client_id client.client_id%type;
  begin
    allow_changes();
  
    -- создание клиента
    insert into client
      (client_id
      ,is_active
      ,is_blocked
      ,blocked_reason)
    values
      (client_seq.nextval
      ,c_active
      ,c_not_blocked
      ,null)
    returning client_id into v_client_id;
  
    -- добавление клиентских данных
    client_data_api_pack.insert_or_update_client_data(p_client_id   => v_client_id,
                                                      p_client_data => p_client_data);
  
    disallow_changes();
  
    return v_client_id;
  
  exception
    when others then
      disallow_changes();
      raise;
  end;

  -- Блокировка клиента
  procedure block_client(p_client_id client.client_id%type
                        ,p_reason    client.blocked_reason%type) is
  begin
    if p_client_id is null then
      raise_application_error(common_pack.c_error_code_invalid_parameter,
                              common_pack.c_error_msg_object_id_is_null);
    end if;
  
    if p_reason is null then
      raise_application_error(common_pack.c_error_code_invalid_parameter,
                              common_pack.c_error_msg_payment_reason_is_null);
    end if;
    
    try_lock_client(p_client_id);-- блокируем клиента
  
    allow_changes();
  
    -- обновление клиента
    update client cl
       set cl.is_blocked     = c_blocked
          ,cl.blocked_reason = p_reason
     where cl.client_id = p_client_id
       and cl.is_active = c_active;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end;

  -- Разблокировка клиента
  procedure unblock_client(p_client_id client.client_id%type) is
  begin
    if p_client_id is null then
      raise_application_error(common_pack.c_error_code_invalid_parameter,
                              common_pack.c_error_msg_object_id_is_null);
    end if;

    try_lock_client(p_client_id);-- блокируем клиента
  
    allow_changes();
  
    -- обновление клиента
    update client cl
       set cl.is_blocked     = c_not_blocked
          ,cl.blocked_reason = null
     where cl.client_id = p_client_id
       and cl.is_active = c_active;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end;

  -- Клиент деактивирован
  procedure deactivate_client(p_client_id client.client_id%type) is
  begin
    if p_client_id is null then
      raise_application_error(common_pack.c_error_code_invalid_parameter,
                              common_pack.c_error_msg_object_id_is_null);
    end if;

    try_lock_client(p_client_id);-- блокируем клиента
  
    allow_changes();
  
    -- обновление клиента
    update client cl
       set cl.is_active = c_inactive
     where cl.client_id = p_client_id
       and cl.is_active = c_active;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end;

  procedure is_changes_through_api is
  begin
    if not g_is_api
       and not common_pack.is_manual_changes_allowed() then
      raise_application_error(common_pack.c_error_code_payment_dml_disallow,
                              common_pack.c_error_msg_payment_dml_disallow);
    end if;
  end;

  procedure check_client_delete_restriction is
  begin
    if not common_pack.is_manual_changes_allowed() then
      raise_application_error(common_pack.c_error_code_delete_forbidden,
                              common_pack.c_error_msg_delete_forbidden);
    end if;
  end;

  procedure try_lock_client(p_client_id client.client_id%type) is
    v_is_active client.client_id%type;
  begin
    -- пытаемся заблокировать клиента
    select cl.is_active
      into v_is_active
      from client cl
     where cl.client_id = p_client_id
       for update nowait;
    
    -- объект уже неактивен. с ним нельзя работать
    if v_is_active = c_inactive then
      raise_application_error(common_pack.c_error_code_inactive_object_state, common_pack.c_error_msg_inactive_object_state);        
    end if;
    
  exception
    when no_data_found then -- такой клиент вообще не найден
      raise_application_error(common_pack.c_error_code_object_notfound, common_pack.c_error_msg_object_notfound);
    when common_pack.e_row_locked then -- объект не удалось заблокировать
      raise_application_error(common_pack.c_error_code_object_locked, common_pack.c_error_msg_object_locked);
  end;

end;

/