## 0.3.0

- `agentInit(releaseKey:)`: a release build of an app given a key (an
  `AgentKey` of tekartik_app_agent 0.4.0, the hash of the key) lets an
  agent in only with `?agent=<key>`; without a key, `?agent` alone, as
  before (the default), and always in debug and profile builds.
  `agentAllowed` tells whether the agent was let in.

## 0.2.1

- The VM service extensions come from tekartik_app_agent 0.3.0
  (`agentVmRegister`).

## 0.2.0

- `agentInit` exposes `agentCommands`: with `?agent` on the web, the js
  bridge `window.tekartikAgent` (`commands()`, `run(name, args)`, `help()`,
  release builds included); in a debug or profile run, the VM service
  extensions `ext.tekartik.agent.commands` and `ext.tekartik.agent.run`.
- `AgentCommandsScope`: registers commands while in the tree.

## 0.1.0

- `AgentId`, `agentInit` / `agentUrlOptions`.
