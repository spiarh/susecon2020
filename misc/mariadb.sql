CREATE DATABASE prestashop;
CREATE USER 'prestashop'@'%' IDENTIFIED BY 'susecon';
GRANT ALL ON prestashop.* TO 'prestashop'@'%' WITH GRANT OPTION;
CREATE DATABASE nextcloud;
CREATE USER 'nextcloud'@'%' IDENTIFIED BY 'susecon';
GRANT ALL ON nextcloud.* TO 'nextcloud'@'%' WITH GRANT OPTION;
