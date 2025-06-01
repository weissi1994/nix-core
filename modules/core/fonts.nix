{ pkgs, ... }:
{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.ubuntu-mono
      fira-code
      fira-code-symbols
      fira-go
      victor-mono
      joypixels
      font-awesome
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      source-serif
      ubuntu_font_family
      work-sans
    ];

    # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
    enableDefaultPackages = true;

    fontconfig = {
      antialias = true;
      defaultFonts = {
        serif = [ "Source Serif" ];
        sansSerif = [
          "Work Sans"
          "Fira Sans"
          "FiraGO"
        ];
        monospace = [
          "FiraCode Nerd Font Mono"
          "SauceCodePro Nerd Font Mono"
        ];
        emoji = [
          "Noto Color Emoji"
          "Twitter Color Emoji"
          "JoyPixels"
          "Unifont"
          "Unifont Upper"
        ];
      };
      enable = true;
      hinting = {
        autohint = false;
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "light";
      };
    };
  };
}
