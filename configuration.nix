{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs;
    [
      fastfetch
	  nushell
	  starship
    ];
}
