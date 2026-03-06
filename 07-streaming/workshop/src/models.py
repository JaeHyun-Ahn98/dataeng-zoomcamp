import json # JSON 형식을 다루기 위한 도구
from dataclasses import dataclass # 데이터를 담는 전용 클래스를 만들기 위한 도구


@dataclass # 데이터를 저장하는 용도라는 것을 명시 (데이터 클래스)
class Ride: # 'Ride'라는 이름의 데이터 틀 정의
    PULocationID: int # 승차 위치 ID (정수)
    DOLocationID: int # 하차 위치 ID (정수)
    trip_distance: float # 이동 거리 (실수)
    total_amount: float # 총 요금 (실수)
    tpep_pickup_datetime: int  # 승차 시간 (컴퓨터가 읽기 편한 숫자 형태)


def ride_from_row(row): # Pandas의 한 줄 데이터를 Ride 객체로 바꾸는 함수
    return Ride(
        PULocationID=int(row['PULocationID']), # 엑셀의 PULocationID를 정수로 변환
        DOLocationID=int(row['DOLocationID']), # 엑셀의 DOLocationID를 정수로 변환
        trip_distance=float(row['trip_distance']), # 이동 거리를 소수점 있는 숫자로 변환
        total_amount=float(row['total_amount']), # 요금을 소수점 있는 숫자로 변환
        # 시간을 타임스탬프(초)로 바꾼 뒤 1000을 곱해 밀리초 단위로 저장
        tpep_pickup_datetime=int(row['tpep_pickup_datetime'].timestamp() * 1000), 
    )


def ride_deserializer(data): # Redpanda에서 받은 바이트 데이터를 다시 파이썬 객체로 바꾸는 함수
    json_str = data.decode('utf-8') # 0101 바이트 데이터를 글자(UTF-8)로 해독
    ride_dict = json.loads(json_str) # 글자를 파이썬의 딕셔너리(Key-Value) 형태로 변환
    return Ride(**ride_dict) # 딕셔너리 내용을 바탕으로 Ride 객체 생성