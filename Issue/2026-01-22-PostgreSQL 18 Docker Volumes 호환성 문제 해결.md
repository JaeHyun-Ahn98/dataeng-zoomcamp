# 📝 PostgreSQL 18 Docker Volumes 호환성 문제 해결

## 1. 문제 상황 및 에러 로그

Docker Compose로 PostgreSQL 18 컨테이너를 실행하려고 했으나, 다음과 같은 오류가 발생했습니다.

```
Error: in 18+, these Docker images are configured to store database data in a
       format which is compatible with "pg_ctlcluster" (specifically, using
       major-version-specific directory names).  This better reflects how
       PostgreSQL itself works, and how upgrades are to be performed.

       Counter to that, there appears to be PostgreSQL data in:
         /var/lib/postgresql/data (unused mount/volume)

       The suggested container configuration for 18+ is to place a single mount
       at /var/lib/postgresql which will then place PostgreSQL data in a
       subdirectory, allowing usage of "pg_upgrade --link" without mount point
       boundary issues.
```

### 증상:
- `docker-compose ps`에서 `pgdatabase` 컨테이너가 실행되지 않음
- Kestra 워크플로우에서 PostgreSQL 연결 실패 (`UnknownHostException: pgdatabase`)
- 컨테이너 로그에서 PostgreSQL 18의 새로운 데이터 저장 방식과 충돌

## 2. 원인 분석

### PostgreSQL 18의 주요 변경사항:
- **데이터 저장 구조 변경**: PostgreSQL 18부터는 버전별 서브디렉토리를 사용하여 데이터를 저장
- **권장 마운트 경로**: `/var/lib/postgresql` 전체를 마운트해야 호환성 보장
- **이전 방식과의 비호환**: `/var/lib/postgresql/data` 하위 경로 마운트는 더 이상 지원되지 않음

### 현재 파일 vs 강의 파일 비교:

**문제가 있었던 현재 파일:**
```yaml
pgdatabase:
  image: postgres:18
  volumes:
    - ny_taxi_postgres_data:/var/lib/postgresql/data  # ❌ 호환되지 않음
```

**정상 작동하는 강의 파일:**
```yaml
pgdatabase:
  image: postgres:18
  volumes:
    - ny_taxi_postgres_data:/var/lib/postgresql  # ✅ 전체 경로 마운트
```

## 3. 해결 과정

### 3.1 초기 진단
- `docker-compose ps`로 컨테이너 상태 확인
- `pgdatabase`가 목록에 없음을 발견
- `docker-compose logs pgdatabase`로 상세 오류 확인

### 3.2 PostgreSQL 버전 다운그레이드 (임시 해결 방법)
```yaml
pgdatabase:
  image: postgres:17  # 18 → 17로 변경
```

### 3.3 최종 해결: Volumes 경로 수정
강의에서 제공하는 올바른 경로로 수정:

```yaml
pgdatabase:
  image: postgres:18  # 원래 버전 유지
  volumes:
    - ny_taxi_postgres_data:/var/lib/postgresql  # 전체 경로로 변경
```

### 3.4 컨테이너 재시작
```bash
docker-compose down
docker-compose up -d
```

## 4. 결과 확인

### 해결 후 상태:
```bash
$ docker-compose ps
NAME                                          IMAGE                COMMAND                   SERVICE           CREATED       STATUS                   PORTS
02-workflow-orchestration-pgdatabase-1        postgres:18          "docker-entrypoint.s…"   pgdatabase        2 minutes ago Up 2 minutes             0.0.0.0:5432->5432/tcp
02-workflow-orchestration-pgadmin-1           dpage/pgadmin4       "/entrypoint.sh"          pgadmin           2 minutes ago Up 2 minutes             0.0.0.0:8085->80/tcp
# ... 다른 컨테이너들
```

### Kestra 워크플로우 정상 실행:
- PostgreSQL 연결 성공
- 데이터 파이프라인 정상 작동

## 5. 학습 포인트

### Docker PostgreSQL 버전 관리:
- **메이저 버전 업그레이드 시**: 데이터 저장 방식 변경 확인 필수
- **Volumes 마운트 경로**: 공식 문서 권장사항 준수
- **강의 코드 참고**: 최신 버전에서 이미 해결된 문제들은 강의 코드에서 확인

### 트러블슈팅 접근법:
1. **컨테이너 상태 확인**: `docker-compose ps`
2. **로그 분석**: `docker-compose logs [service]`
3. **공식 문서 확인**: Docker Hub PostgreSQL 이미지 변경사항
4. **강의 코드 비교**: 같은 문제가 이미 해결되었을 수 있음

### PostgreSQL 18 특징:
- **pg_ctlcluster 호환**: 클러스터 관리 도구와의 호환성 향상
- **데이터 디렉토리 구조**: `/var/lib/postgresql/18/main/` 형태로 저장
- **업그레이드 용이성**: `pg_upgrade --link` 지원

## 6. 결론

**PostgreSQL 18의 데이터 저장 방식 변경으로 인한 Docker volumes 호환성 문제**였습니다.

**핵심 해결책**: `/var/lib/postgresql/data` → `/var/lib/postgresql`로 마운트 경로 수정

이제 Kestra 워크플로우가 PostgreSQL에 정상적으로 연결되어 데이터 파이프라인을 실행할 수 있습니다.