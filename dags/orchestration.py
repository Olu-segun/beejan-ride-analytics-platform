import os
from airflow import DAG
from datetime import datetime
from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
from airflow.providers.standard.operators.bash import BashOperator

AIRBYTE_CONN_ID_FROM_ENV = os.getenv("AIRBYTE_CONNECTION_ID")

with DAG(
    dag_id="beejan-ride-analytics",
    schedule="@daily",
    start_date=datetime(2026, 5, 10),
    catchup=False,
) as dag:

    sync_data = AirbyteTriggerSyncOperator(
        task_id="sync_airbyte_connection",
        airbyte_conn_id="airbyte_connection",
        connection_id=AIRBYTE_CONN_ID_FROM_ENV,
        asynchronous=False,
        timeout=3600
    )
    
    check_freshness = BashOperator(
    task_id="check_freshness",
    bash_command="""
    cd /opt/airflow/dbt &&
    dbt source freshness --profiles-dir .
    """
)

    run_dbt = BashOperator(
    task_id="run_dbt",
    bash_command="""
    cd /opt/airflow/dbt &&
    rm -rf target &&
    dbt build --profiles-dir .
    """
)
    
    sync_data >> check_freshness >> run_dbt
