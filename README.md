# Verilog FIR Low-Pass Filter

8비트 signed 입력을 처리하는 **19탭 FIR 저역통과 필터**입니다. 대칭 계수와 shift/add 연산으로 상수 곱셈을 구성하고, 파이프라인 가산 트리와 출력 포화 처리를 적용했습니다.

## 설계 구조

```text
xn → 19-sample delay line → symmetric pair sums → shift/add
   → registered adder tree → arithmetic shift (÷256) → saturation → yn
```

| 항목 | 구현 |
| --- | --- |
| 입출력 | 8비트 signed, −128 ~ 127 |
| 필터 | 19탭 대칭 FIR |
| 계수 연산 | 대칭 샘플 합산, 0 계수 생략, shift/add 상수 곱셈 |
| 누산 | 19 → 20 → 21비트 레지스터 가산 트리 |
| 출력 | 산술 우측 시프트 8비트, 포화 처리, 출력 레지스터 |
| 리셋 | Active-low 비동기 리셋 (`n_rst`) |
| 클록 제약 | 3 ns (합성 목표값) |

RTL에 구현된 계수는 다음과 같습니다. 계수 합은 244이며, 스케일링 후 DC 이득은 244/256입니다.

```text
[6, 0, -8, -14, -12, 0, 19, 41, 58, 64,
 58, 41, 19, 0, -12, -14, -8, 0, 6]
```

## 파일 구성

```text
rtl/lpf.v                    필터 RTL
sim/tb_lpf.v                 테스트벤치
sim/xn_data.txt              입력 샘플 3,000개 (8비트 hex)
synthesis/lpf.con           합성 제약
synthesis/main_syn.tcl      Design Compiler 실행 스크립트
results/lpf_mapped.v        합성된 게이트 레벨 넷리스트
results/lpf.sdf             합성 후 지연 정보
docs/lpf_presentation.pptx  설계 발표자료
```

[RTL](rtl/lpf.v) · [테스트벤치](sim/tb_lpf.v) · [합성 제약](synthesis/lpf.con) · [발표자료](docs/lpf_presentation.pptx)

## RTL 시뮬레이션

Icarus Verilog가 설치된 환경에서 저장소 루트를 기준으로 실행합니다.

```sh
iverilog -g2012 -s tb_lpf -o lpf_sim rtl/lpf.v sim/tb_lpf.v
vvp lpf_sim
```

테스트벤치는 입력 샘플 3,000개를 순서대로 인가한 뒤 50클록을 더 진행하고 종료합니다. 입출력은 콘솔과 `lpf.vcd`에 기록되며, 자동 정답 비교 기능은 포함되어 있지 않습니다.

FSDB를 지원하는 시뮬레이터에서는 `FSDB` 매크로를 정의하면 기존 FSDB 덤프를 사용할 수 있습니다. 데이터·SDF 경로는 현재 폴더 구조에 맞췄고, 3 ns 클록이 정수 나눗셈으로 2 ns가 되지 않도록 반주기 계산을 `T_CLK/2.0`으로 수정했습니다. 필터 RTL은 원본 그대로입니다.

## 합성 자료

넷리스트와 SDF는 원본 프로젝트의 Synopsys Design Compiler 산출물입니다. SDF 헤더에는 `saed32rvt_ss0p95v125c`, 0.95 V, 125 °C 조건이 기록되어 있습니다. 클록 제약 3 ns는 달성 주파수를 의미하지 않습니다.

`main_syn.tcl`에서 참조하는 `0_Script/` 하위 스크립트와 표준셀 라이브러리는 제공된 프로젝트에 포함되어 있지 않습니다. 합성 재실행에는 해당 환경이 추가로 필요합니다. 게이트 레벨 시뮬레이션은 RTL 대신 `results/lpf_mapped.v`와 해당 셀 모델을 사용하고, `SDF_PRE`를 정의해 SDF를 적용합니다.

제약 파일은 원본을 보존했으며, `n_rst`를 별도 클록으로 정의한 설정도 포함합니다. 새로운 환경에서 재사용할 때는 리셋 타이밍 의도를 확인해야 합니다. 이 저장소 정리 과정에서 시뮬레이션이나 합성을 새로 수행하지 않았습니다.
