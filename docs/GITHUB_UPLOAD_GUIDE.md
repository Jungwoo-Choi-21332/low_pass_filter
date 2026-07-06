# GitHub Upload Guide

이 저장소는 이미 Git으로 초기화되어 있으며, GitHub 원격 저장소에 push할 수 있는 구조입니다.

## Upload

```bash
git add .
git commit -m "Document and implement low pass filter simulation"
git push
```

## Before Submission

- README에서 프로젝트 목적과 실행 방법이 잘 보이는지 확인
- `python src/low_pass_filter.py` 실행 결과 확인
- `python -m unittest discover -s tests` 테스트 통과 확인
- GitHub 저장소 첫 화면에서 README가 정상 표시되는지 확인

