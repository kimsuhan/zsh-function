newbranch() {
    echo "🌿 Git Branch Creator"
    echo "───────────────────────────────────────────────"

    # 1. 카테고리 선택
    echo "📂 브랜치 카테고리를 선택하세요:"
    echo "  1) feature    - 새 기능 개발"
    echo "  2) bugfix     - 버그 수정"
    echo "  3) hotfix     - 긴급 수정"
    echo "  4) refactor   - 리팩토링"
    echo "  5) chore      - 환경 설정 & 디펜던시 업데이트"
    echo "  6) docs       - 문서 관련"
    echo "  7) test       - 테스트"
    echo "  8) experiment - 시도적 기능"
    echo ""
    echo -n "카테고리 번호 입력 (1-8): "
    read category_num

    case $category_num in
        1) category="feature" ;;
        2) category="bugfix" ;;
        3) category="hotfix" ;;
        4) category="refactor" ;;
        5) category="chore" ;;
        6) category="docs" ;;
        7) category="test" ;;
        8) category="experiment" ;;
        *)
            echo "❌ 잘못된 선택입니다. 1-8 사이의 숫자를 입력하세요."
            return 1
            ;;
    esac

    echo "✅ 선택된 카테고리: $category"
    echo ""

    # 2. 코드 입력
    echo "🏷️  코드를 입력하세요 (예: TS-53, 빈값일 경우 no-ref):"
    echo -n "코드: "
    read code

    if [[ -z "$code" ]]; then
        code="no-ref"
    fi

    echo "✅ 코드: $code"
    echo ""

    # 3. 브랜치명 입력
    echo "📝 브랜치명을 입력하세요 (예: wallet-plan-search):"
    echo -n "브랜치명: "
    read branch_name

    if [[ -z "$branch_name" ]]; then
        echo "❌ 브랜치명은 필수입니다."
        return 1
    fi

    echo "✅ 브랜치명: $branch_name"
    echo ""

    # 최종 브랜치명 구성
    final_branch="$category/$code/$branch_name"
    echo "🎯 생성될 브랜치: \033[1;32m$final_branch\033[0m"
    echo ""

    # 현재 브랜치 확인
    current_branch=$(git branch --show-current)
    echo "📍 현재 브랜치: $current_branch"

    # dev 브랜치로 이동 (현재가 dev가 아닌 경우)
    if [[ "$current_branch" != "dev" ]]; then
        echo "🔄 dev 브랜치로 이동 중..."
        if ! git switch dev; then
            echo "❌ dev 브랜치로 이동 실패"
            return 1
        fi
        echo "✅ dev 브랜치로 이동 완료"
    else
        echo "✅ 이미 dev 브랜치에 있습니다"
    fi

    # git pull로 최신 상태 유지
    echo ""
    echo "📥 최신 변경사항 가져오는 중..."
    if ! git pull; then
        echo "❌ git pull 실패"
        return 1
    fi
    echo "✅ 최신 상태로 업데이트 완료"

    # 새 브랜치 생성 및 이동
    echo ""
    echo "🌱 새 브랜치 생성 중..."
    if git switch -c "$final_branch"; then
        echo "✅ 브랜치 \033[1;32m$final_branch\033[0m 생성 및 이동 완료!"
    else
        echo "❌ 브랜치 생성 실패"
        return 1
    fi

    echo ""
    echo "🎉 \033[1;32m브랜치 생성이 완료되었습니다!\033[0m"
}
