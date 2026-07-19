# dq-market

DanQing Teams 官方专家 / 技能市场内容仓。

Teams 通过 `config.yaml` 中的 `market.sources` 拉取本仓的 `catalog/index.json`，并按条目 `path` 安装技能与专家。

## 目录约定

```text
catalog/index.json          # 市场目录（必填）
skills/<id>/SKILL.md        # 技能包（可选 scripts/ references/ assets/）
experts/<id>/AGENT.md       # 专家包（frontmatter 对齐 Teams agents/*.md）
```

## 添加技能

1. 在 `skills/<id>/` 下编写 `SKILL.md`（YAML frontmatter + 正文）
2. 可选：放入 `scripts/`、`references/`、`assets/` 资源文件
3. 在 `catalog/index.json` 增加一条 `kind: skill` 条目，`path` 指向该目录

## 添加专家

1. 在 `experts/<id>/` 下编写 `AGENT.md`
2. 在 frontmatter 的 `skills` 中列出依赖技能 id
3. 在 `catalog/index.json` 增加 `kind: expert`，并用 `skillDeps` 声明依赖

## Teams 配置示例

```yaml
market:
  cache_ttl_hours: 6
  sources:
    - id: official-github
      name: Official (GitHub)
      kind: git
      platform: github
      repo: https://github.com/danqing-ai/dq-market
      ref: main
      enabled: true
      priority: 10
```

官方仓：https://github.com/danqing-ai/dq-market

本地开发也可配置 `platform: local` 指向本目录绝对路径。
