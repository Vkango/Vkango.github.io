# Typst 说明

项目中 Typst 的组织与构建流程：

- 源目录：`typ/` — 放置 Typst 文件与工作区。
- 依赖包：`packages/typst-apollo/` 包含 apollo 的 typst 包定义（`typst.toml`）。
- 生成位置：`static/typst/` — 构建脚本会把每个条目按主题（light/dark）输出到此处，供 Zola 静态站点使用。

构建逻辑（位于 `scripts/build-posts.js`）：

- 遍历 `typ/`，对每个文件或 workspace 调用 `Compiler.vector(...)` 生成中间文件，输出到 `static/typst/<path>/<theme>/main.multi.sir.in`。
- 若 workspace 中包含 `build-config.toml`，则按配置的 entries 编译出多个条目。
- 构建前脚本会尝试执行 `typst-ts-cli package link --manifest ...`，将 `packages/typst-apollo/typst.toml` 链接到 typst 工具链（所以需要安装 `typst-ts-cli`）。

如何添加新的 Typst 文章：

1. 在 `typ/` 下创建文件或文件夹：
   - 单文件：`typ/foo.typ`。
   - 工作区：`typ/foo/`，包含 `main.typ` 或 `build-config.toml`。
2. 在 `content/` 下新增一个 `.md`（用于生成页面），在 front matter 中添加：

```toml
extra.typst = "foo" # 相对于 typ/ 的路径
```

（如果希望隐藏 Zola 自动生成的标题：`
extra.hide_title = true`）

注意：每次修改 Typst 源后执行 `yarn build:typ`，确保 `static/typst` 有更新内容，才能在本地开发服务器看到变化。
