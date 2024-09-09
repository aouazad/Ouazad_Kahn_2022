import pandas as pd

df = pd.read_csv("downloads/Climate Risk Replication/regression_input_Table7.csv")

high_cost_counts = df['high_cost'].value_counts(dropna=False)
