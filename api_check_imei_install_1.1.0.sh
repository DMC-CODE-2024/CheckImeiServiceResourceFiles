#!/bin/bash
. ~/.bash_profile

#set -x

mkdir -p /u02/eirsdata/release/api_service/api_check_imei_module/1.1.0/
cd /u02/eirsdata/release/api_service/api_check_imei_module/1.1.0/
tar -xzvf api_check_imei_1.1.0.tar.gz >>api_check_imei_1.1.0_untar_log.txt

mv api_check_imei_1.1.0.jar ${RELEASE_HOME}/binary/

cd ${APP_HOME}/api_service/api_check_imei/
rm api_check_imei.jar
ln -sf ${RELEASE_HOME}/binary/api_check_imei_1.1.0.jar api_check_imei.jar

source ${commonConfigurationFile} 2>/dev/null

dbPassword=$(java -jar  ${pass_dypt} spring.datasource.password)

conn="mysql -h${dbIp} -P${dbPort} -u${dbUsername} -p${dbPassword} ${appdbName}"

`${conn} <<EOFMYSQL

insert ignore  into  eirs_response_param (tag , value ,feature_name,language ,description) values ('luhnFailMsg' ,'Invalid IMEI number. Please ensure you have entered a valid 15-digit IMEI','Check IMEI' , 'en' , 'Message for luhn algo fail ');
insert ignore  into  eirs_response_param (tag , value ,feature_name,language ,description) values ('luhnFailMsg' ,'លេខ IMEI មនតរមតរវ។ សមបរាកដថាអនកបានបញចល IMEI 15 ខទងតរមតរវ។','Check IMEI' , 'km' , 'Message for luhn algo fail ');

insert ignore into label_mul_lingual_text (label ,english_name,khmer_name ,feature_name) values ('luhnFailMsg' ,'Invalid IMEI number. Please ensure you have entered a valid 15-digit IMEI' ,'លេខ IMEI មនតរមតរវ។ សមបរាកដថាអនកបានបញចល IMEI 15 ខទងតរមតរវ។' ,'Check IMEI');
update sys_param set feature_name ='Check IMEI' where feature_name ='CheckImei';
insert ignore into app.cfg_feature_alert ( alert_id,feature, description ) values ('alert1303','Check IMEI',  'Something went wrong in feature Check Imei while retrieving imei details' ) ;   
insert ignore into app.cfg_feature_alert ( alert_id,feature, description ) values ('alert1304','Check IMEI',  'Something went wrong while saving deviceDetails for  feature CheckImei Init') ; 
insert ignore into app.cfg_feature_alert ( alert_id,feature, description ) values ('alert1305','Check IMEI',  'Something went wrong while retreiving labels and its values for Language Retriever') ; 
insert ignore into app.cfg_feature_alert ( alert_id,feature, description ) values ('alert1306','Check IMEI',  'Something went wrong in check imei pre-init api while fetching url details') ;  
insert ignore into app.cfg_feature_alert ( alert_id,feature, description ) values ('alert1307','Check IMEI',  'Something went wrong while posting to notification api for ussd channel') ;  
insert ignore into app.cfg_feature_alert ( alert_id,feature, description ) values ('alert1308','Check IMEI',  'Something went wrong while storing data to Notification') ;  
insert ignore into app.cfg_feature_alert ( alert_id,feature, description ) values ('alert1309','Check IMEI',  'Something went wrong. Exception <e> occurred for process <process_name> .') ;

update feature_rule set feature ='Check IMEI' where feature = 'CheckImeiNew';
update check_imei_response_param set feature_name = 'Check IMEI' where feature_name = 'CheckImei';

EOFMYSQL`

echo "********************Thank You Process is completed now*****************"

