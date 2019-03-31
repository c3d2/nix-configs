{ lib, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = lib.mkForce [ "en_US.UTF-8/UTF-8" ];
  };
}
