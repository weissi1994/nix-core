{ ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''

      local scrollback_lines = 200000
      local config = wezterm.config_builder()

      -- The filled in variant of the < symbol
      local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

      -- The filled in variant of the > symbol
      local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

      -- This function returns the suggested title for a tab.
      -- It prefers the title that was set via `tab:set_title()`
      -- or `wezterm cli set-tab-title`, but falls back to the
      -- title of the active pane in that tab.
      function tab_title(tab_info)
        local title = tab_info.tab_title
        -- if the tab title is explicitly set, take that
        if title and #title > 0 then
          return title
        end
        -- Otherwise, use the title from the active pane
        -- in that tab
        return tab_info.active_pane.title
      end

      wezterm.on(
        'format-tab-title',
        function(tab, tabs, panes, config, hover, max_width)
          local edge_background = '#0b0022'
          local background = '#1b1032'
          local foreground = '#808080'

          if tab.is_active then
            background = '#2b2042'
            foreground = '#c0c0c0'
          elseif hover then
            background = '#3b3052'
            foreground = '#909090'
          end

          local edge_foreground = background

          local title = tab_title(tab)

          -- ensure that the titles fit in the available space,
          -- and that we have room for the edges.
          title = wezterm.truncate_right(title, max_width - 2)

          return {
            { Background = { Color = edge_background } },
            { Foreground = { Color = edge_foreground } },
            { Text = SOLID_LEFT_ARROW },
            { Background = { Color = background } },
            { Foreground = { Color = foreground } },
            { Text = title },
            { Background = { Color = edge_background } },
            { Foreground = { Color = edge_foreground } },
            { Text = SOLID_RIGHT_ARROW },
          }
        end
      )


      config.tab_max_width = 25
      config.text_background_opacity = 1
      config.hide_tab_bar_if_only_one_tab = true
      config.font_size = 11
      config.font = wezterm.font_with_fallback({
        "FiraCode Nerd Font Mono",
        "Noto Color Emoji",
        "MesloLGL Nerd Font",
        "Roboto",
        "Code2000",
        "Symbola",
        "Source Code Pro",
        "Material Icons Two Tone",
        "google-mdi",
        "Unifont",
        "DejaVuSansMono Nerd Font",
        "DejaVu Sans",
        "Droid Sans",
        "Droid Sans Fallback",
        "Unifont",
      })
      config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
      config.window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      }
      config.inactive_pane_hsb = {
        saturation = 0.4,
        brightness = 0.6,
      }
      config.tab_bar_at_bottom = true
      config.scrollback_lines = scrollback_lines
      config.default_prog = { "fish" }

      config.keys = {
        { key = "F1", mods = "", action = wezterm.action.ShowTabNavigator },
        { key = ".", mods = "CTRL", action = wezterm.action.PaneSelect },
        { key = "PageUp", mods = "SHIFT", action = wezterm.action.ActivateTabRelative(1) },
        { key = "PageDown", mods = "SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
        { key = "a", mods = "CTRL|SHIFT", action = wezterm.action.ToggleFullScreen },
        {
          key = "Enter",
          mods = "CTRL",
          action = wezterm.action.SpawnTab("CurrentPaneDomain"),
        },
        {
          key = "Enter",
          mods = "CTRL|SHIFT",
          action = wezterm.action.SplitPane({
            direction = "Down",
            size = { Percent = 50 },
          }),
        },
        {
          key = "LeftArrow",
          mods = "CTRL|SHIFT",
          action = wezterm.action.SplitPane({
            direction = "Left",
            size = { Percent = 50 },
          }),
        },
        {
          key = "DownArrow",
          mods = "CTRL|SHIFT",
          action = wezterm.action.SplitPane({
            direction = "Down",
            size = { Percent = 50 },
          }),
        },
        {
          key = "UpArrow",
          mods = "CTRL|SHIFT",
          action = wezterm.action.SplitPane({
            direction = "Up",
            size = { Percent = 50 },
          }),
        },
        {
          key = "RightArrow",
          mods = "CTRL|SHIFT",
          action = wezterm.action.SplitPane({
            direction = "Right",
            size = { Percent = 50 },
          }),
        },
        {
          key = "LeftArrow",
          mods = "SHIFT",
          action = wezterm.action.ActivatePaneDirection("Left"),
        },
        {
          key = "RightArrow",
          mods = "SHIFT",
          action = wezterm.action.ActivatePaneDirection("Right"),
        },
        {
          key = "UpArrow",
          mods = "SHIFT",
          action = wezterm.action.ActivatePaneDirection("Up"),
        },
        {
          key = "DownArrow",
          mods = "SHIFT",
          action = wezterm.action.ActivatePaneDirection("Down"),
        },
      }

      config.mouse_bindings = {
        {
          event = { Down = { streak = 1, button = "Left" } },
          mods = "CTRL|SHIFT",
          action = wezterm.action.SelectTextAtMouseCursor("Block"),
        },
        {
          event = { Drag = { streak = 1, button = "Left" } },
          mods = "CTRL|SHIFT",
          action = wezterm.action.ExtendSelectionToMouseCursor("Block"),
        },
        {
          event = { Up = { streak = 1, button = "Left" } },
          mods = "CTRL|SHIFT",
          action = wezterm.action.CompleteSelection("ClipboardAndPrimarySelection"),
        },
        {
          event = { Down = { streak = 1, button = 'Right' } },
          action = wezterm.action.Multiple {
            { SelectTextAtMouseCursor = 'SemanticZone' },
            { CopyTo = 'ClipboardAndPrimarySelection' },
          },
          mods = 'NONE',
        },
      }

      return config
    '';
  };
}
