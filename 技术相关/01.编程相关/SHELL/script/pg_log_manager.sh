#!/bin/bash

# in param
LOG_DURATION=$1
DBLOG_PATH="$2"
DEST_USER="$3"
DEST_IP="$4"
DEST_DIR="$5"
LAST_LOG_FILE="pglog_lastfile.file"


# global param
LAST_SCPLOG_FILENAME=""

SCRIPT_DIR=$(cd `dirname $0`; pwd)
mkdir -p "${SCRIPT_DIR}"/pg_log_manager_log
RUN_LOG_FILE="${SCRIPT_DIR}/pg_log_manager_log/pg_log_manager_log_$(date +%Y_%m_%d).log"

function log()
{
    echo "[$(date +%Y-%m-%d-%H-%M-%S)] $*" >> "${RUN_LOG_FILE}"
}

function check()
{
    if [ -z "${DBLOG_PATH}" ] || [ ! -d "${DBLOG_PATH}" ]; then
        log "${DBLOG_PATH} is not a valid directory! "
        return 1
    fi

    i_pid=$$
    result=$(ps -ef |grep "${SCRIPT_DIR}/pg_log_manager.sh" |grep -v grep |grep -v "${i_pid}")
    if [ -n "$result" ]; then
        log "the other process is running($result)"
        return 1
    fi

    ssh -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no  "${DEST_USER}"@"${DEST_IP}" "date"
    if [ $? -ne 0 ]; then
        log "ssh error! "
        return 1
    fi

    return 0
}

function get_last_log_file()
{
    if [ ! -f "${SCRIPT_DIR}/${LAST_LOG_FILE}" ]; then
        log "${SCRIPT_DIR}/${LAST_LOG_FILE} is not exist!"
        return
    fi
    LAST_SCPLOG_FILENAME=$(head -1 "${SCRIPT_DIR}"/"${LAST_LOG_FILE}")
}

function save_last_log_file()
{
    tmp_last_scplog_filename=$1
    echo "${tmp_last_scplog_filename}" > "${SCRIPT_DIR}"/"${LAST_LOG_FILE}"
}

function scp_log()
{
    local -i filenum=0
    local -i compare_flag=0

    get_last_log_file
    if [ ! -z "${LAST_SCPLOG_FILENAME}" ] && [ -f "${LAST_SCPLOG_FILENAME}" ]; then
        compare_flag=1
    fi

    for filename in $(find "${DBLOG_PATH}"/postgresql-* |sort)
    do
        if [ "${compare_flag}" -eq 1 ]; then
            if [ "${filename}" \< "${LAST_SCPLOG_FILENAME}" ]; then
                continue
            elif [ "${filename}" == "${LAST_SCPLOG_FILENAME}" ]; then
                rsync -a "${filename}" "${DEST_USER}"@"${DEST_IP}":"${DEST_DIR}"/ >> /dev/null 2>&1
                filenum=`expr $filenum + 1`
                continue
            fi
        fi
        scp "${filename}" "${DEST_USER}"@"${DEST_IP}":"${DEST_DIR}"/ >> /dev/null 2>&1
        filenum=`expr $filenum + 1`
    done

    save_last_log_file "${filename}"
    log "the last file is ${filename}, filenum is ${filenum}"
}

function remove_db_log()
{
    if [ -z "${LOG_DURATION}" ] || [ "${LOG_DURATION}" -gt 432000 ] || [ "${LOG_DURATION}" -lt 60 ]; then
        LOG_DURATION=1440
    fi
    find "${DBLOG_PATH}"/postgresql-* -mmin +${LOG_DURATION} -exec rm {} \;>> /dev/null 2>&1
}

function remove_script_run_log()
{
    #30 days
    find "${SCRIPT_DIR}"/pg_log_manager_log/pg_log_manager_log* -mmin +43200 -exec rm {} \; >> /dev/null 2>&1
}

###mian function
log "pg_log_manager begin."
check || exit 1

if [ ! -z "${DEST_IP}" ]; then
    log "pg_log_manager scp_log begin."
    scp_log
    log "pg_log_manager scp_log end."
fi

log "pg_log_manager remove_db_log begin."
remove_db_log
log "pg_log_manager remove_db_log end."

remove_script_run_log
log "pg_log_manager end"

