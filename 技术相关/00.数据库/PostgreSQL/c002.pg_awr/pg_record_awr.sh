#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0`; pwd)
CONF_FILE="${SCRIPT_DIR}/awr.conf"
DATE_STR=$(date +%Y%m%d)
BGWRITE_LOG="${SCRIPT_DIR}/run_log/bgwriter_${DATE_STR}.log"
RUN_LOG_FILE="${SCRIPT_DIR}/run_log/pg_record_awr_${DATE_STR}.log"

function log()
{
    echo "[$(date +%Y-%m-%d-%H-%M-%S)] $*" >> "${RUN_LOG_FILE}"
}

function main()
{
    "${SCRIPT_DIR}"/hello.tool d '!hellobike' "${CONF_FILE}" | grep -v "#" |grep -v "^$" | while read -r line; 
    do
        num=$(echo "${line}" |awk -F"@" '{print NF}')
        if [ "${num}" -ne 6 ]; then
            continue
        fi
    
        T_HOSTNAME=$(echo "${line}" |awk -F"@" '{printf $1}')
        T_USERNAME=$(echo "${line}" |awk -F"@" '{printf $2}')
        T_DATABASENAME=$(echo "${line}" |awk -F"@" '{printf $3}')
        T_PWD=$(echo "${line}" |awk -F"@" '{printf $4}')
        T_PORT=$(echo "${line}" |awk -F"@" '{printf $5}')
        T_RESVERDAY=$(echo "${line}" |awk -F"@" '{printf $6}')
        
        export PGPASSWORD="${T_PWD}"

        psql -h "${T_HOSTNAME}" -d "${T_DATABASENAME}" -U "${T_USERNAME}" -p "${T_PORT}" -t -A -w -c " \
            select pg_stat_statements_reset(); \
            select __rds_pg_stats__.snap_database(false); \
            select __rds_pg_stats__.snap_delete(LOCALTIMESTAMP - interval '${T_RESVERDAY} day');\
            " >> "${RUN_LOG_FILE}" 2>&1

        psql -h "${T_HOSTNAME}" -d "${T_DATABASENAME}" -U "${T_USERNAME}" -p "${T_PORT}" -t -A -w -c " \
            select '${T_HOSTNAME}:${T_PORT},pg_stat_bgwriter,'||to_char(now(),'YYYY-MM-DD HH24:MI:SS')||','||checkpoints_timed || \
                   ','||checkpoints_req||','||checkpoint_write_time||','||checkpoint_sync_time|| \
                   ','||buffers_checkpoint||','||buffers_clean||','||maxwritten_clean|| \
                   ','||buffers_backend||','||buffers_backend_fsync||','||buffers_alloc|| \
                   ','||to_char(stats_reset,'YYYY-MM-DD HH24:MI:SS') from pg_stat_bgwriter;\
            " >> "${BGWRITE_LOG}" 2>>/dev/null
    done
}

log "begin"
main
log "end"