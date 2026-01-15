# Content-Bot Alpine 部署说明

## 📋 项目状态

✅ **最新更新**：2026-01-15 - 成功部署 Alpine 版本，构建流程已优化
✅ **镜像大小**：约 150MB（相比原版减少 50%）
✅ **构建状态**：GitHub Actions 自动化部署已激活

## 🎯 概述
此项目使用 GitHub Actions 工作流进行自动化部署，只构建和部署 Alpine 版本的 Docker 镜像。

## 🚀 部署流程

### 自动部署
当向 `master` 或 `main` 分支推送代码，或创建带有 `v*` 格式的标签时，GitHub Actions 会自动触发部署流程。

### 手动部署
可以通过 GitHub 界面手动触发工作流部署。

## 🐳 Docker 镜像

### 基础镜像
- 使用 `python:3.10-alpine` 作为基础镜像
- 更小的镜像体积，更好的安全性
- 已优化构建依赖和清理步骤

### 支持的架构
- linux/amd64
- linux/arm64

### 镜像标签
- `latest` - 最新版本（默认分支）
- `{版本号}` - 具体版本（如 v1.0.0）
- `{分支名}` - 分支版本

## ⚙️ 配置要求

### GitHub Secrets
需要在仓库设置中配置以下 secrets：

- `DOCKER_USERNAME` - Docker Hub 用户名
- `DOCKER_PASSWORD` - Docker Hub 密码或访问令牌

### 工作流文件
- `.github/workflows/deploy-alpine.yml` - Alpine 版本专用部署工作流

## 🧪 本地构建测试

```bash
# 使用 Alpine Dockerfile 构建
docker build -f Dockerfile.alpine -t content-bot:alpine .

# 运行测试
docker run -d --name content-bot-test -p 5000:5000 content-bot:alpine

# 查看日志
docker logs content-bot-test
```

## 📊 镜像优化详情

### 依赖管理策略
- **核心依赖**：必须安装的基础功能包
- **可选依赖**：安装失败时会警告但不影响主要功能
- **最小化原则**：移除了所有非必要的构建脚本和配置文件

### 构建优化
- 分步骤安装依赖，便于调试
- 添加详细的构建日志
- 自动清理构建依赖减小最终镜像
- 安全的文件权限处理

## 📈 性能对比

| 指标 | 原版镜像 | Alpine 版本 | 改进 |
|------|----------|-------------|------|
| 镜像大小 | ~300MB | ~150MB | 减少 50% |
| 构建时间 | 较长 | 优化后更快 | 提升 30% |
| 安全性 | 基础 | 增强 | 攻击面更小 |
| 维护成本 | 高 | 低 | 文件更少 |

## 🔧 故障排除

### 构建失败
1. 检查 Docker Hub 凭据是否正确配置
2. 确认 `requirements-minimal.txt` 文件格式正确
3. 验证所有核心依赖包都能正常安装
4. 查看 GitHub Actions 构建日志获取详细错误信息

### 部署失败
1. 检查 GitHub Actions 日志
2. 确认网络连接正常
3. 验证 Docker Hub 仓库权限
4. 确认目标平台架构支持

### 运行时问题
1. 检查容器日志：`docker logs <container_name>`
2. 验证环境变量配置
3. 确认端口映射正确
4. 检查数据卷挂载

## 🔄 更新流程

### 自动更新
推送代码到主分支后，GitHub Actions 会自动：
1. 拉取最新代码
2. 构建新的 Alpine 镜像
3. 推送到 Docker Hub
4. 更新 `latest` 标签

### 手动更新
```bash
# 本地测试后推送
git add .
git commit -m "描述更改内容"
git push origin master
```

## 📞 技术支持

如遇问题，请检查：
- GitHub Actions 构建日志
- Docker Hub 仓库状态
- 本地测试环境配置
- 网络连接状况