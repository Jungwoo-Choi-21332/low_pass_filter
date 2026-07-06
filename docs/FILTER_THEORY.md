# Filter Theory

## Low Pass Filter

Low Pass Filter는 특정 주파수보다 낮은 성분은 통과시키고 높은 성분은 감쇠시키는 필터입니다.  
RC 회로에서는 저항과 커패시터의 조합으로 간단한 1차 저역통과 필터를 만들 수 있습니다.

## RC Time Constant

```text
tau = R * C
```

`tau`는 필터가 입력 변화에 얼마나 빠르게 반응하는지 결정합니다.  
`tau`가 커질수록 출력은 더 느리게 변하고, 고주파 성분은 더 강하게 감쇠됩니다.

## Cutoff Frequency

```text
fc = 1 / (2 * pi * R * C)
```

차단 주파수 `fc`는 출력 크기가 입력 대비 약 `-3 dB`가 되는 지점입니다.

## Digital Approximation

Python 시뮬레이션에서는 연속 시간 회로를 다음 이산 시간 식으로 근사했습니다.

```text
alpha = dt / (tau + dt)
y[n] = y[n-1] + alpha * (x[n] - y[n-1])
```

이 구조는 직전 출력값과 현재 입력값의 차이를 이용해 출력이 천천히 따라가도록 만듭니다.

