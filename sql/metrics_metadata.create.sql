--! create database
CREATE DATABASE metrics_monitor_metadata;

--! create table 
CREATE TABLE metrics_metadata(
    id SERIAL PRIMARY KEY,
    day TIMESTAMP,
    event_key TEXT NOT NULL,
    platform TEXT NOT NULL,
    os TEXT NOT NULL,
    pv INT NOT NULL,
    uv INT NOT NULL,
    creat_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--! create index
CREATE index idx_metrics_metadata_event_key ON metrics_metadata USING btree(event_key);

--! load data
metrics_monitor_metadata=# COPY metrics_metadata(day, event_key, platform, os, pv, uv)
metrics_monitor_metadata-# FROM '/Users/xingzezhang/current_work/bd_data_monitoring_system/sql/base_metrics_metadata.csv' DELIMITER ',' CSV HEADER;