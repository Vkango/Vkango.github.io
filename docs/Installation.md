# 安装

先决条件：

- Node.js (推荐 LTS)
- Yarn
- Zola（用于本地预览/构建）
- typst-ts-cli（用于将 Typst 转为静态 artifact）

在大多数类 Unix 环境（Linux、macOS、Git Bash / WSL）下：

```bash
yarn install
# 安装 zola（见 https://www.getzola.org ）
# 全局安装 typst-ts-cli（任选）
npm i -g @myriaddreamin/typst-ts-cli
```

Windows 原生 PowerShell 用户注意：仓库根的 `reset` 脚本使用 `rm -rf`（Unix），在 Windows 下请改用：

```powershell
Remove-Item -Recurse -Force static/typst
cd frontend
npm run reset
```

常用脚本（在仓库根目录执行）：

- `yarn build:fe` — 构建前端资源
- `yarn build:typ` — 生成 Typst 静态 artifact（输出到 `static/typst`）
- `yarn serve` — 启动 Zola 开发服务器（等同 `zola serve`）

部署：使用仓库中的 GitHub Action（见 `.github/workflows` 或 README 里的示例）。
