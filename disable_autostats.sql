BEGIN
   dbms_auto_task_admin.disable
             (client_name=> 'auto optimizer stats collection',
              operation        => NULL,
              window_name      => NULL
             );
END;
