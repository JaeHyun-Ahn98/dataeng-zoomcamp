import dataclasses # 데이터 클래스 처리를 위한 도구
import json # 데이터를 주고받기 쉬운 글자(JSON)로 바꾸기 위한 도구
import sys # 시스템 경로 설정을 위한 도구
import time # 시간 지연(sleep)을 주기 위한 도구
from pathlib import Path # 파일 경로 처리를 위한 도구

# 현재 파일 위치 기준으로 상위 폴더(src)를 파이썬 경로에 추가 (models.py를 찾기 위함)
sys.path.insert(0, str(Path(__file__).parent.parent))

import pandas as pd # 표 형태의 데이터를 다루는 도구
from kafka import KafkaProducer # Kafka(Redpanda)에 데이터를 보내는 엔진
from models import Ride, ride_from_row # 우리가 만든 설계도와 변환기 불러오기

# NYC 택시 데이터 주소 (2025년 11월 데이터)
url = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2025-11.parquet"
# 필요한 컬럼(열)만 지정
columns = ['PULocationID', 'DOLocationID', 'trip_distance', 'total_amount', 'tpep_pickup_datetime']
# 데이터 다운로드 후 위에서부터 1000줄만 읽어오기
df = pd.read_parquet(url, columns=columns).head(1000)

def ride_serializer(ride): # Ride 객체를 전송 가능한 바이트로 직렬화하는 함수
    ride_dict = dataclasses.asdict(ride) # 객체를 딕셔너리 형태로 변환
    json_str = json.dumps(ride_dict) # 딕셔너리를 JSON 문자열로 변환
    return json_str.encode('utf-8') # 문자열을 바이트(0101)로 최종 변환

server = 'localhost:9092' # 우리가 띄운 Redpanda 서버 주소

producer = KafkaProducer( # 전송 엔진 설정
    bootstrap_servers=[server], # 서버 주소 연결
    value_serializer=ride_serializer # 보낼 때마다 위에서 만든 직렬화 함수 사용
)

t0 = time.time() # 시작 시간 기록

topic_name = 'rides' # Redpanda 안의 'rides'라는 이름의 우편함(토픽) 지정

for _, row in df.iterrows(): # 1000개의 데이터를 한 줄씩 반복 처리
    ride = ride_from_row(row) # 한 줄 데이터를 Ride 객체 설계도에 맞게 변환
    producer.send(topic_name, value=ride) # Redpanda의 'rides' 토픽으로 데이터 전송
    print(f"Sent: {ride}") # 화면에 보낸 데이터 출력
    time.sleep(0.01) # 0.01초간 대기 (실시간 스트리밍 시뮬레이션)

producer.flush() # 아직 네트워크 통로에 남아있는 데이터가 있다면 모두 밀어내기

t1 = time.time() # 종료 시간 기록
print(f'took {(t1 - t0):.2f} seconds') # 총 걸린 시간 출력