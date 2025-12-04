# 📝 更改 GitHub 用户名指南

## ⚠️ 重要提示

**GitHub 用户名是唯一的标识符，更改后会影响：**
- 所有仓库的 URL
- 个人主页地址
- 其他用户对你的引用
- 已存在的链接和书签

## 🔧 更改 GitHub 用户名

### 步骤 1：在 GitHub 上更改用户名

1. **登录 GitHub**
   - 访问：https://github.com/settings/profile

2. **更改用户名**
   - 在 "Change username" 部分
   - 输入新的用户名（例如：`your-new-username`）
   - 点击 "Change my username"
   - 确认更改

3. **注意事项**
   - 用户名必须是唯一的
   - 只能包含字母、数字和连字符
   - 不能以连字符开头或结尾
   - 更改后，旧的用户名可能被其他人使用

### 步骤 2：更新本地 Git 配置

更改 GitHub 用户名后，需要更新本地配置：

```bash
# 更新 Git 用户名（使用新用户名）
git config --global user.name "your-new-username"

# 验证配置
git config --global user.name
```

### 步骤 3：更新远程仓库地址

更改用户名后，所有仓库的 URL 都会改变，需要更新远程地址：

```bash
# 查看当前远程地址
git remote -v

# 更新远程地址（替换为新用户名）
git remote set-url origin https://github.com/your-new-username/bilibili-parser.git

# 验证更新
git remote -v
```

### 步骤 4：更新代码中的引用

如果代码中有硬编码的用户名，需要更新：

1. **public/script.js** 中的 GIST_CONFIG：
   ```javascript
   const GIST_CONFIG = {
       username: 'your-new-username',  // 更新这里
       gistId: 'ae97ddcecaaf2f3dea622ef7b2520c67',
       filename: 'gistfile1.txt',
       enabled: true
   };
   ```

2. **update-announcement.js** 中的配置：
   ```javascript
   const GIST_CONFIG = {
       username: 'your-new-username',  // 更新这里
       gistId: 'ae97ddcecaaf2f3dea622ef7b2520c67',
       filename: 'gistfile1.txt',
       token: process.env.GITHUB_TOKEN || ''
   };
   ```

3. **文档中的引用**：
   - 检查所有 `.md` 文件中的用户名引用
   - 更新部署指南、README 等文档

## 🔍 查找需要更新的文件

使用以下命令查找所有包含旧用户名的文件：

```bash
# 查找包含旧用户名的文件
git grep -i "1662187689" -- "*.js" "*.md" "*.json" "*.txt" "*.bat"

# 或使用 PowerShell
Select-String -Path "*.js","*.md","*.json","*.txt","*.bat" -Pattern "1662187689" -Recurse
```

## 📋 更新清单

更改用户名后，需要更新：

- [ ] GitHub 用户名（在 GitHub 设置中）
- [ ] 本地 Git 配置（`git config --global user.name`）
- [ ] 远程仓库地址（`git remote set-url`）
- [ ] `public/script.js` 中的 GIST_CONFIG
- [ ] `update-announcement.js` 中的 GIST_CONFIG
- [ ] 所有文档中的用户名引用
- [ ] Render 部署配置（如果使用了 GitHub 集成）
- [ ] 其他服务中的 GitHub 集成

## ⚡ 快速更新脚本

创建一个批处理文件来自动更新：

```batch
@echo off
chcp 65001 >nul
echo ========================================
echo    更新 GitHub 用户名引用
echo ========================================
echo.

set /p new_username="请输入新的 GitHub 用户名: "

if "!new_username!"=="" (
    echo [错误] 用户名不能为空
    pause
    exit /b 1
)

echo.
echo [1/4] 更新 Git 配置...
git config --global user.name "!new_username!"
echo ✅ Git 配置已更新

echo.
echo [2/4] 更新远程仓库地址...
git remote set-url origin https://github.com/!new_username!/bilibili-parser.git
echo ✅ 远程地址已更新

echo.
echo [3/4] 更新代码中的引用...
powershell -Command "(Get-Content 'public\script.js') -replace '1662187689', '!new_username!' | Set-Content 'public\script.js'"
powershell -Command "(Get-Content 'update-announcement.js') -replace '1662187689', '!new_username!' | Set-Content 'update-announcement.js'"
echo ✅ 代码引用已更新

echo.
echo [4/4] 检查文档中的引用...
echo 请手动检查以下文件中的用户名引用：
echo   - 完整部署指南.md
echo   - Render部署检查清单.md
echo   - 快速部署指南.md
echo   - 推送命令.txt
echo   - 推送到GitHub.bat

echo.
echo ========================================
echo    ✅ 更新完成！
echo ========================================
echo.
echo 下一步：
echo 1. 检查所有更改：git diff
echo 2. 提交更改：git add . && git commit -m "更新 GitHub 用户名引用"
echo 3. 推送到新地址：git push
echo.
pause
```

## 🎯 推荐的新用户名格式

- **使用有意义的名称**：例如 `bilibili-parser`、`video-downloader` 等
- **避免个人信息**：不要使用 QQ 号、手机号等
- **保持简洁**：易于记忆和输入
- **检查可用性**：在 GitHub 上搜索确认用户名可用

## ⚠️ 注意事项

1. **旧链接失效**：更改用户名后，所有指向旧用户名的链接都会失效
2. **通知协作者**：如果有其他协作者，需要通知他们更新远程地址
3. **备份重要数据**：更改前建议备份重要仓库
4. **Gist ID 不变**：更改用户名不会改变 Gist ID，所以 Gist 仍然可以正常访问

## 🔗 相关链接

- GitHub 用户名更改：https://github.com/settings/profile
- GitHub 帮助文档：https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/managing-your-profile/renaming-a-user-account

