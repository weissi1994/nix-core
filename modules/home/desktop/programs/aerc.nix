{ pkgs, ... }:
{
  home.packages = with pkgs; [
    w3m
    dante
  ];

  programs.aerc = {
    enable = true;
    # catppuccin.enable = true;
    extraConfig = {
      viewer = {
        pager = "${pkgs.less}/bin/less -R";
      };
      filters = {
        "text/plain" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
        "text/calendar" = "${pkgs.gawk}/bin/awk -f ${pkgs.aerc}/libexec/aerc/filters/calendar";
        "text/html" =
          "${pkgs.aerc}/libexec/aerc/filters/html | ${pkgs.aerc}/libexec/aerc/filters/colorize"; # Requires w3m, dante
        # "text/*" =
        #   ''${pkgs.bat}/bin/bat -fP --file-name="$AERC_FILENAME "'';
        "message/delivery-status" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
        "message/rfc822" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
        "application/x-sh" = "${pkgs.bat}/bin/bat -fP -l sh";
        "application/pdf" = "${pkgs.zathura}/bin/zathura -";
        "application/json" = "${pkgs.jq}/bin/jq -C";
        "audio/*" = "${pkgs.mpv}/bin/mpv -";
        # "image/*" = "convert - -resize 1000x500\>  - | kitty +kitten icat --stdin=yes --silent --transfer-mode stream --hold --place=120x120@0x7 && kitty +kitten icat --silent --transfer-mode stream --clear";
        "image/*" =
          "kitty +kitten icat --stdin=yes --silent --transfer-mode stream --hold --place=120x120@0x7 && kitty +kitten icat --silent --transfer-mode stream --clear";
        # "image/*" = "kitty +kitten icat --silent --stdin";
        # audio/*=mpv -
        # image/*=feh -
      };
      viewer = {
        alternatives = "text/plain,text/html";
        # alternatives = "text/html,text/plain";
      };
    };
  };
}
