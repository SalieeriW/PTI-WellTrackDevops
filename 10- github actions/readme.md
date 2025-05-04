打开仓库设置页面 -> Secrets and variables -> Actions
添加以下密钥：

HARBOR_URL: 您的本地 Harbor 地址，例如 harbor.welltrack.local
HARBOR_USERNAME: Harbor 用户名（可能是 admin）
HARBOR_PASSWORD: Harbor 密码（从安装输出中获取）
GITOPS_URL： GitOps 仓库地址
GIT_DEPLOY_KEY：GitOps 仓库的 SSH 私钥