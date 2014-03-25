CREATE OR REPLACE TRIGGER PROCRM_logon_trigger
  AFTER LOGON
  ON PROCRM.SCHEMA
BEGIN
  execute immediate 'ALTER SESSION SET optimizer_features_enable=''9.2.0.8''';
  execute immediate 'alter session set optimizer_use_sql_plan_baselines=true';
END

CREATE OR REPLACE TRIGGER CRMCUBO_logon_trigger
  AFTER LOGON
  ON CRMCUBO.SCHEMA
BEGIN
  execute immediate 'ALTER SESSION SET optimizer_features_enable=''9.2.0.8''';
  execute immediate 'alter session set optimizer_use_sql_plan_baselines=true';
END