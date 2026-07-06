# GitHub Upload Guide

## 1. GitHub에서 새 저장소 만들기

1. GitHub에 로그인합니다.
2. 오른쪽 위 `+` 버튼을 누르고 `New repository`를 선택합니다.
3. 저장소 이름을 입력합니다.
   - 예시: `portfolio-project`
4. `Public`을 선택합니다.
5. `Add a README file`은 체크하지 않습니다.
6. `Create repository`를 누릅니다.

## 2. 로컬 프로젝트와 GitHub 저장소 연결

아래 명령에서 `your-github-id`와 `repository-name`을 본인 정보로 바꿔서 실행합니다.

```bash
git remote add origin https://github.com/your-github-id/repository-name.git
git branch -M main
git push -u origin main
```

## 3. 업로드 전 확인할 것

- README의 프로젝트명, 기술 스택, 실행 방법을 실제 내용으로 수정했는지 확인
- `assets/`에 스크린샷이 있다면 README에서 이미지 링크를 연결
- 개인정보, 토큰, 비밀번호, 학교 과제 원본 자료 등 공개하면 안 되는 파일이 없는지 확인
- 실행에 필요한 파일이 `src/` 또는 적절한 폴더에 포함되어 있는지 확인

## 4. 포트폴리오 제출 팁

GitHub 링크만 보내기보다 아래 내용을 함께 적으면 좋습니다.

```text
프로젝트명:
개발 기간:
사용 기술:
담당 역할:
핵심 구현:
GitHub:
```

