## 0.2.0

- `agentInit` exposes `agentCommands`: with `?agent` on the web, the js
  bridge `window.tekartikAgent` (`commands()`, `run(name, args)`, `help()`,
  release builds included); in a debug or profile run, the VM service
  extensions `ext.tekartik.agent.commands` and `ext.tekartik.agent.run`.
- `AgentCommandsScope`: registers commands while in the tree.

## 0.1.0

- `AgentId`, `agentInit` / `agentUrlOptions`.
