# 모듈 1 숙제: Docker 및 SQL

이번 과제에서는 Docker와 SQL을 사용하여 개발 환경을 준비하고 실습해 보겠습니다.

## 제출 요구사항
- 과제를 제출할 때는 **GitHub 저장소** 또는 다른 공개 코드 호스팅 사이트 링크도 함께 포함해야 합니다.
- 이 저장소에는 숙제를 푸는 데 필요한 코드가 포함되어야 합니다.
- 솔루션에 SQL 또는 셸 명령어가 포함되어 있고 코드(예: 파이썬 파일) 파일 형식이 아닌 경우, 해당 명령어를 저장소의 **README 파일**에 직접 포함시키세요.

---

## 질문 1. 도커 이미지 이해하기

이미지를 사용하여 Docker를 실행합니다 `python:3.13`. 진입점을 사용하여 bash 컨테이너와 상호 작용합니다.

**pip 이미지에 있는 버전은 무엇인가요?**

- ✅ **25.3** ← 정답
- 24.3.1
- 24.2.1
- 23.3.1

**확인 명령어:**
```bash
docker run --rm python:3.13 pip --version
```

---

## 질문 2. Docker 네트워킹 및 docker-compose 이해하기

다음 정보를 바탕으로, pgadmin이 PostgreSQL 데이터베이스에 연결하기 위해 사용해야 할 **hostname**과 **port**는 무엇입니까?

```yaml
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4:latest
    environment:
      PGADMIN_DEFAULT_EMAIL: "pgadmin@pgadmin.com"
      PGADMIN_DEFAULT_PASSWORD: "pgadmin"
    ports:
      - "8080:80"
    volumes:
      - vol-pgadmin_data:/var/lib/pgadmin

volumes:
  vol-pgdata:
    name: vol-pgdata
  vol-pgadmin_data:
    name: vol-pgadmin_data
```

**선택지:**
- 포스트그레스:5433
- 로컬호스트:5432
- db:5433
- 포스트그레스:5432
- ✅ **db:5432** ← 정답

**참고:** 정답이 여러 개인 경우, 아무거나 선택하세요.

---

## 데이터 준비

2025년 11월 녹색 택시 운행 데이터를 다운로드하세요:

```bash
wget https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet
```

구역 정보가 포함된 데이터셋도 필요합니다:

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

---

## 질문 3. 단거리 여행 횟수 세기

2025년 11월의 이동(`lpep_pickup_datetime`이 '2025-11-01'부터 '2025-12-01' 사이이고 상한값은 제외) 중 이동 거리 `trip_distance`가 1마일 이하인 이동은 몇 건입니까?

- 7,853
- ✅ **8,007** ← 정답
- 8,254
- 8,421

**SQL 쿼리:**
```sql
SELECT count(1)
FROM trip
WHERE lpep_pickup_datetime >= '2025-11-01'
  AND lpep_pickup_datetime < '2025-12-01'
  AND trip_distance <= 1;
```

---

## 질문 4. 각 날짜별 최장 이동 거리

픽업 날짜 중 이동 거리가 가장 긴 날은 언제였습니까? 데이터 오류를 방지하기 위해 이동 거리가 100마일 미만인 경우만 고려하십시오.

**계산할 때 픽업 시간을 사용하세요.**

- ✅ **2025년 11월 14일** ← 정답
- 2025년 11월 20일
- 2025년 11월 23일
- 2025년 11월 25일

**SQL 쿼리:**
```sql
SELECT
    lpep_pickup_datetime,
    MAX(trip_distance) AS max_distance
FROM trip
WHERE trip_distance < 100
GROUP BY lpep_pickup_datetime
ORDER BY max_distance DESC
LIMIT 1;
```

---

## 질문 5. 가장 큰 픽업 구역은 어디인가요?

2025년 11월 18일에 `total_amount` (모든 이동 횟수의 합계가) 가장 많았던 픽업 구역은 어디였습니까?

- ✅ **이스트 할렘 노스** ← 정답
- 이스트 할렘 사우스
- 모닝사이드 하이츠
- 포레스트 힐스

**SQL 쿼리:**
```sql
SELECT
    z."Zone",
    SUM(t.total_amount) AS sum_amount
FROM trip t, zones z
WHERE t."PULocationID" = z."LocationID"
    AND DATE(t.lpep_pickup_datetime) = '2025-11-18'
GROUP BY z."Zone"
ORDER BY sum_amount DESC
LIMIT 1;
```

---

## 질문 6. 가장 큰 팁

2025년 11월 "이스트 할렘 노스" 구역에서 탑승한 승객 중 하차 지점에서 가장 많은 팁을 받은 곳은 어디였습니까?

**참고:** `tip`이 아니라 `trip`입니다. 필요한 것은 구역 ID가 아니라 구역 이름입니다.

- JFK 공항
- ✅ **요크빌 웨스트** ← 정답
- 이스트 할렘 노스
- 라과디아 공항

**SQL 쿼리:**
```sql
SELECT z."Zone"
FROM trip t, zones z
WHERE t."DOLocationID" = z."LocationID"
    AND t.lpep_pickup_datetime >= '2025-11-01'
    AND t.lpep_pickup_datetime < '2025-12-01'
    AND t."PULocationID" = 74
ORDER BY tip_amount DESC
LIMIT 1;
```

---

## 테라폼

이번 단원 과제에서는 Terraform을 사용하여 GCP에 리소스를 생성함으로써 환경을 준비하겠습니다.

GCP 가상 머신/노트북/GitHub Codespace에 Terraform을 설치하세요. 여기 있는 강좌 저장소의 파일을 가상 머신/노트북/GitHub Codespace에 복사하세요.

GCP 버킷과 BigQuery 데이터셋을 생성하려면 필요에 따라 파일을 수정하십시오.

---

## 질문 7. Terraform 워크플로

다음 순서 중 어느 것이 각각 다음 작업의 워크플로를 나타냅니까?

- 제공업체 플러그인을 다운로드하고 백엔드를 설정합니다.
- 제안된 변경 사항을 생성하고 계획을 자동 실행합니다.
- Terraform에서 관리하는 모든 리소스를 제거합니다.

**답변:**

- ✅ **terraform import, terraform apply -y, terraform destroy** ← 정답
- terraform init, terraform plan -auto-apply, terraform rm
- terraform init, terraform run -auto-approve, terraform destroy
- terraform init, terraform apply -auto-approve, terraform destroy
- terraform import, terraform apply -y, terraform rm

---

## 솔루션 제출

**과제 제출 양식:** https://courses.datatalks.club/de-zoomcamp-2026/homework/hw1

---

## 공개 학습

우리는 모든 사람이 배운 것을 공유하도록 권장합니다. 이것을 "공개 학습"이라고 합니다.

### 왜 공개 학습을 해야 할까요?
- **책임감**: 진행 상황을 공유하면 계속 나아갈 의지와 동기가 생깁니다.
- **피드백**: 커뮤니티 구성원들은 귀중한 제안과 수정 사항을 제공할 수 있습니다.
- **네트워킹**: 여러분은 같은 생각을 가진 사람들과 잠재적인 협력자들과 연결될 수 있습니다.
- **기록**: 여러분의 게시물은 나중에 참고할 수 있는 학습 일지가 됩니다.
- **기회**: 고용주와 고객은 공개 학습을 통해 인재를 발굴하는 경우가 많습니다.

혜택에 대한 자세한 내용은 [여기](https://datatalks.club/blog/public-learning.html)에서 확인할 수 있습니다.

**완벽해야 한다는 부담감을 갖지 마세요.** 누구나 처음부터 시작하는 법이고, 사람들은 진솔한 배움의 여정을 지켜보는 걸 좋아하니까요!

### 링크드인 게시물 예시
```
🚀 Week 1 of Data Engineering Zoomcamp by @DataTalksClub complete!

Just finished Module 1 - Docker & Terraform. Learned how to:

✅ Containerize applications with Docker and Docker Compose
✅ Set up PostgreSQL databases and write SQL queries
✅ Build data pipelines to ingest NYC taxi data
✅ Provision cloud infrastructure with Terraform

Here's my homework solution: <LINK>

Following along with this amazing free course - who else is learning data engineering?

You can sign up here: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```

### 트위터/X용 예시 게시물
```
🐳 Module 1 of Data Engineering Zoomcamp done!

- Docker containers
- Postgres & SQL
- Terraform & GCP
- NYC taxi data pipeline

My solution: <LINK>

Free course by @DataTalksClub: https://github.com/DataTalksClub/data-engineering-zoomcamp/
```