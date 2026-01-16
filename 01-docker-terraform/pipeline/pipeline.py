# 시스템 관련 기능을 사용하기 위해 sys 모듈을 가져옵니다. (예: 명령줄 인자 처리)
import sys 

# 데이터 처리를 위한 pandas 라이브러리를 pd라는 별칭으로 가져옵니다.
import pandas as pd 

# sys.argv[0]은 스크립트 파일 이름, sys.argv[1]부터 실제 인자입니다.
# 스크립트 실행 시 전달된 모든 명령줄 인자들을 출력합니다.
print('arguments:', sys.argv) 

# 첫 번째 명령줄 인자(예: '12')를 정수(int)로 변환하여 month 변수에 저장합니다.
# 인자가 없으면 IndexError가 발생합니다.
month = int(sys.argv[1]) 

# 'day'와 'num_passengers' 컬럼을 가진 간단한 pandas DataFrame을 생성합니다.
df = pd.DataFrame({"day": [1, 2], "num_passengers": [3, 4]}) 

# DataFrame에 'month'라는 새 컬럼을 추가하고, 위에서 받은 month 값을 모든 행에 채웁니다.
df['month'] = month 

# 생성된 DataFrame의 처음 몇 줄을 출력하여 데이터를 확인합니다.
print(df.head()) 

# DataFrame의 데이터를 Parquet 형식의 파일로 저장합니다.
# 파일 이름은 'output_12.parquet'처럼 month 값에 따라 동적으로 생성됩니다.
df.to_parquet(f'output_{month}.parquet') 

# 파이프라인이 어떤 month 값으로 실행되었는지 최종 메시지를 출력합니다.
print(f'Hello, pipeline, month={month}') 