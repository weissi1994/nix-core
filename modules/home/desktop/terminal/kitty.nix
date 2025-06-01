{ ... }:
{
  programs.kitty = {
    enable = true;
    shellIntegration = {
      mode = "no-sudo";
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    settings = {
      font_size = 11;
      font_family = "FiraCode Nerd Font Mono";
      active_border_color = "#00ff00";
      copy_on_select = "yes";
      cursor_shape = "block";
      cursor_blink_interval = 0;
      enable_audio_bell = "no";
      shell = "fish --login";
      shell_integration = "enabled";
      editor = "nvim";
      tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}";
      tab_bar_style = "powerline";
      tab_powerline_style = "angled";
      enabled_layouts = "Grid,Stack,Splits,Tall,Fat";
      scrollback_lines = -1;
      scrollback_pager_history_size = 0;
      scrollback_fill_enlarged_window = "no";
      dim_opacity = "0.75";
      kitty_mod = "ctrl+shift";
    };
    extraConfig = ''
      # Right click copy previous command output
      mouse_map right press ungrabbed mouse_select_command_output
    '';
    keybindings = {
      "kitty_mod+up" = "neighboring_window up";
      "kitty_mod+down" = "neighboring_window down";
      "kitty_mod+left" = "neighboring_window left";
      "kitty_mod+right" = "neighboring_window right";
      "ctrl+alt+right" = "next_tab";
      "ctrl+alt+left" = "previous_tab";
      "kitty_mod+space" = "next_layout";
      "kitty_mod+d" = "detach_tab ask";
      "kitty_mod+s" = "move_window_to_top";
      "kitty_mod+a" = "detach_window ask";
      "kitty_mod+c" = "neighboring_window up";
      "kitty_mod+t" = "neighboring_window down";
      "kitty_mod+h" = "neighboring_window left";
      "kitty_mod+n" = "neighboring_window right";
      "kitty_mod+r" = "next_tab";
      "kitty_mod+g" = "previous_tab";
      "kitty_mod+e" = "new_tab_with_cwd";
      "kitty_mod+o" = "new_tab";
      "ctrl+shift+tab" = "next_tab";
      "ctrl+tab" = "previous_tab";
      "page_up" = "scroll_page_up";
      "page_down" = "scroll_page_down";
      "ctrl+shift+l" = "show_scrollback";
    };
  };
}
