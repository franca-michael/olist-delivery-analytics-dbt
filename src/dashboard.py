import streamlit as st
import pandas as pd
import plotly.express as px
from db_connection import get_olap_engine

# 1. Configuração inicial da página
st.set_page_config(page_title="E-commerce Analytics", page_icon="🛒", layout="wide")
st.title("🛒 Dashboard de E-commerce (Camada Ouro)")
st.markdown("Visualização interativa construída a partir do Data Warehouse (dbt).")

# 2. Função para carregar dados com Cache (Performance)
@st.cache_data
def load_data():
    try:
        engine = get_olap_engine()
        query = "SELECT * FROM analytics.fct_customer_orders;"
        df = pd.read_sql(query, engine)
        
        # Conversão de datas
        df['purchased_at'] = pd.to_datetime(df['purchased_at'])
        df['delivered_at'] = pd.to_datetime(df['delivered_at'])
        return df
    except Exception as e:
        st.error(f"Erro ao conectar no banco de dados: {e}")
        return pd.DataFrame()

# Carregando os dados brutos
with st.spinner("Carregando dados do Data Warehouse..."):
    df_raw = load_data()

if not df_raw.empty:
    
    st.sidebar.header("⚙️ Filtros do Painel")
    
    # Lista de estados para filtro
    lista_estados = ["Todos"] + sorted(df_raw['state'].dropna().unique().tolist())
    estado_selecionado = st.sidebar.selectbox("Selecione o Estado:", lista_estados)
    
    # Filtro no DataFrame inteiro
    if estado_selecionado != "Todos":
        df = df_raw[df_raw['state'] == estado_selecionado].copy()
    else:
        df = df_raw.copy()

    # Renderiza os gráficos
    if not df.empty:
        # 3. Criando KPIs
        st.subheader(f"📊 Visão Geral - {estado_selecionado if estado_selecionado != 'Todos' else 'Brasil'}")
        col1, col2, col3 = st.columns(3)
        
        total_pedidos = len(df)
        cidades_unicas = df['city'].nunique()
        pedidos_entregues = len(df[df['order_status'] == 'delivered'])
        taxa_entrega = (pedidos_entregues / total_pedidos) * 100 if total_pedidos > 0 else 0

        col1.metric("Total de Pedidos", f"{total_pedidos:,}".replace(',', '.'))
        col2.metric("Cidades Alcançadas", cidades_unicas)
        col3.metric("Taxa de Entrega", f"{taxa_entrega:.1f}%")

        st.divider()

        # 4. Criando Gráficos com Plotly
        col_chart1, col_chart2 = st.columns(2)

        with col_chart1:
            # Se "Todos", mostra Estados. Se for 1 Estado, mostra Cidades.
            if estado_selecionado == "Todos":
                col_group = 'state'
                titulo_barras = "Top 10 Estados por Volume de Pedidos"
                nome_coluna = "Estado"
            else:
                col_group = 'city'
                titulo_barras = f"Top 10 Cidades ({estado_selecionado}) por Volume"
                nome_coluna = "Cidade"

            st.subheader(titulo_barras)
            df_bar = df[col_group].value_counts().reset_index().head(10)
            df_bar.columns = [nome_coluna, 'Quantidade']
            
            fig_bar = px.bar(df_bar, x=nome_coluna, y='Quantidade', 
                             color='Quantidade', color_continuous_scale='Blues')
            st.plotly_chart(fig_bar, use_container_width=True)

        with col_chart2:
            st.subheader("Proporção de Status dos Pedidos")
            # Gráfico Treemap
            df_status = df['order_status'].value_counts().reset_index()
            df_status.columns = ['Status', 'Quantidade']
            
            fig_treemap = px.treemap(df_status, path=['Status'], values='Quantidade',
                                     color='Quantidade', color_continuous_scale='Teal')
            
            # Removemos as margens para o Treemap ficar maior
            fig_treemap.update_layout(margin=dict(t=0, l=0, r=0, b=0))
            st.plotly_chart(fig_treemap, use_container_width=True)

        st.divider()
        
        # 5. Evolução Temporal (Gráfico de Linha)
        st.subheader("📈 Evolução de Compras (Mensal)")
        df['mes_ano'] = df['purchased_at'].dt.to_period('M').astype(str)
        df_timeline = df.groupby('mes_ano').size().reset_index(name='Quantidade')
        df_timeline = df_timeline.sort_values('mes_ano')
        
        fig_timeline = px.line(df_timeline, x='mes_ano', y='Quantidade', markers=True)
        st.plotly_chart(fig_timeline, use_container_width=True)

    else:
        st.warning("Nenhum pedido encontrado para o filtro selecionado.")
else:
    st.warning("Nenhum dado encontrado no banco. Verifique se o dbt rodou corretamente.")