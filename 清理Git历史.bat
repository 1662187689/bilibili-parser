@echo off
chcp 65001 >nul
echo ========================================
echo    清理 Git 历史中的敏感信息
echo ========================================
echo.
echo ⚠️  警告：此操作会重写 Git 历史！
echo     - 所有 commit 的哈希值会改变
echo     - 需要强制推送（git push --force）
echo     - 可能影响其他协作者
echo.
set /p confirm="确定要继续吗？(输入 YES 继续): "
if not "!confirm!"=="YES" (
    echo 已取消
    pause
    exit /b 0
)

echo.
echo [1/3] 正在修改 Git 配置...
git config --global user.email "noreply@github.com"
git config --global user.name "1662187689"
echo ✅ Git 配置已更新

echo.
echo [2/3] 正在重写 Git 历史（这可能需要几分钟）...
git filter-branch --env-filter "if [ \"$GIT_COMMITTER_EMAIL\" = \"16662187689@qq.com\" ]; then export GIT_COMMITTER_EMAIL=\"noreply@github.com\"; export GIT_COMMITTER_NAME=\"1662187689\"; fi; if [ \"$GIT_AUTHOR_EMAIL\" = \"16662187689@qq.com\" ]; then export GIT_AUTHOR_EMAIL=\"noreply@github.com\"; export GIT_AUTHOR_NAME=\"1662187689\"; fi" --tag-name-filter cat -- --branches --tags

if %errorlevel% equ 0 (
    echo.
    echo ✅ Git 历史已重写
    echo.
    echo [3/3] 下一步操作：
    echo.
    echo 1. 检查历史是否正确：
    echo    git log --all --pretty=format:"%%an <%%ae>"
    echo.
    echo 2. 如果确认无误，强制推送：
    echo    git push --force --all
    echo    git push --force --tags
    echo.
    echo ⚠️  注意：强制推送会覆盖远程仓库的历史！
) else (
    echo.
    echo ❌ 重写历史失败
    echo 可能需要安装 git-filter-branch 或使用 BFG Repo-Cleaner
)

echo.
pause

