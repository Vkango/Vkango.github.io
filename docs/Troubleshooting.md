# 故障排查

常见问题：

- 看不到 Typst 文档

  1. 问题描述：启动 `yarn serve` 后页面中没有生成 Typst 内容（或相关页面显示空白/404）。
  2. 原因与检查：
     - `static/typst` 目录为空或不存在。`build-posts.js` 会把 Typst 输出写入 `static/typst`。
     - 没有安装 `typst-ts-cli`，导致 `scripts/build-posts.js` 调用 typst 工具失败。
     - 你忘记在 `content/*.md` 的 front matter 中指定 `extra.typst`。
  3. 解决步骤：

```bash
# 在仓库根：
yarn install
# 生成 typst 输出
yarn build:typ
# 再启动开发服务器
yarn serve
```

  Windows 用户：若仓库脚本使用 `rm -rf`（例如 `reset`），请用 PowerShell 的 `Remove-Item -Recurse -Force static/typst` 替代，或在 WSL/Git Bash 中执行脚本。

  如果 `yarn build:typ` 失败，请检查：

  - 是否已安装 `typst-ts-cli`（尝试 `typst-ts-cli --help`）。
  - `node` 与依赖库是否已正确安装（`yarn install`）。
  - `packages/typst-apollo/typst.toml` 是否存在，且 `typst-ts-cli package link` 执行成功。

- 生成后仍看不到页面

  - 确认对应的 `content/*.md` 正确引用了 `extra.typst`，并且 Zola 没把该页面过滤掉（检查 `config.toml` 中的 `build`/`sections` 配置）。

其他问题：

- 资源丢失或字体问题：`build-posts.js` 在生成时会尝试读取若干字体目录，请确保字体路径存在或将字体复制到 `static/fonts`。
