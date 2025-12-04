@echo off
chcp 65001 >nul
echo ========================================
echo    GitHub 代码推送脚本
echo ========================================
echo.

REM 检查是否已配置远程仓库
git remote -v >nul 2>&1
if %errorlevel% equ 0 (
    echo [信息] 检测到已配置的远程仓库：
    git remote -v
    echo.
    echo 是否要更新远程仓库地址？(Y/N)
    set /p update="请输入: "
    if /i "%update%"=="Y" (
        echo.
        set /p repo_url="请输入新的仓库地址: "
        git remote set-url origin %repo_url%
        echo [成功] 远程仓库地址已更新
    ) else (
        echo.
        echo [信息] 使用现有远程仓库，开始推送...
        goto :push
    )
) else (
    echo [提示] 尚未配置远程仓库
    echo.
    echo 请先创建 GitHub 仓库：
    echo 1. 访问: https://github.com/new
    echo 2. 填写仓库名称（例如: bilibili-parser）
    echo 3. 选择 Public 或 Private
    echo 4. 不要勾选任何选项
    echo 5. 点击 Create repository
    echo.
    set /p repo_url="请输入仓库地址（例如: https://github.com/1662187689/bilibili-parser.git）: "
    
    if "%repo_url%"=="" (
        echo [错误] 仓库地址不能为空！
        pause
        exit /b 1
    )
    
    echo.
    echo [执行] 添加远程仓库...
    git remote add origin %repo_url%
    if %errorlevel% neq 0 (
        echo [错误] 添加远程仓库失败！
        pause
        exit /b 1
    )
    echo [成功] 远程仓库已添加
)

:push
echo.
echo ========================================
echo    开始推送到 GitHub
echo ========================================
echo.

REM 检查当前分支
git branch --show-current >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 无法获取当前分支
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('git branch --show-current') do set current_branch=%%i
echo [信息] 当前分支: %current_branch%

REM 检查是否有未提交的更改
git diff --quiet
if %errorlevel% neq 0 (
    echo [提示] 检测到未提交的更改
    echo.
    set /p commit="是否先提交更改？(Y/N): "
    if /i "!commit!"=="Y" (
        set /p commit_msg="请输入提交信息（默认: Update）: "
        if "!commit_msg!"=="" set commit_msg=Update
        git add .
        git commit -m "!commit_msg!"
        if !errorlevel! neq 0 (
            echo [错误] 提交失败！
            pause
            exit /b 1
        )
        echo [成功] 更改已提交
    )
)

echo.
echo [执行] 推送到 GitHub...
echo [提示] 如果提示输入用户名和密码：
echo        - Username: 1662187689
echo        - Password: 使用个人访问令牌（不是密码）
echo.

git push -u origin %current_branch%

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo    ✅ 推送成功！
    echo ========================================
    echo.
    echo 你的代码已推送到 GitHub
    echo 可以在浏览器中查看你的仓库
) else (
    echo.
    echo ========================================
    echo    ❌ 推送失败
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. 认证失败 - 需要使用个人访问令牌
    echo 2. 网络问题 - 检查网络连接
    echo 3. 仓库不存在 - 确认仓库地址正确
    echo.
    echo 生成个人访问令牌：
    echo https://github.com/settings/tokens
    echo.
    echo 选择 "Generate new token (classic)"
    echo 勾选 "repo" 权限
    echo 生成后复制令牌，在密码处粘贴
)

echo.
pause

