# Usage: aws-instance-list [--ssm] [검색어]
# Example: aws-instance-list
# Example: aws-instance-list ility-hub
# Example: aws-instance-list --ssm ility-hub
aws-instance-list() {
    local use_ssm=false
    local search_term=""
    
    # 인자 파싱
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ssm)
                use_ssm=true
                shift
                ;;
            *)
                search_term="$1"
                shift
                ;;
        esac
    done
    
    if [[ "$use_ssm" == true ]]; then
        if [[ -n "$search_term" ]]; then
            echo "📋 SSM에 등록된 인스턴스 목록 (검색어: '$search_term'):"
        else
            echo "📋 SSM에 등록된 인스턴스 목록:"
        fi
        echo ""
        
        local query_cmd="aws ssm describe-instance-information"
        
        if [[ -n "$search_term" ]]; then
            # SSM의 경우 ComputerName으로 필터링
            query_cmd="$query_cmd --query \"InstanceInformationList[?contains(ComputerName, '$search_term')].[InstanceId,ComputerName,PlatformType,PlatformVersion,IPAddress,PingStatus]\""
        else
            query_cmd="$query_cmd --query 'InstanceInformationList[*].[InstanceId,ComputerName,PlatformType,PlatformVersion,IPAddress,PingStatus]'"
        fi
        
        query_cmd="$query_cmd --output table --no-cli-pager"
        
        eval "$query_cmd" 2>/dev/null
        
        if [ $? -ne 0 ]; then
            echo "❌ SSM 인스턴스 목록을 가져오는데 실패했습니다."
            echo "💡 AWS CLI가 설치되어 있고, 올바른 자격 증명이 설정되어 있는지 확인하세요."
            return 1
        fi
    else
        if [[ -n "$search_term" ]]; then
            echo "📋 EC2 인스턴스 목록 (검색어: '$search_term'):"
        else
            echo "📋 EC2 인스턴스 목록:"
        fi
        echo ""
        
        local query_cmd="aws ec2 describe-instances"
        
        if [[ -n "$search_term" ]]; then
            # Name 태그로 필터링
            query_cmd="$query_cmd --filters \"Name=tag:Name,Values=*${search_term}*\""
        fi
        
        query_cmd="$query_cmd --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==\`Name\`].Value|[0],InstanceType,PublicIpAddress,PrivateIpAddress]'"
        query_cmd="$query_cmd --output table --no-cli-pager"
        
        eval "$query_cmd" 2>/dev/null
        
        if [ $? -ne 0 ]; then
            echo "❌ EC2 인스턴스 목록을 가져오는데 실패했습니다."
            echo "💡 AWS CLI가 설치되어 있고, 올바른 자격 증명이 설정되어 있는지 확인하세요."
            return 1
        fi
    fi
}
