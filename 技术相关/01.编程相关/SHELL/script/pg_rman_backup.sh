#!/bin/bash

#
# Use pg_rman to backup database 
#     TODO: zabbix
#

function log()
{
    echo "[$(basename "$0")][$(date +%Y-%m-%d-%H-%M-%S)] $*"
    echo "[$(basename "$0")][$(date +%Y-%m-%d-%H-%M-%S)] $*" >> "${RUN_LOG_FILE}"
}

function err_exit()
{
    log "=========End Backup(Failed)========="
    exit 1
}

function help()
{
    echo "Usage: $(basename "$0") -D DB_NAME -B BACKUP_PATH --host LOCAL_HOST \\ "
    echo "             --data-dir DB_DATA_PATH --backup-mode BACKUP_MODE \\"
    echo "             --keey-days KEEP_DATA_DAYS --local-port LOCAL_PORT \\" 
    echo "             --backup-db-role BACKUP_DB_ROLE [--master-db-ip MASTER_DB_IP] \\"
    echo "             [--slave-port SLAVE_PORT]"
    echo ""
    echo "Options"
    echo "    -h, --help           : Display this help message."
    echo "    -D                   : OADB|OSSDB|BIKEMANAGE."
    echo "    -B                   : To save the directory of a backup file, you need to initialize with the command pg_rman init"
    echo "    --backup-mode        : full|incremental"
    echo "    --keey-days          : db backup file keep days"
    echo "    --backup-db-role      : master|slave, if the role is slave, master db ip needs to be provide."

}

function get_param()
{
    while :; do
        case $1 in
            -h|-\?|--help)
                help
                exit
                ;;
            -D)
                shift
                DB_NAME="$1"
                ;;
            -B)
                shift
                BACKUP_PATH="$1"
                ;;
            --host)
                shift
                LOCAL_HOST="$1"
                ;;
            --data-dir)
                shift
                DB_DATA_PATH="$1"
                ;;
            --backup-mode)
                shift
                BACKUP_MODE="$1"
                ;;
    
            --keey-days)
                shift
                KEEP_DATA_DAYS="$1"
                ;;
            --local-port)
                shift
                LOCAL_PORT="$1"
                ;;
            --backup-db-role)
                shift
                BACKUP_DB_ROLE="$1"
                ;;
            --master-db-ip)
                shift
                MASTER_DB_IP="$1"
                ;;
            --slave-port)
                shift
                SLAVE_PORT="$1"
                ;;
            -?*)
                log "Unknown option: \"$1\""
                exit 1
                ;;
            *)
                break
        esac
    
        shift
    done
}

function check_param()
{
    # DB_NAME检查
    if [ "$DB_NAME" != "OADB" ] && [ "$DB_NAME" != "OSSDB" ] \
                && [ "$DB_NAME" != "BIKEMANAGE" ]; then
        log "Parameter error, incorrect DB_NAME."
        return 1
    fi

    # BACKUP_MODE检查
    if [ "$BACKUP_MODE" != 'incremental' ] && \
            [ "$BACKUP_MODE" != 'full' ]; then
        log "Parameter error, incorrect PG_RMAN backup model! It should be incremental or full"
        return 1
    fi

    # BACKJP_DB_ROLE检查
    if [ "$BACKUP_DB_ROLE" != 'slave' ] && [ "$BACKUP_DB_ROLE" != 'master' ]; then
        log "Parameter error, please provide BACKUP_DB_ROLE:slave|master"
        return 1
    fi
    if [ "$BACKUP_DB_ROLE" = 'slave' ]; then
        if [ "X$MASTER_DB_IP" = "X" ]; then
            log "Parameter error, must provide MASTER_DB_IP if execute backup on slave node"
            return 1
        fi
        if [ "X$SLAVE_PORT" = "X" ]; then
            log "Parameter error, must provide SLAVE_PORT if execute backup on slave node"
            return 1
        fi
    fi

    # 非空检查
    if [ "X$BACKUP_PATH" = "X" ] || [ "X$DB_DATA_PATH" = "X" ] || \
         [ "X$LOCAL_PORT" = "X" ] || [ "X$KEEP_DATA_DAYS" = "X" ] || \
         [ "X$LOCAL_HOST" = "X" ] ; then
        log "Parameter error, incorrect LOCAL_HOST or BACKUP_PATH or DB_DATA_PATH or LOCAL_PORT or KEEP_DATA_DAYS"
        return 1
    fi

    # 目录有效性检查
    if [ ! -d "$BACKUP_PATH" ] || [ ! -d "$DB_DATA_PATH" ] || \
          [ ! -f "$DB_DATA_PATH/postgresql.conf" ] || \
          [ ! -f "$BACKUP_PATH/pg_rman.ini" ]; then
        log "Parameter error, invalid backup_path or db data path!"
        return 1
    fi

    # KEEP_DATA_DAYS检查，必须是数字
    if [ "$KEEP_DATA_DAYS" = "0" ] ||  [ "$KEEP_DATA_DAYS" -gt 0 ] 2>/dev/null ;then
        KEEP_DATA_DAYS=${KEEP_DATA_DAYS} #占位，并没有实际意义
    else
        log "Parameter error, KEEP_DATA_DAYS must be a number!"
        return 1
    fi

    return 0
}

function check_database_status()
{
    connect_string=""
    if [ "$BACKUP_DB_ROLE" = 'master' ] ; then
        connect_string=" -p $LOCAL_PORT -d postgres -U postgres -h $LOCAL_HOST"
    else
        connect_string=" -p $SLAVE_PORT -d postgres -U postgres -h $LOCAL_HOST"
    fi
    
    # connect_string 不能用双引号括起来
    result=$(psql $connect_string -t -c "select 1;" 2>&1)
    if [ "$?" -ne 0 ]; then
        log "Postgre does not run on this server,connect_string[$connect_string],result[$result]"
        #TODO ZIBBIX
        return 1
    fi
    return 0
}

function do_backup()
{
    keep_arclog_files=0
    keep_srvlog_days=0
    if [ "$BACKUP_DB_ROLE" = "master" ]; then
        "$PGRMAN_BIN" backup -B "$BACKUP_PATH" -D "$DB_DATA_PATH" \
                      -b "$BACKUP_MODE" -Z -C --keep-data-days="$KEEP_DATA_DAYS" \
                      --keep-arclog-files="$keep_arclog_files" \
                      --keep-srvlog-days="$keep_srvlog_days" \
                      -p "$LOCAL_PORT" -U postgres -d postgres >> "$RUN_LOG_FILE" 2>&1

    else 
        "$PGRMAN_BIN" backup -B "$BACKUP_PATH" -D "$DB_DATA_PATH" \
                      -b "$BACKUP_MODE" -Z -C --keep-data-days="$KEEP_DATA_DAYS" \
                      --keep-arclog-files="$keep_arclog_files" \
                      --keep-srvlog-days="$keep_srvlog_days" \
                      -p "$LOCAL_PORT" -U postgres -d postgres \
                      -h "$MASTER_DB_IP" --standby-host "$LOCAL_HOST" \
                      --standby-port "$SLAVE_PORT" >> "$RUN_LOG_FILE" 2>&1

    fi

    if [ "$?" != 0 ]; then
        log "pg_rman backup executing failed" 
        # TODO ZABBIX
        err_exit
    else
        # begin validate backup set
        "$PGRMAN_BIN" validate -B "$BACKUP_PATH" >> "$RUN_LOG_FILE" 2>&1
        if [ "$?" != 0 ]; then
            log "pg_rman validate failed"
            # TODO ZABBIX
            err_exit
        else
            #check the backupset status
            if [ -n "$("$PGRMAN_BIN" show -B "$BACKUP_PATH" | grep ERROR)" ]; then
                log "pg_rman check backupset error!"
                # TODO ZABBIX
                err_exit
            else 
                log "pg_rman executing successfully"
                # TODO ZABBIX
            fi 
        fi  
    fi
}

function remove_script_run_log()
{
    #7 days
    find "${SCRIPT_DIR}"/run_log/pg_rman_backup_* -mmin +10080 -exec rm {} \; >> /dev/null 2>&1
}
##########################################################
# Main Function
##########################################################

#GLOBAL PARAM
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
RUN_LOG_FILE="${SCRIPT_DIR}/run_log/pg_rman_backup_$(date +%Y_%m_%d).log"
PGRMAN_BIN="/usr/pgsql-9.5/bin/pg_rman"
#PGRMAN_BIN="/Users/shiguangsheng/user_program/postgresql/bin/pg_rman"

#INPUT PARAM
DB_NAME=""
LOCAL_HOST=""
BACKUP_PATH=""
DB_DATA_PATH=""
BACKUP_MODE=""
KEEP_DATA_DAYS=""
LOCAL_PORT=""
BACKUP_DB_ROLE=""
MASTER_DB_IP=""
SLAVE_PORT=""

get_param "$@"
#echo "DB_NAME:$DB_NAME, BACKUP_PATH:$BACKUP_PATH, DB_DATA_PATH:$DB_DATA_PATH"
#echo "BACKUP_MODE:$BACKUP_MODE, KEEP_DATA_DAYS:$KEEP_DATA_DAYS, LOCAL_PORT:$LOCAL_PORT"
#echo "BACKUP_DB_ROLE:$BACKUP_DB_ROLE, MASTER_DB_IP:$MASTER_DB_IP, SLAVE_PORT:$SLAVE_PORT"
#echo "LOCAL_HOST:$LOCAL_HOST"

log "=========Begin Backup ========="
log "$@"

check_param || err_exit
check_database_status || err_exit
do_backup || err_exit
remove_script_run_log

log "=========End Backup(Succeed)========="