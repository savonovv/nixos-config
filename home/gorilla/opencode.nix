{ pkgs, ... }:

{
  xdg.configFile."opencode/opencode.jsonc".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
  };

  xdg.configFile."opencode/plugins/action-notification.ts".text = ''
    import type { Plugin } from "@opencode-ai/plugin"

    export const ActionNotification: Plugin = async ({ $ }) => {
      const pending = new Map<string, string>()

      const setTmuxAttention = async (enabled: boolean) => {
        const pane = process.env.TMUX_PANE
        if (!pane) return

        try {
          await $`${pkgs.tmux}/bin/tmux set-window-option -t ''${pane} @opencode_attention ''${enabled ? "1" : "0"}`.quiet()
        } catch {}
      }

      const clearSession = async (sessionID: string) => {
        for (const [requestID, requestSessionID] of pending) {
          if (requestSessionID === sessionID) pending.delete(requestID)
        }
        await setTmuxAttention(pending.size > 0)
      }

      const notify = async () => {
        try {
          await $`${pkgs.systemd}/bin/busctl --user call org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications Notify susssasa{sv}i opencode 0 dialog-information "Action required" "OpenCode is waiting for your input" 0 0 5000`.quiet()
        } catch {}
      }

      await setTmuxAttention(false)

      return {
        event: async ({ event }) => {
          if (event.type === "permission.asked" || event.type === "question.asked") {
            pending.set(event.properties.id, event.properties.sessionID)
            await Promise.all([setTmuxAttention(true), notify()])
            return
          }

          if (
            event.type === "permission.replied" ||
            event.type === "question.replied" ||
            event.type === "question.rejected"
          ) {
            pending.delete(event.properties.requestID)
            await setTmuxAttention(pending.size > 0)
            return
          }

          if (event.type === "session.idle") {
            await clearSession(event.properties.sessionID)
            return
          }

          if (event.type === "session.error" && event.properties.sessionID) {
            await clearSession(event.properties.sessionID)
          }
        },
      }
    }
  '';
}
