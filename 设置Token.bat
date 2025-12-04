@echo off
chcp 65001 >nul
echo ========================================
echo    设置 GitHub Token
echo ========================================
echo.

REM 检查是否已设置
if not "%GITHUB_TOKEN%"=="" (
    echo [信息] 当前已设置 Token: %GITHUB_TOKEN:~0,10%...
    echo.
    set /p confirm="是否要更新 Token? (Y/N): "
    if /i not "!confirm!"=="Y" (
        echo 已取消
        pause
        exit /b 0
    )
)

echo.
echo 请输入你的 GitHub Token:
echo (Token 将以加密方式保存到系统环境变量)
echo.
set /p token="Token: "

if "!token!"=="" (
    echo [错误] Token 不能为空
    pause
    exit /b 1
)

REM 设置用户环境变量（永久保存）
setx GITHUB_TOKEN "!token!" >nul 2>&1

if %errorlevel% equ 0 (
    REM 同时设置当前会话的环境变量
    set GITHUB_TOKEN=!token!
    
    echo.
    echo ========================================
    echo    ✅ Token 设置成功！
    echo ========================================
    echo.
    echo Token 已保存到系统环境变量
    echo 当前会话已生效，新窗口需要重新打开才能生效
    echo.
    echo 现在可以使用以下命令更新公告：
    echo   更新公告.bat
    echo   或
    echo   node update-announcement.js
) else (
    echo.
    echo ========================================
    echo    ⚠️  Token 设置失败
    echo ========================================
    echo.
    echo 请尝试手动设置：
    echo 1. 右键"此电脑" - "属性"
    echo 2. "高级系统设置" - "环境变量"
    echo 3. 在"用户变量"中添加：
    echo    变量名: GITHUB_TOKEN
    echo    变量值: !token!
)

echo.
pause

