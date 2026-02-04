aws-tunneling() {
    local data_file="$HOME/.zshrc_function/data/aws-tunneling.json"
    local name="$1"

    if ! command -v jq >/dev/null 2>&1; then
        echo "❌ jq가 설치되어 있지 않습니다. (brew install jq)"
        return 1
    fi

    if [[ ! -f "$data_file" ]]; then
        echo "❌ 설정 파일이 없습니다: $data_file"
        return 1
    fi

    if [[ -z "$name" || "$name" == "--list" || "$name" == "-l" ]]; then
        echo "📋 등록된 터널 목록:"
        jq -r 'to_entries[] | " - \(.key)\t\(.value.desc // "")"' "$data_file"
        return 0
    fi

    if ! jq -e --arg name "$name" '.[$name]' "$data_file" >/dev/null 2>&1; then
        echo "❌ '$name' 항목을 찾을 수 없습니다."
        echo "💡 사용 가능 목록: aws-tunneling --list"
        return 1
    fi

    local profile region target_tag_name target_instance_id host port local_port desc
    profile="$(jq -r --arg name "$name" '.[$name].profile // empty' "$data_file")"
    region="$(jq -r --arg name "$name" '.[$name].region // empty' "$data_file")"
    target_tag_name="$(jq -r --arg name "$name" '.[$name].target_tag_name // empty' "$data_file")"
    target_instance_id="$(jq -r --arg name "$name" '.[$name].target_instance_id // empty' "$data_file")"
    host="$(jq -r --arg name "$name" '.[$name].host // empty' "$data_file")"
    port="$(jq -r --arg name "$name" '.[$name].port // empty' "$data_file")"
    local_port="$(jq -r --arg name "$name" '.[$name].local_port // empty' "$data_file")"
    desc="$(jq -r --arg name "$name" '.[$name].desc // empty' "$data_file")"

    if [[ -z "$host" || -z "$port" || -z "$local_port" || "$host" == "null" || "$port" == "null" || "$local_port" == "null" ]]; then
        echo "❌ 필수 값이 비어 있습니다. (host, port, local_port)"
        return 1
    fi

    local -a aws_args
    aws_args=()
    [[ -n "$profile" ]] && aws_args+=(--profile "$profile")
    [[ -n "$region" ]] && aws_args+=(--region "$region")

    local target_id
    if [[ -n "$target_instance_id" ]]; then
        target_id="$target_instance_id"
    else
        if [[ -z "$target_tag_name" ]]; then
            echo "❌ target_tag_name 또는 target_instance_id가 필요합니다."
            return 1
        fi

        target_id="$(aws ec2 describe-instances \
            --filters "Name=tag:Name,Values=${target_tag_name}" "Name=instance-state-name,Values=running" \
            --query "Reservations[0].Instances[0].InstanceId" \
            --output text \
            "${aws_args[@]}")"
    fi

    if [[ -z "$target_id" || "$target_id" == "None" || "$target_id" == "null" ]]; then
        echo "❌ 대상 인스턴스를 찾지 못했습니다."
        return 1
    fi

    local params
    params="$(jq -n --arg host "$host" --arg port "$port" --arg local_port "$local_port" \
        '{host:[$host],portNumber:[$port],localPortNumber:[$local_port]}')"

    echo "\n🚀 터널링을 시작합니다: $name"
    [[ -n "$desc" ]] && echo "📝 $desc"
    echo "🎯 target: $target_id"
    echo "🔁 ${host}:${port} -> localhost:${local_port}"
    echo "💡 종료하려면 Ctrl + C 를 누르세요.\n"

    while true; do
        aws ssm start-session \
            --target "$target_id" \
            --document-name AWS-StartPortForwardingSessionToRemoteHost \
            --parameters "$params" \
            "${aws_args[@]}"

        exit_code=$?
        if [ $exit_code -eq 0 ]; then
            echo "\n⚠️  세션이 만료되었습니다. 3초 후 재연결합니다..."
            sleep 3
            continue
        fi

        echo "\n🛑 사용자에 의해 종료되었습니다."
        break
    done
}
