
import pandas as pd
import numpy as np

# 1. Normalizar nombres de columnas
def normalize_column_names(df):
    df.columns = (
        df.columns.str.strip()
        .str.lower()
        .str.replace(' ', '_')
        .str.replace(r'[^\w\s]', '', regex=True)
    )
    return df

# 2. Convertir columnas de fecha al formato datetime
def convert_to_datetime(df):
    for col in df.columns:
        if df[col].dtype == 'object' and df[col].str.match(r'\d{4}-\d{2}-\d{2}').any():
            try:
                df[col] = pd.to_datetime(df[col])
            except Exception:
                pass
    return df

# 3. Limpiar columnas numéricas (quitar símbolos y convertir a int o float)
def clean_numeric_columns(df):
    for col in df.columns:
        if df[col].dtype == 'object':
            if df[col].str.contains(r'\d').any():
                df[col] = df[col].str.replace(r'[^\d.-]', '', regex=True)
                try:
                    df[col] = pd.to_numeric(df[col])
                except:
                    continue
    return df

# 4. Redondear los floats a 2 decimales
def round_floats(df):
    for col in df.select_dtypes(include='float'):
        df[col] = df[col].round(2)
    return df

# 5. Completar nulos en columnas numéricas con 0
def fillna_numeric_with_zero(df):
    for col in df.select_dtypes(include=['int64', 'float64']):
        df[col] = df[col].fillna(0)
    return df

def fillna_numeric(df, value=0):
    """Rellena nulos en columnas numéricas con valor dado."""
    num_cols = df.select_dtypes(include=['int64', 'float64']).columns
    df[num_cols] = df[num_cols].fillna(value)
    return df

# 6. Completar nulos en columnas  categóricas con moda
def fillna_categoricals(df, method='mode'):
    """Rellena nulos en columnas categóricas con el valor más común (modo) o un valor fijo."""
    cat_cols = df.select_dtypes(include='object').columns
    for col in cat_cols:
        if method == 'mode':
            mode_val = df[col].mode().iloc[0] if not df[col].mode().empty else 'Desconocido'
            df[col] = df[col].fillna(mode_val)
        else:
            df[col] = df[col].fillna(method)
    return df

# 7. Ver cuántos nulos y duplicados hay
def report_nulls_duplicates(df):
    print("\nValores nulos por columna:")
    print(df.isnull().sum())
    print(f"\nTotal duplicados: {df.duplicated().sum()}")

# 8. Resumen general del DataFrame
def overview(df):
    print("\nShape:", df.shape)
    print("\nInfo:")
    print(df.info())
    print("\nTipos de datos:")
    print(df.dtypes)

# 9. Eliminar nulos
def drop_nulls(df):
    return df.dropna()

# 10. Eliminar duplicados
def drop_duplicates(df):
    return df.drop_duplicates()

# Función principal para aplicar todas las limpiezas básicas a excepción de limpieza col categorical null
def clean_dataframe(df):
    df = normalize_column_names(df)
    df = convert_to_datetime(df)
    df = clean_numeric_columns(df)
    df = round_floats(df)
    df = fillna_numeric_with_zero(df)
    report_nulls_duplicates(df)
    overview(df)
    return df

def limpiar_columna_total(df, columna='Total'):
    """
    Limpia una columna tipo string con números europeos:
    elimina puntos de miles, reemplaza comas por punto decimal y convierte a float.
    """
    df = df.copy()
    df[columna] = df[columna].astype(str)
    df[columna] = df[columna].str.replace('.', '', regex=False)
    df[columna] = df[columna].str.replace(',', '.', regex=False)
    df[columna] = pd.to_numeric(df[columna], errors='coerce')
    df = df.dropna(subset=[columna])
    return df