{application,rest_store,
             [{description,"Message Index Store"},
              {vsn,"0.0.1"},
              {modules,[ds_util,hash_md5,inbox_handler,index_handler,
                        message_handler,message_server,myredis,proxy_server,
                        qredis,rest_store,rest_store_app,rest_store_sup,
                        susr_handler,susr_server,user_handler,user_server]},
              {registered,[rest_store_sup]},
              {applications,[kernel,stdlib,cowboy]},
              {mod,{rest_store_app,[]}},
              {env,[]}]}.
