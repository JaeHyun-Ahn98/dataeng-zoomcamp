"""@bruin
name: ingestion.trips
type: python
image: python:3.11
connection: bq-default

materialization:
  type: table
  strategy: append
@bruin"""

import os
import json
import pandas as pd
import requests
from datetime import datetime
from dateutil.relativedelta import relativedelta
from io import BytesIO

# 핵심: pyarrow가 타임존 DB를 찾지 않도록 환경 변수를 코드 내에서 강제 설정
os.environ['PYARROW_IGNORE_TIMEZONE'] = '1'

def materialize():
    """
    NYC Taxi 데이터를 가져와서 타임존 문제를 방지하기 위해 
    모든 시간 데이터를 'Naive' 상태로 변환 후 반환합니다.
    """
    start_date_str = os.environ.get("BRUIN_START_DATE")
    end_date_str = os.environ.get("BRUIN_END_DATE")
    
    if not start_date_str or not end_date_str:
        raise ValueError("BRUIN_START_DATE와 BRUIN_END_DATE 환경 변수가 필요합니다.")
    
    start_date = datetime.strptime(start_date_str, "%Y-%m-%d")
    end_date = datetime.strptime(end_date_str, "%Y-%m-%d")
    
    vars_json = os.environ.get("BRUIN_VARS", "{}")
    vars_dict = json.loads(vars_json)
    taxi_types = vars_dict.get("taxi_types", ["yellow", "green"])
    
    extracted_at = datetime.now()
    base_url = "https://d37ci6vzurychx.cloudfront.net/trip-data/"
    
    dataframes = []
    current_date = start_date
    
    while current_date <= end_date:
        year = current_date.year
        month = current_date.month
        
        for taxi_type in taxi_types:
            filename = f"{taxi_type}_tripdata_{year}-{month:02d}.parquet"
            url = base_url + filename
            
            try:
                response = requests.get(url, timeout=30)
                response.raise_for_status()
                
                # pyarrow.read_table 대신 pandas.read_parquet 사용 (엔진은 자동으로 선택됨)
                # 이 단계에서 타임존 관련 에러가 날 확률을 줄이기 위해 BytesIO 사용
                df = pd.read_parquet(BytesIO(response.content))
                
                df['taxi_type'] = taxi_type
                
                # 데이터 정제: 모든 datetime 컬럼에서 타임존 제거 (Naive 변환)
                for col in df.select_dtypes(include=['datetime64', 'datetimetz']).columns:
                    # dt.tz_localize(None)은 타임존 정보만 싹 지워줍니다.
                    df[col] = df[col].dt.tz_localize(None)
                
                # 추가 정보 기록
                df["extracted_at"] = extracted_at.replace(tzinfo=None)
                
                dataframes.append(df)
                print(f"성공적으로 다운로드 및 정제 완료: {filename}")
                
            except Exception as e:
                print(f"경고: {filename} 처리 실패 (건너뜀): {e}")
                continue
        
        current_date = current_date + relativedelta(months=1)
    
    if not dataframes:
        raise ValueError("다운로드된 데이터가 없습니다. 날짜 범위를 확인하세요.")
    
# 모든 데이터프레임 합치기
    final_dataframe = pd.concat(dataframes, ignore_index=True)
    
    # [핵심 수정 부분]
    # 모든 datetime/timestamp 컬럼을 찾아 '문자열'로 강제 변환합니다.
    # 이렇게 하면 pyarrow가 타임존 DB를 뒤질 이유 자체가 사라집니다.
    for col in final_dataframe.columns:
        if pd.api.types.is_datetime64_any_dtype(final_dataframe[col]):
            # ISO 형식의 문자열로 변환 (예: "2024-01-01 12:00:00")
            final_dataframe[col] = final_dataframe[col].dt.strftime('%Y-%m-%d %H:%M:%S')
            print(f"Column {col} converted to string to bypass timezone issues.")

    return final_dataframe