/**
 * 腾讯云 Serverless 入口文件
 * 将 API Gateway 事件转换为 Express 请求
 */

const app = require('./server');
const querystring = require('querystring');

// Serverless 入口函数
exports.handler = async (event, context) => {
    // 解析 API Gateway 事件
    const { httpMethod, path, headers, queryStringParameters, body, pathParameters } = event;
    
    // 构建请求路径（处理路径参数）
    let requestPath = path;
    if (pathParameters && pathParameters.proxy) {
        requestPath = '/' + pathParameters.proxy;
    }
    
    // 构建查询字符串
    const queryString = queryStringParameters 
        ? querystring.stringify(queryStringParameters)
        : '';
    const fullPath = queryString ? `${requestPath}?${queryString}` : requestPath;
    
    // 解析请求体
    let requestBody = {};
    if (body) {
        try {
            if (headers['Content-Type'] && headers['Content-Type'].includes('application/json')) {
                requestBody = JSON.parse(body);
            } else {
                requestBody = querystring.parse(body);
            }
        } catch (e) {
            // 如果解析失败，使用原始 body
            requestBody = body;
        }
    }
    
    // 构建 Express 风格的请求对象
    const req = {
        method: httpMethod,
        url: fullPath,
        path: requestPath,
        headers: headers || {},
        query: queryStringParameters || {},
        body: requestBody,
        cookies: {},
        get: function(name) {
            return this.headers[name.toLowerCase()] || this.headers[name];
        }
    };
    
    // 解析 Cookie
    if (headers.Cookie) {
        headers.Cookie.split(';').forEach(cookie => {
            const [name, value] = cookie.trim().split('=');
            if (name && value) {
                req.cookies[name] = decodeURIComponent(value);
            }
        });
    }
    
    // 构建响应对象
    let responseBody = '';
    let statusCode = 200;
    const responseHeaders = {};
    
    const res = {
        statusCode: 200,
        headers: responseHeaders,
        body: '',
        
        setHeader: function(key, value) {
            this.headers[key] = value;
        },
        
        getHeader: function(key) {
            return this.headers[key];
        },
        
        status: function(code) {
            statusCode = code;
            this.statusCode = code;
            return this;
        },
        
        json: function(data) {
            this.setHeader('Content-Type', 'application/json; charset=utf-8');
            responseBody = JSON.stringify(data);
            return this;
        },
        
        send: function(data) {
            if (typeof data === 'object') {
                this.setHeader('Content-Type', 'application/json; charset=utf-8');
                responseBody = JSON.stringify(data);
            } else {
                responseBody = data;
            }
            return this;
        },
        
        end: function(data) {
            if (data) {
                responseBody = data;
            }
        },
        
        cookie: function(name, value, options) {
            const cookieOptions = options || {};
            let cookie = `${name}=${encodeURIComponent(value)}`;
            if (cookieOptions.maxAge) {
                cookie += `; Max-Age=${cookieOptions.maxAge}`;
            }
            if (cookieOptions.path) {
                cookie += `; Path=${cookieOptions.path}`;
            }
            if (cookieOptions.httpOnly) {
                cookie += `; HttpOnly`;
            }
            if (cookieOptions.secure) {
                cookie += `; Secure`;
            }
            
            const existingCookies = this.headers['Set-Cookie'] || [];
            if (typeof existingCookies === 'string') {
                this.headers['Set-Cookie'] = [existingCookies, cookie];
            } else {
                existingCookies.push(cookie);
                this.headers['Set-Cookie'] = existingCookies;
            }
        },
        
        clearCookie: function(name) {
            this.cookie(name, '', { maxAge: 0 });
        }
    };
    
    // 处理流式响应（用于文件下载）
    const chunks = [];
    let isStreaming = false;
    
    res.write = function(chunk) {
        chunks.push(chunk);
        isStreaming = true;
    };
    
    res.writeHead = function(code, headers) {
        statusCode = code;
        if (headers) {
            Object.assign(this.headers, headers);
        }
    };
    
    // 执行 Express 应用
    return new Promise((resolve, reject) => {
        try {
            app(req, res, (err) => {
                if (err) {
                    console.error('Express 处理错误:', err);
                    resolve({
                        statusCode: 500,
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            success: false,
                            error: err.message || '服务器内部错误'
                        })
                    });
                    return;
                }
                
                // 如果使用了流式响应
                if (isStreaming && chunks.length > 0) {
                    // 对于流式响应，需要特殊处理
                    // 这里返回基础信息，实际文件流需要通过其他方式处理
                    resolve({
                        statusCode: statusCode || 200,
                        headers: responseHeaders,
                        body: Buffer.concat(chunks).toString('base64'),
                        isBase64Encoded: true
                    });
                } else {
                    // 普通响应
                    resolve({
                        statusCode: statusCode || 200,
                        headers: responseHeaders,
                        body: responseBody || ''
                    });
                }
            });
        } catch (error) {
            console.error('处理请求时发生错误:', error);
            reject({
                statusCode: 500,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    success: false,
                    error: error.message || '服务器内部错误'
                })
            });
        }
    });
};

