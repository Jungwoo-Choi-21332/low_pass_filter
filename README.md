# Low Pass Filter Simulation

취업 포트폴리오 제출을 위해 정리한 **RC Low Pass Filter 분석 및 시뮬레이션 프로젝트**입니다.  
아날로그 1차 RC 저역통과 필터의 원리를 Python으로 모델링하고, 입력 신호에서 고주파 성분이 감쇠되는 과정을 재현할 수 있도록 구현했습니다.

## Project Overview

Low Pass Filter는 낮은 주파수 성분은 통과시키고 높은 주파수 성분은 감쇠시키는 회로/신호처리 기본 블록입니다.  
이 프로젝트에서는 RC 회로의 차단 주파수와 이산 시간 필터 식을 이용해 필터 동작을 소프트웨어로 검증합니다.

### 목표

- RC 저역통과 필터의 차단 주파수 계산
- 1차 IIR 형태의 저역통과 필터 구현
- 저주파 신호와 고주파 잡음이 섞인 입력 신호 생성
- 필터 적용 전/후 데이터를 CSV로 저장
- 단위 테스트를 통해 계산식과 필터 동작 검증

## Tech Stack

| Category | Stack |
| --- | --- |
| Language | Python 3 |
| Core Libraries | math, csv, argparse, dataclasses |
| Test | unittest |
| Version Control | Git, GitHub |

외부 패키지 없이 Python 표준 라이브러리만 사용하도록 구성했습니다.

## Repository Structure

```text
.
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── PROJECT_REPORT.md
│   ├── FILTER_THEORY.md
│   └── TROUBLESHOOTING.md
├── src/
│   ├── __init__.py
│   └── low_pass_filter.py
└── tests/
    └── test_low_pass_filter.py
```

## Filter Theory

1차 RC Low Pass Filter의 차단 주파수는 다음과 같습니다.

```text
fc = 1 / (2 * pi * R * C)
```

이 프로젝트에서는 연속 시간 RC 필터를 아래의 이산 시간 IIR 형태로 근사했습니다.

```text
alpha = dt / (R * C + dt)
y[n] = y[n-1] + alpha * (x[n] - y[n-1])
```

- `R`: resistance in ohms
- `C`: capacitance in farads
- `dt`: sampling interval
- `alpha`: smoothing coefficient
- `x[n]`: input sample
- `y[n]`: filtered output sample

## How to Run

### 1. Run default simulation

```bash
python src/low_pass_filter.py
```

기본 실행 시 `assets/filter_output.csv` 파일이 생성됩니다.

### 2. Change filter parameters

```bash
python src/low_pass_filter.py --resistance 1000 --capacitance 0.000001 --sample-rate 10000 --duration 0.05
```

### 3. Run tests

```bash
python -m unittest discover -s tests
```

## Example Output

```text
Cutoff frequency: 159.15 Hz
Generated samples: 500
Output CSV: assets/filter_output.csv
```

CSV에는 시간, 원본 입력 신호, 필터 적용 결과가 함께 저장됩니다.

```csv
time,input,output
0.0,0.0,0.0
0.0001,0.3568,0.1370
...
```

## Main Implementation Points

- `RCFilterConfig`: 저항, 커패시터, 샘플링 주파수 등 필터 설정 관리
- `cutoff_frequency()`: RC 회로의 차단 주파수 계산
- `alpha()`: 이산 시간 필터 계수 계산
- `apply_low_pass_filter()`: 입력 샘플에 저역통과 필터 적용
- `generate_mixed_signal()`: 저주파 성분과 고주파 잡음이 섞인 테스트 신호 생성
- `write_csv()`: 분석 결과를 GitHub에서 확인 가능한 CSV 파일로 저장

## Portfolio Value

이 프로젝트는 단순 구현보다 다음 역량을 보여주는 데 초점을 맞췄습니다.

- 전자회로/신호처리 이론을 코드로 변환하는 능력
- 수식 기반 알고리즘을 테스트 가능한 구조로 구현하는 능력
- 결과 재현이 가능한 CLI 프로그램 구성
- GitHub 포트폴리오용 문서화 및 저장소 정리 능력

## Future Improvements

- Matplotlib 기반 파형 시각화 추가
- 주파수 응답 그래프 생성
- 실제 측정 데이터 CSV 입력 기능 추가
- Verilog 또는 SPICE 시뮬레이션 결과와 비교

