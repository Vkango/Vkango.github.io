# 贡献说明

欢迎贡献！常见流程：

1. Fork 本仓库并创建 feature 分支。
2. 本地修改后，确保：
   - 运行 `yarn build:typ`（若修改了 Typst 内容）
   - 运行 `yarn build:fe`（若修改了前端）
   - 运行 `zola build` 或 `yarn serve` 本地检查
3. 提交并发起 Pull Request，描述你的改动与验证步骤。

注意：`static/typst` 被列入 `.gitignore`，构建产物不应提交到仓库；PR 应只包含源代码变更（`typ/`、`content/`、模板等）。
