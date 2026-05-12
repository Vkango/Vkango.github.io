# 使用与本地开发

本项目支持 Markdown 与 Typst 两种内容源。

快速本地开发：

1. 确保已按 [安装](Installation.md) 步骤准备好依赖。
2. 生成 Typst artifact（必要）：

```bash
yarn build:typ
```

3. 启动开发服务器：

```bash
yarn serve
# 或者直接
zola serve
```

4. 打开浏览器访问 `http://127.0.0.1:1111`（默认端口），检查站点。

编辑文章（Markdown 或 Typst）：

- Markdown：在 `content/` 下创建或编辑 `.md`，遵循 Zola 的 front matter。示例：`content/posts/markdown.md`。
- Typst：在 `typ/` 下放置 `.typ` 文件或工作区（含 `main.typ` 或 `build-config.toml`），在对应的 `content/*.md` front matter 中添加 `extra.typst` 字段（值为 `typ/` 下的相对路径），示例：`content/posts/test.md`。

每次修改 Typst 源后，需重新运行 `yarn build:typ` 以生成 `static/typst` 下的 artifact，然后刷新开发页面。
