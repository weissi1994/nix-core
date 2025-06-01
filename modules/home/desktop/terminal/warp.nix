{ ... }:
{
  programs.warp = {
    enable = true;
    keybindings = {
      "ctrl+shift+up" = "neighboring_window up";
      "ctrl+shift+down" = "neighboring_window down";
      "ctrl+shift+left" = "neighboring_window left";
      "ctrl+shift+right" = "neighboring_window right";
      "ctrl+alt+right" = "next_tab";
      "ctrl+alt+left" = "previous_tab";
      "ctrl+shift+c" = "neighboring_window up";
      "ctrl+shift+t" = "neighboring_window down";
      "ctrl+shift+h" = "neighboring_window left";
      "ctrl+shift+n" = "neighboring_window right";
      "ctrl+shift+r" = "next_tab";
      "ctrl+shift+g" = "previous_tab";
      "ctrl+shift+e" = "new_tab_with_cwd";
      "ctrl+shift+o" = "new_tab";
      "ctrl+shift+tab" = "next_tab";
      "ctrl+tab" = "previous_tab";
      "page_up" = "scroll_page_up";
      "page_down" = "scroll_page_down";
      "ctrl+shift+h" = "show_scrollback";
    };
  };
}
