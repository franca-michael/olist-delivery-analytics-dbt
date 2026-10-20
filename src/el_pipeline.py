from datetime import datetime, timezone
 
import pandas as pd
from sqlalchemy import inspect, text
from db_connection import get_oltp_engine, get_olap_engine
 
def run_extract_and_load():
    """Extrai dados do OLTP e carrega no schema 'raw' do OLAP em lotes (chunks)."""
    
    print("Conectando aos bancos de dados...")
    oltp_engine = get_oltp_engine()
    olap_engine = get_olap_engine()
    
    inspector = inspect(oltp_engine)
    olap_inspector = inspect(olap_engine)
    tables = inspector.get_table_names(schema="public")
    
    print(f"Encontradas {len(tables)} tabelas no sistema transacional. Iniciando extração...\n")
    
    for table in tables:
        print(f"Processando tabela: {table}...")
        
        # ler os dados de 10 em 10 mil linhas
        chunk_iterator = pd.read_sql_table(table, oltp_engine, chunksize=10000)
        
        # esvazia a tabela em vez de dropar, para não quebrar as views do dbt que dependem dela
        if olap_inspector.has_table(table, schema="raw"):
            with olap_engine.begin() as conn:
                conn.execute(text(f'ALTER TABLE raw."{table}" ADD COLUMN IF NOT EXISTS _loaded_at timestamptz'))
                conn.execute(text(f'TRUNCATE TABLE raw."{table}"'))

        # horário da carga, igual para todas as linhas desta execução (usado no source freshness do dbt)
        loaded_at = datetime.now(timezone.utc)
        
        # loop para processar pedaço por pedaço
        for chunk in chunk_iterator:
            chunk["_loaded_at"] = loaded_at
            # adiciona as linhas no final da tabela (o pandas cria a tabela se ela ainda não existir)
            chunk.to_sql(table, olap_engine, schema='raw', if_exists='append', index=False)
                
        print(f"Tabela '{table}' copiada com sucesso para o Data Warehouse!\n")
 
    print("Pipeline EL concluído! Os dados brutos estão no Data Warehouse.")
 
if __name__ == "__main__":
    run_extract_and_load()