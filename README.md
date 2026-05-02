# douban-kc-monitor

豆瓣"爱猫生活"小组（group/656297）【开车】tab 6 小时巡检，结果通过 Telegram bot 推送。

## 调度

GitHub Actions cron `0 4,10,16,22 * * *`（UTC）= CST 0/6/12/18 点。

## 本地手动触发

```bash
gh workflow run inspect.yml --repo buddingc/douban-kc-monitor
gh run list --repo buddingc/douban-kc-monitor --limit 1
gh run view --repo buddingc/douban-kc-monitor --log
```

## Secrets（已配置在 repo settings）

- `TG_BOT_TOKEN` — Telegram bot token
- `TG_CHAT_ID` — 接收消息的 chat id

源是本地 `~/.claude/secrets/telegram.env`，更新 token 后重新跑：

```bash
source ~/.claude/secrets/telegram.env
gh secret set TG_BOT_TOKEN --repo buddingc/douban-kc-monitor --body "$TG_BOT_TOKEN"
gh secret set TG_CHAT_ID  --repo buddingc/douban-kc-monitor --body "$TG_CHAT_ID"
```

## 不做的事

- 不去重（每次推前 15 条，重复推可接受）
- 不解析帖子正文，只标题 + 链接
- 不翻页

## 设计权衡历史

旧版本试过 Anthropic `/schedule` 远程 routine，云端 sandbox 出站有 host allowlist 挡掉了豆瓣和 Telegram，所以改用 GitHub Actions。详见 `~/.claude/plans/foamy-wandering-marble.md`。
