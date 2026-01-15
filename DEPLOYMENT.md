# Content-Bot Alpine 部署说明

## 概述
此项目使用 GitHub Actions 工作流进行自动化部署，只构建和部署 Alpine 版本的 Docker 镜像。

## 部署流程

### 自动部署
当向 `master` 或 `main` 分支推送代码，或创建带有 `v*` 格式的标签时，GitHub Actions 会自动触发部署流程。

### 手动部署
可以通过 GitHub 界面手动触发工作流部署。

## Docker 镜像

### 基础镜像
- 使用 `python:3.10-alpine` 作为基础镜像
- 更小的镜像体积，更好的安全性

### 支持的架构
- linux/amd64
- linux/arm64

### 镜像标签
- `latest` - 最新版本
- `{版本号}` - 具体版本（如 v1.0.0）
- `{分支名}` - 分支版本

## 配置要求

### GitHub Secrets
需要在仓库设置中配置以下 secrets：

- `DOCKER_USERNAME` - Docker Hub 用户名
- `DOCKER_PASSWORD` - Docker Hub 密码或访问令牌

### 工作流文件
- `.github/workflows/deploy-alpine.yml` - Alpine 版本专用部署工作流

## 本地构建测试

```bash
# 使用 Alpine Dockerfile 构建
docker build -f Dockerfile.alpine -t content-bot:alpine .

# 运行测试
docker run -d --name content-bot-test -p 5000:5000 content-bot:alpine
```

## 镜像大小对比

| 镜像类型 | 大小 | 特点 |
|---------|------|------|
| Alpine | ~150MB | 最小化，安全 |
| Slim | ~300MB | 较小，兼容性好 |
| Full | ~900MB | 完整功能 |

## 故障排除

### 构建失败
1. 检查 Docker Hub 凭据是否正确配置
2. 确认 `requirements.txt` 文件格式正确
3. 验证所有依赖包都能正常安装

### 部署失败
1. 检查 GitHub Actions 日志
2. 确认网络连接正常
3. 验证 Docker Hub 仓库权限