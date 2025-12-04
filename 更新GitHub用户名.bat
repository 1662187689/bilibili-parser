@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo    更新 GitHub 用户名引用
echo ========================================
echo.
echo 当前用户名: 1662187689
echo.
echo ⚠️  重要提示：
echo 1. 请先在 GitHub 上更改用户名
echo    访问: https://github.com/settings/profile
echo 2. 更改后，所有仓库 URL 都会改变
echo 3. 需要更新远程仓库地址和代码中的引用
echo.
set /p new_username="请输入新的 GitHub 用户名: "

if "!new_username!"=="" (
    echo [错误] 用户名不能为空
    pause
    exit /b 1
)

if "!new_username!"=="1662187689" (
    echo [错误] 新用户名不能与旧用户名相同
    pause
    exit /b 1
)

echo.
echo ========================================
echo    开始更新...
echo ========================================
echo.

echo [1/5] 更新 Git 配置...
git config --global user.name "!new_username!"
if %errorlevel% equ 0 (
    echo ✅ Git 配置已更新: !new_username!
) else (
    echo ❌ Git 配置更新失败
)

echo.
echo [2/5] 更新远程仓库地址...
git remote set-url origin https://github.com/!new_username!/bilibili-parser.git
if %errorlevel% equ 0 (
    echo ✅ 远程地址已更新
    git remote -v
) else (
    echo ❌ 远程地址更新失败
)

echo.
echo [3/5] 更新代码中的引用...
powershell -Command "$files = @('public\script.js', 'update-announcement.js'); foreach($file in $files) { if(Test-Path $file) { (Get-Content $file -Encoding UTF8) -replace '1662187689', '!new_username!' | Set-Content $file -Encoding UTF8; Write-Host \"✅ $file 已更新\" } }"
if %errorlevel% equ 0 (
    echo ✅ 代码文件已更新
) else (
    echo ⚠️  代码文件更新可能失败，请手动检查
)

echo.
echo [4/5] 更新文档中的引用...
powershell -Command "$files = Get-ChildItem -Path . -Include *.md,*.txt,*.bat -Recurse -Exclude node_modules,test | Where-Object { $_.FullName -notmatch 'node_modules|\.git' }; foreach($file in $files) { $content = Get-Content $file.FullName -Encoding UTF8 -Raw; if($content -match '1662187689') { $content = $content -replace '1662187689', '!new_username!'; Set-Content $file.FullName -Value $content -Encoding UTF8; Write-Host \"✅ $($file.Name) 已更新\" } }"
if %errorlevel% equ 0 (
    echo ✅ 文档文件已更新
) else (
    echo ⚠️  文档文件更新可能失败，请手动检查
)

echo.
echo [5/5] 更新 Gist 引用（如果 Gist ID 需要更改）...
echo ⚠️  注意：Gist ID 通常不需要更改，但如果 Gist 所有者改变，可能需要更新
echo 当前 Gist ID: ae97ddcecaaf2f3dea622ef7b2520c67
echo 如果 Gist 已转移到新用户名，请手动更新以下文件：
echo   - public/script.js (GIST_CONFIG.gistId)
echo   - update-announcement.js (GIST_CONFIG.gistId)

echo.
echo ========================================
echo    ✅ 更新完成！
echo ========================================
echo.
echo 下一步操作：
echo.
echo 1. 检查所有更改：
echo    git status
echo    git diff
echo.
echo 2. 提交更改：
echo    git add .
echo    git commit -m "更新 GitHub 用户名引用为 !new_username!"
echo.
echo 3. 推送到新地址：
echo    git push
echo.
echo 4. 更新 Render 部署配置（如果使用）：
echo    - 进入 Render 控制台
echo    - 更新服务的 GitHub 仓库连接
echo.
echo 5. 验证新用户名：
echo    - 访问: https://github.com/!new_username!/bilibili-parser
echo    - 确认仓库可以正常访问
echo.
pause

