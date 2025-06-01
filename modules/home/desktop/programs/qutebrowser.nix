{ ... }:
{
  programs.qutebrowser = {
    enable = true;
    keyBindings = {
      normal = {
        "<ctrl+right>" = "tab-next";
        "<ctrl+left>" = "tab-prev";
      };
    };
    settings = {
      auto_save = {
        session = true;
      };
      colors = {
        webpage = {
          darkmode = {
            enabled = true;
          };
        };
      };
    };
  };
}
