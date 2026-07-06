# Troubleshooting

## Python command not found

### Problem

`python src/low_pass_filter.py` 실행 시 Python을 찾을 수 없다는 메시지가 나올 수 있습니다.

### Solution

Windows 환경에서는 아래 명령을 사용할 수 있습니다.

```bash
py src/low_pass_filter.py
```

## Output CSV is not created

### Problem

실행 후 `assets/filter_output.csv`가 보이지 않을 수 있습니다.

### Solution

프로젝트 루트 폴더에서 명령을 실행했는지 확인합니다.

```bash
python src/low_pass_filter.py
```

## Test import error

### Problem

테스트 실행 시 `ModuleNotFoundError`가 발생할 수 있습니다.

### Solution

프로젝트 루트에서 다음 명령으로 실행합니다.

```bash
python -m unittest discover -s tests
```

