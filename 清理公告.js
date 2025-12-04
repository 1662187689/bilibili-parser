/**
 * 清理 GitHub Gist 公告中的开发相关更新
 * 使用方法：node 清理公告.js
 */

const https = require('https');

// Gist 配置
const GIST_CONFIG = {
    username: 'YiQing-House',
    gistId: 'ae97ddcecaaf2f3dea622ef7b2520c67',
    filename: 'gistfile1.txt',
    token: process.env.GITHUB_TOKEN || ''
};

// 检查是否是开发相关的更新
function isDevUpdate(message) {
    if (!message) return true;
    
    const lowerMessage = message.toLowerCase();
    const devKeywords = [
        'readme', 'git', 'github', '删除', '移除', '清理', '更新 .gitignore',
        '更新 git', 'commit', 'push', 'pull', 'merge', 'refactor',
        '代码整理', '重构', '优化代码', '修复 lint', '格式化',
        '更新文档', '添加文档', '删除文档', '更新指南',
        'token', '环境变量', '配置', '设置', '用户名', '隐私', '敏感'
    ];
    
    for (const keyword of devKeywords) {
        if (lowerMessage.includes(keyword)) {
            return true;
        }
    }
    
    return false;
}

// 读取 Gist 内容
function getGistContent() {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api.github.com',
            path: `/gists/${GIST_CONFIG.gistId}`,
            method: 'GET',
            headers: {
                'User-Agent': 'Node.js',
                'Accept': 'application/vnd.github.v3+json',
                'Authorization': `token ${GIST_CONFIG.token}`
            }
        };

        https.get(options, (res) => {
            let data = '';
            res.on('data', (chunk) => { data += chunk; });
            res.on('end', () => {
                if (res.statusCode === 200) {
                    const gist = JSON.parse(data);
                    const file = gist.files[GIST_CONFIG.filename];
                    resolve(file ? file.content : '');
                } else {
                    reject(new Error(`获取 Gist 失败: ${res.statusCode}`));
                }
            });
        }).on('error', reject);
    });
}

// 更新 Gist 内容
function updateGist(newContent) {
    return new Promise((resolve, reject) => {
        const postData = JSON.stringify({
            files: {
                [GIST_CONFIG.filename]: {
                    content: newContent
                }
            }
        });

        const options = {
            hostname: 'api.github.com',
            path: `/gists/${GIST_CONFIG.gistId}`,
            method: 'PATCH',
            headers: {
                'User-Agent': 'Node.js',
                'Accept': 'application/vnd.github.v3+json',
                'Authorization': `token ${GIST_CONFIG.token}`,
                'Content-Type': 'application/json; charset=utf-8',
                'Content-Length': Buffer.byteLength(postData, 'utf8')
            }
        };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => { data += chunk; });
            res.on('end', () => {
                if (res.statusCode === 200 || res.statusCode === 201) {
                    resolve(JSON.parse(data));
                } else {
                    reject(new Error(`更新失败: ${res.statusCode} - ${data}`));
                }
            });
        });

        req.on('error', reject);
        req.write(postData, 'utf8');
        req.end();
    });
}

// 主函数
async function main() {
    if (!GIST_CONFIG.token) {
        console.error('❌ 错误: 需要设置 GITHUB_TOKEN 环境变量');
        process.exit(1);
    }

    console.log('📝 正在清理公告...');

    try {
        // 获取现有内容
        const currentContent = await getGistContent();
        
        // 解析公告
        let announcement;
        try {
            announcement = JSON.parse(currentContent);
        } catch (e) {
            console.log('⚠️  公告格式不正确，创建新公告');
            announcement = {
                id: Date.now().toString(),
                title: '公告通知',
                message: '',
                date: new Date().toLocaleDateString('zh-CN'),
                isActive: true,
                history: []
            };
        }

        // 过滤历史记录，只保留用户相关的更新
        if (announcement.history && Array.isArray(announcement.history)) {
            const originalCount = announcement.history.length;
            announcement.history = announcement.history.filter(entry => {
                // 提取消息部分（格式：日期 - 消息）
                const match = entry.match(/^\d{4}年\d{1,2}月\d{1,2}日 \d{1,2}:\d{2} - (.+)$/);
                const message = match ? match[1] : entry;
                return !isDevUpdate(message);
            });
            
            const removedCount = originalCount - announcement.history.length;
            console.log(`✅ 已清理 ${removedCount} 条开发相关公告，保留 ${announcement.history.length} 条用户相关公告`);
        }

        // 更新最新更新（如果有历史记录）
        if (announcement.history && announcement.history.length > 0) {
            const latestUpdate = announcement.history[0];
            const historyText = announcement.history.join('\n');
            announcement.message = `## 📢 最新更新\n\n${latestUpdate}\n\n## 📜 更新历史\n\n${historyText}`;
        } else {
            announcement.message = '暂无更新记录';
        }

        // 更新公告
        announcement.id = Date.now().toString();
        announcement.date = new Date().toLocaleDateString('zh-CN');
        announcement.isActive = true;

        // 更新 Gist（确保使用 UTF-8 编码）
        const newContent = JSON.stringify(announcement, null, 2);
        await updateGist(newContent);
        
        console.log('✅ 公告清理完成！');
        console.log(`📊 当前公告数量: ${announcement.history.length}`);
        
    } catch (error) {
        console.error('❌ 清理失败:', error.message);
        process.exit(1);
    }
}

main();

