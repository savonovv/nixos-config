{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    prefix = "C-a";
    terminal = "tmux-256color";
    mouse = true;
    keyMode = "vi";
    clock24 = true;
    escapeTime = 0;
    historyLimit = 100000;
    baseIndex = 1;
    shell = "${pkgs.fish}/bin/fish";

    extraConfig = ''
      # True color
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -ag terminal-overrides ",ghostty:RGB"
      set -as terminal-features ",ghostty:RGB"

      # Fish
      set -g default-shell "${pkgs.fish}/bin/fish"
      set -g default-command "${pkgs.fish}/bin/fish"

      # Navigation and copy mode
      set -g mouse on
      setw -g mode-keys vi

      bind v copy-mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"
      bind -T copy-mode-vi Escape send-keys -X cancel

      # Start indexes from 1
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on

      # Splits keep current directory
      unbind %
      unbind '"'

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Reload
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux reloaded"

      # Status bar
      set -g status on
      set -g status-position bottom
      set -g status-justify centre
      set -g status-interval 5

      # Kanagawa:
      # background      #1f1f28
      # dark background #16161d
      # foreground      #dcd7ba
      # muted           #727169
      # blue            #7e9cd8
      # aqua            #7aa89f
      # green           #98bb6c
      # yellow          #e6c384
      # orange          #ffa066
      # red             #e82424
      # violet          #957fb8

      set -g status-style "bg=#1f1f28,fg=#dcd7ba"

      set -g status-left-length 60
      set -g status-right-length 120

      # Session segment turns orange while the prefix is active.
      set -g status-left "#{?client_prefix,#[fg=#16161d]#[bg=#ff5d62]#[bold] #S #[fg=#ff5d62]#[bg=#1f1f28],#[fg=#16161d]#[bg=#e6c384]#[bold] #S #[fg=#e6c384]#[bg=#1f1f28]}"

      set -g status-right "#[fg=#7e9cd8]CPU #(awk '{print $1}' /proc/loadavg) #[fg=#727169]│ #[fg=#957fb8]MEM #(awk '/MemTotal/ { total=$2 } /MemAvailable/ { available=$2 } END { printf \"%.0f%%\", (total-available)*100/total }' /proc/meminfo) #[fg=#727169]│ #[fg=#7aa89f]#(nmcli -t -f TYPE,STATE device status | awk -F: '$2 == \"connected\" && $1 == \"wifi\" { print \"󰖩\"; found=1; exit } $2 == \"connected\" && $1 == \"ethernet\" { wired=1 } END { if (!found) print wired ? \"󰈀\" : \"󰖪\" }') #[fg=#727169]│ #[fg=#ffa066]BAT #(awk 'NR == 1 { pct=$1; next } { icon = $1 == \"Charging\" ? \"⇡\" : ($1 == \"Full\" ? \"•\" : \"⇣\"); print icon \" \" pct \"%\" }' /sys/class/power_supply/BAT0/capacity /sys/class/power_supply/BAT0/status) #[fg=#727169]│ #[fg=#7fb4ca]#(whoami)#[fg=#727169]@#[fg=#c0a36e]#H #[fg=#727169]│ #[fg=#98bb6c]%B %-d #[fg=#e6c384]%H:%M "

      setw -g window-status-separator ""

      setw -g window-status-format "#[fg=#727169,bg=#1f1f28] #I:#W "

      setw -g window-status-current-format "#[fg=#1f1f28,bg=#7e9cd8,bold] #I:#W #[fg=#7e9cd8,bg=#1f1f28]"

      setw -g window-status-activity-style "fg=#ffa066,bg=#1f1f28,bold"

      set -g pane-border-style "fg=#363646"
      set -g pane-active-border-style "fg=#7e9cd8"

      set -g message-style "fg=#16161d,bg=#e6c384,bold"
      set -g mode-style "fg=#16161d,bg=#7e9cd8,bold"
    '';
  };
}
