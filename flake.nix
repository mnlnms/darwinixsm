{
  description = "Darwinixsm - My journey of nixological evolution";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = 
    { self,
      nixpkgs,
      nix-darwin,
      nix-homebrew,
      ...
    } @inputs:

    let
      configuration = { pkgs, config, ... }: {
        environment.systemPackages = with pkgs;
          [ 
          ];
	
	environment.etc = {
	  "pam.d/sudo_local".text = ''
	    # Managed by Nix-Darwin
	    auth	optional	${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
	    auth	sufficient	pam_tid.so
	  '';
	};
	homebrew = {
          enable = true;
  	brews = [
	  # Installing & updating MacOS AppStore Packages via nix-darwin
  	  "mas"
	  # terminal / cli
	  "fd"
	  "fzf"
	  "oh-my-posh"
	  "ripgrep"
	  "tmux"
	  "yazi"
	  # yazi prerequisition
	  "ffmpegthumbnailer"
	  "imagemagick"
	  "poppler"
	  "sevenzip"
	  "xclip"
	  # end
	  "zellij"
	  "zoxide"
	  # Dotfile - Management
	  "chezmoi"
	  # Editors
	  "neovide"
	  "neovim"
	  # Other CLI - Tools
	  "bitwarden-cli"
	  # Virtual Machines / Dev Containers
	  "colima"
  	];
  	casks = [
	  # Work
  	  "microsoft-edge"
	  "microsoft-teams"
	  "webex"
	  "powershell"
	  # Editors
	  "visual-studio-code"
	  # Private
  	  "iina"
	  "spotify"
	  "firefox"
	  # System
      "alacritty"
	  "betterdisplay"
  	  "raycast"
	  "wezterm"
	  "zerotier-one"
	  # Virtualization
	  "vmware-fusion"
  	];
  	masApps = {
          # Microsoft Office
          "Microsoft Word" = 462054704;
  	  "Microsoft Outlook" = 985367838;
	  # Safari Extensions
  	  "Bitwarden - Safari" = 1352778147;
  	  "AdGuard für Safari" = 1440147259;
  	};
  	onActivation.cleanup = "zap";
  	onActivation.autoUpdate = true;
  	onActivation.upgrade = true;
        };
	
        networking = {
          hostName = "mcbk-air.nemes.cc";
  	localHostName = "mcbk-air";
  	computerName = "mcbk-air";
        };
  
        security.pam.enableSudoTouchIdAuth = true;
  
        system = {
          defaults = {
            dock = {
	      autohide = true;
	      persistent-apps = [
  	        "/Applications/Safari.app"
  	        "/System/Applications/Mail.app"
  	        "/System/Applications/Calendar.app"
  	      ];
              orientation = "left";
              show-recents = false;
              tilesize = 32;
	    };
  	    finder.FXPreferredViewStyle = "clmv";
  	    loginwindow.GuestEnabled = false;
  	    trackpad = {
	      Clicking = true;
  	      Dragging = true;
  	      TrackpadThreeFingerDrag = true;
  	    };
	    NSGlobalDomain = {
	      AppleICUForce24HourTime = true;
  	      AppleInterfaceStyle = "Dark";
  	      KeyRepeat = 2;
	    };
          };
  	  startup.chime = false;
        };
  
        users.users.mnl.home = "/Users/mnl";

	fonts.packages = with pkgs; [
	 (nerdfonts.override { fonts = ["FiraCode" "JetBrainsMono"]; })
	];
  
        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;
  
        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";
  
        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true;  # default shell on catalina
        # programs.fish.enable = true;
  
        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;
  
        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;
  
        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };

    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."air" = nix-darwin.lib.darwinSystem {
        # specialArgs = { inherit inputs; };
        modules = [ 
          configuration
	  ./configuration.nix
  	  nix-homebrew.darwinModules.nix-homebrew
  	  {
  	    nix-homebrew =
  	    {
  	      enable = true;
  	      enableRosetta = true;
  	      user = "mnl";
  	    };
  	  }
        ];
      };
  
      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."air".pkgs;
    };
}

