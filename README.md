# wordpress-cluster

Installs and configures a wordpress cluster. This cookbooks is highly
opinionated, and assumes you are conforming to our environment.

## LWRPs

This cookbook is intended to be consumed through its LWRPs, and therefore
doesn't include any recipes. Here is an overview of the LWRPs provided:

**Note:** The first attribute listed for each LWRP is also the name attribute.

### wordpress_cluster_app

**Attributes:**

| Name             | Description                                                      | Type                        | Required | Default  |
| ---------------- | ---------------------------------------------------------------- | --------------------------- | -------- | -------- |
| app_name         | Name of the application.                                         | String                      | true     | N/A      |
| deployment_user  | User that deploys the application.                               | String                      | false    | 'deploy' |
| deployment_group | Group that deploys the application.                              | String                      | false    | 'deploy' |
| web_root         | Directory where app is server (relative to the root of the repo) | String                      | false    | 'web'    |
| server_name      | ServerName in Apache config.                                     | String                      | true     | N/A      |
| server_aliases   | List of ServerAlias in Apache config.                            | Array                       | false    | nil      |
| scm              | Source code management tool used for the project                 | String ('git' or 'hg' only) | true     | N/A      |
| development      | Development flag for configuring local dev machines.             | Boolean                     | false    | false    |
| bedrock          | Whether or not to configure for bedrock wordpress apps.          | Boolean                     | false    | false    |

**Example:**

```ruby
wordpress_cluster_app 'my-app' do
  server_name 'my-app.com'
  scm 'git'
end
```

### wordpress_cluster_database

**Attributes:**

| Name                | Description                                          | Type    | Required | Default     |
| ------------------- | ---------------------------------------------------- | ------- | -------- | ----------- |
| db_name             | Name of the MySQL database.                          | String  | true     | N/A         |
| user                | MySQL user that owns the database.                   | String  | true     | N/A         |
| user_host           | Host the database is on.                             | String  | false    | 'localhost' |
| user_password       | Password for MySQL user that owns the database.      | String  | true     | N/A         |
| mysql_root_password | Password for MySQL root user.                        | String  | true     | N/A         |
| development         | Development flag for configuring local dev machines. | Boolean | false    | false       |

**Example:**

```ruby
wordpress_cluster_database 'my_app_production' do
  user 'my-app'
  user_host '%'
  user_password 'my-app-password'
  mysql_root_password 'my-root-password'
end
```

### wordpress_cluster_repl_config

**Attributes:**

| Name           | Description                              | Type   | Required | Default |
| ------------   | ---------------------------------------- | ------ | -------- | ------- |
| name           | Name of repl configuration.              | String | true     | N/A     |
| csync2_key     | Key used for csync2.                     | String | true     | N/A     |
| csync2_hosts   | List of hosts to sync with csync2.       | Array  | true     | N/A     |
| lsyncd_sync_id | SyncId to use in lsyncd config           | String | true     | N/A     |
| synced_dirs    | List of directories to sync with csync2. | Array  | true     | N/A     |

**Example:**

```ruby
wordpress_cluster_repl_config 'main' do
  csync2_key 'a5HuyFhmKThg.aOS_iNr8N_UOMvp6VLd.AnSL.PvP5SzckPpEYyMaWDP2Jv5t2H6'
  csync2_hosts [{ name: 'web01', ip_address: '1.2.3.4' },
                { name: 'web02', ip_address: '2.3.4.5' }]
  lsyncd_sync_id 'web01'
  synced_dirs ['/var/www/my-app/shared/web/app/uploads']
end
```
