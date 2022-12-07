/////////////////////////////////////////////////////////////
//
// pgAdmin 4 - PostgreSQL Tools
//
// Copyright (C) 2013 - 2022, The pgAdmin Development Team
// This software is released under the PostgreSQL Licence
//
//////////////////////////////////////////////////////////////

define(
  'pgadmin.browser.endpoints', [],
  function() {
    return {
            'static': '/pgadmin4/static/<path:filename>',

      'kerberos.login': '/pgadmin4/kerberos/login',

      'kerberos.logout': '/pgadmin4/kerberos/logout',

      'kerberos.update_ticket': '/pgadmin4/kerberos/update_ticket',

      'kerberos.validate_ticket': '/pgadmin4/kerberos/validate_ticket',

      'oauth2.authorize': '/pgadmin4/oauth2/authorize',

      'oauth2.logout': '/pgadmin4/oauth2/logout',

      'webserver.login': '/pgadmin4/webserver/login',

      'webserver.logout': '/pgadmin4/webserver/logout',

      'about.index': '/pgadmin4/about/',

      'authenticate.login': '/pgadmin4/authenticate/login',

      'browser.index': '/pgadmin4/browser/',

      'browser.nodes': '/pgadmin4/browser/nodes/',

      'browser.check_corrupted_db_file': '/pgadmin4/browser/check_corrupted_db_file',

      'browser.check_master_password': '/pgadmin4/browser/master_password',

      'browser.set_master_password': '/pgadmin4/browser/master_password',

      'browser.reset_master_password': '/pgadmin4/browser/master_password',

      'browser.lock_layout': '/pgadmin4/browser/lock_layout',

      'browser.signal_runtime': '/pgadmin4/browser/signal_runtime',

      'NODE-server.connect_id': '/pgadmin4/browser/server/connect/<int:gid>/<int:sid>',

      'NODE-server.connect_id': '/pgadmin4/browser/server/connect/<int:gid>/<int:sid>',

      'NODE-server.connect_id': '/pgadmin4/browser/server/connect/<int:gid>/<int:sid>',

      'dashboard.index': '/pgadmin4/dashboard/',

      'dashboard.get_by_sever_id': '/pgadmin4/dashboard/<int:sid>',

      'dashboard.get_by_database_id': '/pgadmin4/dashboard/<int:sid>/<int:did>',

      'dashboard.dashboard_stats': '/pgadmin4/dashboard/dashboard_stats',

      'dashboard.dashboard_stats_sid': '/pgadmin4/dashboard/dashboard_stats/<int:sid>',

      'dashboard.dashboard_stats_did': '/pgadmin4/dashboard/dashboard_stats/<int:sid>/<int:did>',

      'dashboard.activity': '/pgadmin4/dashboard/activity/',

      'dashboard.get_activity_by_server_id': '/pgadmin4/dashboard/activity/<int:sid>',

      'dashboard.get_activity_by_database_id': '/pgadmin4/dashboard/activity/<int:sid>/<int:did>',

      'dashboard.locks': '/pgadmin4/dashboard/locks/',

      'dashboard.get_locks_by_server_id': '/pgadmin4/dashboard/locks/<int:sid>',

      'dashboard.get_locks_by_database_id': '/pgadmin4/dashboard/locks/<int:sid>/<int:did>',

      'dashboard.prepared': '/pgadmin4/dashboard/prepared/',

      'dashboard.get_prepared_by_server_id': '/pgadmin4/dashboard/prepared/<int:sid>',

      'dashboard.get_prepared_by_database_id': '/pgadmin4/dashboard/prepared/<int:sid>/<int:did>',

      'dashboard.config': '/pgadmin4/dashboard/config/',

      'dashboard.get_config_by_server_id': '/pgadmin4/dashboard/config/<int:sid>',

      'help.static': '/pgadmin4/help/help/<path:filename>',

      'misc.ping': '/pgadmin4/misc/ping',

      'misc.index': '/pgadmin4/misc/',

      'misc.cleanup': '/pgadmin4/misc/cleanup',

      'misc.validate_binary_path': '/pgadmin4/misc/validate_binary_path',

      'bgprocess.status': '/pgadmin4/misc/bgprocess/<pid>',

      'bgprocess.detailed_status': '/pgadmin4/misc/bgprocess/<pid>/<int:out>/<int:err>/',

      'bgprocess.acknowledge': '/pgadmin4/misc/bgprocess/<pid>',

      'bgprocess.list': '/pgadmin4/misc/bgprocess/',

      'bgprocess.stop_process': '/pgadmin4/misc/bgprocess/stop/<pid>',

      'bgprocess.update_cloud_details': '/pgadmin4/misc/bgprocess/update_cloud_details/<pid>',

      'cloud.deploy_on_cloud': '/pgadmin4/cloud/deploy',

      'cloud.update_cloud_server': '/pgadmin4/cloud/update_cloud_server',

      'cloud.update_cloud_process': '/pgadmin4/cloud/update_cloud_process/<sid>',

      'cloud.get_host_ip': '/pgadmin4/cloud/get_host_ip/',

      'cloud.clear_cloud_session': '/pgadmin4/cloud/clear_cloud_session/',

      'file_manager.init': '/pgadmin4/file_manager/init',

      'file_manager.filemanager': '/pgadmin4/file_manager/filemanager/<int:trans_id>/',

      'file_manager.index': '/pgadmin4/file_manager/',

      'file_manager.delete_trans_id': '/pgadmin4/file_manager/delete_trans_id/<int:trans_id>',

      'file_manager.save_last_dir': '/pgadmin4/file_manager/save_last_dir/<int:trans_id>',

      'file_manager.save_file_dialog_view': '/pgadmin4/file_manager/save_file_dialog_view/<int:trans_id>',

      'file_manager.save_show_hidden_file_option': '/pgadmin4/file_manager/save_show_hidden_file_option/<int:trans_id>',

      'sql.format': '/pgadmin4/misc/sql/format',

      'sql.format': '/pgadmin4/misc/sql/format',

      'bgprocess.status': '/pgadmin4/misc/bgprocess/<pid>',

      'bgprocess.detailed_status': '/pgadmin4/misc/bgprocess/<pid>/<int:out>/<int:err>/',

      'bgprocess.acknowledge': '/pgadmin4/misc/bgprocess/<pid>',

      'bgprocess.list': '/pgadmin4/misc/bgprocess/',

      'bgprocess.stop_process': '/pgadmin4/misc/bgprocess/stop/<pid>',

      'bgprocess.update_cloud_details': '/pgadmin4/misc/bgprocess/update_cloud_details/<pid>',

      'cloud.deploy_on_cloud': '/pgadmin4/cloud/deploy',

      'cloud.update_cloud_server': '/pgadmin4/cloud/update_cloud_server',

      'cloud.update_cloud_process': '/pgadmin4/cloud/update_cloud_process/<sid>',

      'cloud.get_host_ip': '/pgadmin4/cloud/get_host_ip/',

      'cloud.clear_cloud_session': '/pgadmin4/cloud/clear_cloud_session/',

      'azure.verify_credentials': '/pgadmin4/azure/verify_credentials/',

      'azure.check_cluster_name_availability': '/pgadmin4/azure/check_cluster_name_availability/',

      'azure.subscriptions': '/pgadmin4/azure/subscriptions/',

      'azure.resource_groups': '/pgadmin4/azure/resource_groups/<subscription_id>',

      'azure.regions': '/pgadmin4/azure/regions/<subscription_id>',

      'azure.zone_redundant_ha_supported': '/pgadmin4/azure/zone_redundant_ha_supported/<region_name>',

      'azure.db_versions': '/pgadmin4/azure/db_versions/<availability_zone>',

      'azure.instance_types': '/pgadmin4/azure/instance_types/<availability_zone>/<db_version>',

      'azure.availability_zones': '/pgadmin4/azure/availability_zones/<region_name>',

      'azure.storage_types': '/pgadmin4/azure/storage_types/<availability_zone>/<db_version>',

      'azure.get_azure_verification_codes': '/pgadmin4/azure/get_azure_verification_codes/',

      'biganimal.verification': '/pgadmin4/biganimal/verification/',

      'biganimal.verification_ack': '/pgadmin4/biganimal/verification_ack/',

      'biganimal.regions': '/pgadmin4/biganimal/regions/',

      'biganimal.db_types': '/pgadmin4/biganimal/db_types/',

      'biganimal.db_versions': '/pgadmin4/biganimal/db_versions/',

      'biganimal.instance_types': '/pgadmin4/biganimal/instance_types/<region_id>',

      'biganimal.volume_types': '/pgadmin4/biganimal/volume_types/<region_id>',

      'biganimal.volume_properties': '/pgadmin4/biganimal/volume_properties/<region_id>/<volume_type>',

      'rds.db_versions': '/pgadmin4/rds/db_versions/',

      'rds.verify_credentials': '/pgadmin4/rds/verify_credentials/',

      'rds.db_instances': '/pgadmin4/rds/db_instances/',

      'rds.regions': '/pgadmin4/rds/regions/',

      'file_manager.init': '/pgadmin4/file_manager/init',

      'file_manager.filemanager': '/pgadmin4/file_manager/filemanager/<int:trans_id>/',

      'file_manager.index': '/pgadmin4/file_manager/',

      'file_manager.delete_trans_id': '/pgadmin4/file_manager/delete_trans_id/<int:trans_id>',

      'file_manager.save_last_dir': '/pgadmin4/file_manager/save_last_dir/<int:trans_id>',

      'file_manager.save_file_dialog_view': '/pgadmin4/file_manager/save_file_dialog_view/<int:trans_id>',

      'file_manager.save_show_hidden_file_option': '/pgadmin4/file_manager/save_show_hidden_file_option/<int:trans_id>',

      'sql.format': '/pgadmin4/misc/sql/format',

      'sql.format': '/pgadmin4/misc/sql/format',

      'preferences.index': '/pgadmin4/preferences/',

      'preferences.get_by_name': '/pgadmin4/preferences/<module>/<preference>',

      'preferences.get_all': '/pgadmin4/preferences/get_all',

      'settings.store': '/pgadmin4/settings/store/<setting>/<value>',

      'settings.store_bulk': '/pgadmin4/settings/store',

      'settings.reset_layout': '/pgadmin4/settings/layout',

      'settings.save_tree_state': '/pgadmin4/settings/save_tree_state/',

      'settings.get_tree_state': '/pgadmin4/settings/get_tree_state/',

      'settings.reset_tree_state': '/pgadmin4/settings/reset_tree_state',

      'settings.save_file_format_setting': '/pgadmin4/settings/save_file_format_setting/',

      'settings.get_file_format_setting': '/pgadmin4/settings/get_file_format_setting/',

      'backup.create_server_job': '/pgadmin4/backup/job/<int:sid>',

      'backup.create_object_job': '/pgadmin4/backup/job/<int:sid>/object',

      'backup.utility_exists': '/pgadmin4/backup/utility_exists/<int:sid>/<backup_obj_type>',

      'debugger.index': '/pgadmin4/debugger/',

      'debugger.init_for_function': '/pgadmin4/debugger/init/<node_type>/<int:sid>/<int:did>/<int:scid>/<int:fid>',

      'debugger.init_for_trigger': '/pgadmin4/debugger/init/<node_type>/<int:sid>/<int:did>/<int:scid>/<int:fid>/<int:trid>',

      'debugger.direct': '/pgadmin4/debugger/direct/<int:trans_id>',

      'debugger.initialize_target_for_function': '/pgadmin4/debugger/initialize_target/<debug_type>/<int:trans_id>/<int:sid>/<int:did>/<int:scid>/<int:func_id>',

      'debugger.initialize_target_for_trigger': '/pgadmin4/debugger/initialize_target/<debug_type>/<int:trans_id>/<int:sid>/<int:did>/<int:scid>/<int:func_id>/<int:tri_id>',

      'debugger.close': '/pgadmin4/debugger/close/<int:trans_id>',

      'debugger.restart': '/pgadmin4/debugger/restart/<int:trans_id>',

      'debugger.start_listener': '/pgadmin4/debugger/start_listener/<int:trans_id>',

      'debugger.execute_query': '/pgadmin4/debugger/execute_query/<int:trans_id>/<query_type>',

      'debugger.messages': '/pgadmin4/debugger/messages/<int:trans_id>/',

      'debugger.start_execution': '/pgadmin4/debugger/start_execution/<int:trans_id>/<int:port_num>',

      'debugger.set_breakpoint': '/pgadmin4/debugger/set_breakpoint/<int:trans_id>/<int:line_no>/<int:set_type>',

      'debugger.clear_all_breakpoint': '/pgadmin4/debugger/clear_all_breakpoint/<int:trans_id>',

      'debugger.deposit_value': '/pgadmin4/debugger/deposit_value/<int:trans_id>',

      'debugger.select_frame': '/pgadmin4/debugger/select_frame/<int:trans_id>/<int:frame_id>',

      'debugger.get_arguments': '/pgadmin4/debugger/get_arguments/<int:sid>/<int:did>/<int:scid>/<int:func_id>',

      'debugger.set_arguments': '/pgadmin4/debugger/set_arguments/<int:sid>/<int:did>/<int:scid>/<int:func_id>',

      'debugger.clear_arguments': '/pgadmin4/debugger/clear_arguments/<int:sid>/<int:did>/<int:scid>/<int:func_id>',

      'debugger.poll_end_execution_result': '/pgadmin4/debugger/poll_end_execution_result/<int:trans_id>/',

      'debugger.poll_result': '/pgadmin4/debugger/poll_result/<int:trans_id>/',

      'erd.panel': '/pgadmin4/erd/panel/<int:trans_id>',

      'erd.initialize': '/pgadmin4/erd/initialize/<int:trans_id>/<int:sgid>/<int:sid>/<int:did>',

      'erd.prequisite': '/pgadmin4/erd/prequisite/<int:trans_id>/<int:sgid>/<int:sid>/<int:did>',

      'erd.sql': '/pgadmin4/erd/sql/<int:trans_id>/<int:sgid>/<int:sid>/<int:did>',

      'erd.close': '/pgadmin4/erd/close/<int:trans_id>/<int:sgid>/<int:sid>/<int:did>',

      'grant_wizard.acl': '/pgadmin4/grant_wizard/acl/<int:sid>/<int:did>/',

      'grant_wizard.objects': '/pgadmin4/grant_wizard/<int:sid>/<int:did>/<int:node_id>/<node_type>/',

      'grant_wizard.apply': '/pgadmin4/grant_wizard/<int:sid>/<int:did>/',

      'grant_wizard.modified_sql': '/pgadmin4/grant_wizard/sql/<int:sid>/<int:did>/',

      'import_export.create_job': '/pgadmin4/import_export/job/<int:sid>',

      'import_export.utility_exists': '/pgadmin4/import_export/utility_exists/<int:sid>',

      'import_export.get_settings': '/pgadmin4/import_export/get_settings/',

      'import_export_servers.get_servers': '/pgadmin4/import_export_servers/get_servers',

      'import_export_servers.load_servers': '/pgadmin4/import_export_servers/load_servers',

      'import_export_servers.save': '/pgadmin4/import_export_servers/save',

      'maintenance.create_job': '/pgadmin4/maintenance/job/<int:sid>/<int:did>',

      'maintenance.utility_exists': '/pgadmin4/maintenance/utility_exists/<int:sid>',

      'psql.panel': '/pgadmin4/psql/panel/<int:trans_id>',

      'restore.create_job': '/pgadmin4/restore/job/<int:sid>',

      'restore.utility_exists': '/pgadmin4/restore/utility_exists/<int:sid>',

      'schema_diff.initialize': '/pgadmin4/schema_diff/initialize',

      'schema_diff.panel': '/pgadmin4/schema_diff/panel/<int:trans_id>/<path:editor_title>',

      'schema_diff.servers': '/pgadmin4/schema_diff/servers',

      'schema_diff.databases': '/pgadmin4/schema_diff/databases/<int:sid>',

      'schema_diff.schemas': '/pgadmin4/schema_diff/schemas/<int:sid>/<int:did>',

      'schema_diff.ddl_compare': '/pgadmin4/schema_diff/ddl_compare/<int:trans_id>/<int:source_sid>/<int:source_did>/<int:source_scid>/<int:target_sid>/<int:target_did>/<int:target_scid>/<int:source_oid>/<int:target_oid>/<node_type>/<comp_status>/',

      'schema_diff.connect_server': '/pgadmin4/schema_diff/server/connect/<int:sid>',

      'schema_diff.connect_database': '/pgadmin4/schema_diff/database/connect/<int:sid>/<int:did>',

      'schema_diff.get_server': '/pgadmin4/schema_diff/get_server/<int:sid>/<int:did>',

      'schema_diff.close': '/pgadmin4/schema_diff/close/<int:trans_id>',

      'search_objects.search': '/pgadmin4/search_objects/search/<int:sid>/<int:did>',

      'search_objects.types': '/pgadmin4/search_objects/types/<int:sid>/<int:did>',

      'sqleditor.initialize_viewdata': '/pgadmin4/sqleditor/initialize/viewdata/<int:trans_id>/<int:cmd_type>/<obj_type>/<int:sgid>/<int:sid>/<int:did>/<int:obj_id>',

      'sqleditor.initialize_sqleditor': '/pgadmin4/sqleditor/initialize/sqleditor/<int:trans_id>/<int:sgid>/<int:sid>',

      'sqleditor.initialize_sqleditor_with_did': '/pgadmin4/sqleditor/initialize/sqleditor/<int:trans_id>/<int:sgid>/<int:sid>/<int:did>',

      'sqleditor.filter_validate': '/pgadmin4/sqleditor/filter/validate/<int:sid>/<int:did>/<int:obj_id>',

      'sqleditor.filter': '/pgadmin4/sqleditor/filter',

      'sqleditor.panel': '/pgadmin4/sqleditor/panel/<int:trans_id>',

      'sqleditor.close': '/pgadmin4/sqleditor/close/<int:trans_id>',

      'sqleditor.update_sqleditor_connection': '/pgadmin4/sqleditor/initialize/sqleditor/update_connection/<int:trans_id>/<int:sgid>/<int:sid>/<int:did>',

      'sqleditor.view_data_start': '/pgadmin4/sqleditor/view_data/start/<int:trans_id>',

      'sqleditor.query_tool_start': '/pgadmin4/sqleditor/query_tool/start/<int:trans_id>',

      'sqleditor.poll': '/pgadmin4/sqleditor/poll/<int:trans_id>',

      'sqleditor.fetch': '/pgadmin4/sqleditor/fetch/<int:trans_id>',

      'sqleditor.fetch_all': '/pgadmin4/sqleditor/fetch/<int:trans_id>/<int:fetch_all>',

      'sqleditor.fetch_all_from_start': '/pgadmin4/sqleditor/fetch_all_from_start/<int:trans_id>/<int:limit>',

      'sqleditor.save': '/pgadmin4/sqleditor/save/<int:trans_id>',

      'sqleditor.inclusive_filter': '/pgadmin4/sqleditor/filter/inclusive/<int:trans_id>',

      'sqleditor.exclusive_filter': '/pgadmin4/sqleditor/filter/exclusive/<int:trans_id>',

      'sqleditor.remove_filter': '/pgadmin4/sqleditor/filter/remove/<int:trans_id>',

      'sqleditor.set_limit': '/pgadmin4/sqleditor/limit/<int:trans_id>',

      'sqleditor.cancel_transaction': '/pgadmin4/sqleditor/cancel/<int:trans_id>',

      'sqleditor.get_object_name': '/pgadmin4/sqleditor/object/get/<int:trans_id>',

      'sqleditor.auto_commit': '/pgadmin4/sqleditor/auto_commit/<int:trans_id>',

      'sqleditor.auto_rollback': '/pgadmin4/sqleditor/auto_rollback/<int:trans_id>',

      'sqleditor.autocomplete': '/pgadmin4/sqleditor/autocomplete/<int:trans_id>',

      'sqleditor.load_file': '/pgadmin4/sqleditor/load_file/',

      'sqleditor.save_file': '/pgadmin4/sqleditor/save_file/',

      'sqleditor.query_tool_download': '/pgadmin4/sqleditor/query_tool/download/<int:trans_id>',

      'sqleditor.connection_status': '/pgadmin4/sqleditor/status/<int:trans_id>',

      'sqleditor.get_filter_data': '/pgadmin4/sqleditor/filter_dialog/<int:trans_id>',

      'sqleditor.set_filter_data': '/pgadmin4/sqleditor/filter_dialog/<int:trans_id>',

      'sqleditor.get_query_history': '/pgadmin4/sqleditor/query_history/<int:trans_id>',

      'sqleditor.add_query_history': '/pgadmin4/sqleditor/query_history/<int:trans_id>',

      'sqleditor.clear_query_history': '/pgadmin4/sqleditor/query_history/<int:trans_id>',

      'sqleditor.get_macro': '/pgadmin4/sqleditor/get_macros/<int:macro_id>/<int:trans_id>',

      'sqleditor.get_macros': '/pgadmin4/sqleditor/get_macros/<int:trans_id>',

      'sqleditor.set_macros': '/pgadmin4/sqleditor/set_macros/<int:trans_id>',

      'sqleditor.get_new_connection_data': '/pgadmin4/sqleditor/new_connection_dialog/<int:sgid>/<int:sid>',

      'sqleditor.get_new_connection_servers': '/pgadmin4/sqleditor/new_connection_dialog',

      'sqleditor.get_new_connection_database': '/pgadmin4/sqleditor/new_connection_database/<int:sgid>/<int:sid>',

      'sqleditor.get_new_connection_user': '/pgadmin4/sqleditor/new_connection_user/<int:sgid>/<int:sid>',

      'sqleditor._check_server_connection_status': '/pgadmin4/sqleditor/get_server_connection/<int:sgid>/<int:sid>',

      'sqleditor.get_new_connection_role': '/pgadmin4/sqleditor/new_connection_role/<int:sgid>/<int:sid>',

      'sqleditor.connect_server': '/pgadmin4/sqleditor/connect_server/<int:sid>',

      'user_management.roles': '/pgadmin4/user_management/role/',

      'user_management.role': '/pgadmin4/user_management/role/<int:rid>',

      'user_management.users': '/pgadmin4/user_management/user/',

      'user_management.user': '/pgadmin4/user_management/user/<int:uid>',

      'security.login': '/pgadmin4/login',

      'user_management.auth_sources': '/pgadmin4/user_management/auth_sources/',

      'user_management.change_owner': '/pgadmin4/user_management/change_owner',

      'user_management.shared_servers': '/pgadmin4/user_management/shared_servers/<int:uid>',

      'user_management.admin_users': '/pgadmin4/user_management/admin_users/<int:uid>',

      'user_management.save': '/pgadmin4/user_management/save',

      'pgadmin.root': '/pgadmin4'
    };
  });