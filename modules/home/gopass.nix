{
  desktop,
  lib,
  pkgs,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      gopass
      gopass-hibp
      gopass-summon-provider
      summon
    ]
    ++ lib.optionals (desktop != null) [ gopass-jsonapi ];
}
