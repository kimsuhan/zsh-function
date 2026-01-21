pr() {
    local current_branch=$(git branch --show-current)

    echo "🚀 Creating GitHub PR for branch: \033[1;34m$current_branch\033[0m"
    echo "───────────────────────────────────────────────"

    # Create PR using GitHub CLI
    if gh pr create; then
        echo "✅ PR created successfully!"
    else
        echo "❌ Failed to create PR"
        return 1
    fi

    echo ""
    echo "🔄 Switching to dev branch..."
    if git switch dev; then
        echo "✅ Switched to dev branch"
    else
        echo "❌ Failed to switch to dev branch"
        return 1
    fi

    echo ""
    echo "📥 Pulling latest changes..."
    if git pull; then
        echo "✅ Successfully pulled latest changes"
    else
        echo "❌ Failed to pull changes"
        return 1
    fi

    echo ""
    echo "🗑️  Deleting branch: \033[1;31m$current_branch\033[0m"
    if git branch -d "$current_branch"; then
        echo "✅ Branch deleted successfully"
    else
        echo "❌ Failed to delete branch"
        return 1
    fi

    echo ""
    echo "🎉 \033[1;32mAll done! PR created and cleanup completed.\033[0m"
}
