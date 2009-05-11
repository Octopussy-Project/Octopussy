CREATE DATABASE IF NOT EXISTS octopussy;
CREATE TABLE IF NOT EXISTS octopussy._alerts_ (log_id bigint(20) NOT NULL auto_increment, alert_id varchar(250) default NULL, status varchar(50) default 'Opened', level varchar(50) default NULL, date_time datetime default NULL, device varchar(250) default NULL, log text default NULL, comment text default NULL, PRIMARY KEY  (log_id));
INSERT IGNORE INTO mysql.user (host,user,password, file_priv) values ('localhost','octopussy',password('octopussy'), 'Y');
INSERT IGNORE INTO mysql.db (host,user,db,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv) values ('localhost','octopussy','octopussy','Y','Y','Y','Y','Y','Y');
FLUSH PRIVILEGES;
