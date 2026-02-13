# /// script
# dependencies = ["pandas", "pandas-gbq", "pyarrow"]
# ///

import pandas as pd

def materialize():
    print("Ingesting data...")
    # ... 기존 코드 ...
    return pd.DataFrame({'test': [1]})