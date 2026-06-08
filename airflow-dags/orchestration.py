import os
from airflow import DAG
from datetime import datetime, timedelta
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.smtp.notifications.smtp import send_smtp_notification
from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator

AIRBYTE_CONN_ID_FROM_ENV = os.getenv("AIRBYTE_CONNECTION_ID")

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    dag_id="beejan-ride-analytics",
    start_date=datetime(2026, 5, 10),
    schedule="@daily",
    default_args=default_args,
    catchup=False,
    on_failure_callback=[
        send_smtp_notification(
            smtp_conn_id="smtp_default",
            from_email="fakayodeoluseguno@gmail.com",
            to="olukayodeoluseguno@gmail.com",
            subject="Error❌:  The Dag {{ dag.dag_id }} Failed - {{ds}}",
            html_content="""
                                <p><b>DAG:</b> {{ dag.dag_id }}</p>
                                <p><b>Run ID:</b> {{ run_id }}</p>
                                <p><b>Execution Date:</b> {{ ds }}</p>
                                <p><b>Status:</b> Failed</p>
                            """,
        )
    ],

    on_success_callback=[
        send_smtp_notification(
            smtp_conn_id="smtp_default",
            from_email="fakayodeoluseguno@gmail.com",
            to="olukayodeoluseguno@gmail.com",
            subject="Success✅:  The Dag {{ dag.dag_id }} Succeeded - {{ds}}",
            html_content="""
                                <p><b>DAG:</b> {{ dag.dag_id }}</p>
                                <p><b>Run ID:</b> {{ run_id }}</p>
                                <p><b>Execution Date:</b> {{ ds }}</p>
                                <p><b>Status:</b> Succeeded</p>
                            """,
        )
    ]
    
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
    snapshot_dbt = BashOperator(
    task_id="snapshot_dbt",
    bash_command="""
    cd /opt/airflow/dbt &&
    dbt snapshot --profiles-dir .
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
    
    sync_data >> check_freshness >> snapshot_dbt >> run_dbt
