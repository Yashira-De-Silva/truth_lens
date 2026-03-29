import sys
import os
sys.path.insert(0, os.path.abspath('apps/ml_service'))
import pandas as pd
from app import get_pipeline_and_data, row_to_article

pipe, df = get_pipeline_and_data()
idx = df.index[0]
try:
    art = row_to_article(pipe, idx, df.loc[idx])
    print("Success:", art)
except Exception as e:
    import traceback
    traceback.print_exc()
