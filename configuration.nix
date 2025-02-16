# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

# Home-Manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.puter = { pkgs, ... }: {
    home.stateVersion = "24.11";
    programs.home-manager.enable = true;

      # Waybar Configuration
	  programs.waybar = {
	    enable = true;
	    systemd.enable = true;
	  };

	  # Dunst Configuration
	  services.dunst = {
	    enable = true;
	    settings = {
	      global = {
		width = 300;
		height = 300;
		offset = "30x50";
		origin = "top-right";
		transparency = 10;
		frame_color = "#eceff4";
		font = "JetBrainsMono Nerd Font 10";
	      };
	    };
	  };
  };


# Flatpack Flathub 
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "puter"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  fonts.packages = with pkgs; [
  	(nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
  ];

  # Enable the X11 windowing system.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
	modesetting.enable = true;
	open = true;
	nvidiaSettings = true;
	package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = { 
	enable = true;
	enable32Bit = true;
  };

  hardware.opengl = {
	enable = true;
  	driSupport32Bit = true;
  };

  # Enable the GNOME Desktop Environment.
  services.xserver = {
  enable = true;
  displayManager.gdm = {
    enable = true;
    wayland = true;
  };
};

  # services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

# HYPRLAND
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
programs.dconf.enable = true;
# Configure GTK
# programs.gtk = {
#   enable = true;
#   cursorTheme = {
#     name = "Bibata-Modern-Classic";
#     package = pkgs.bibata-cursors;
#   };
# };
#
  # DBus
services.dbus.enable = true;

# Polkit
security.polkit.enable = true;

# Enable XDG Portal
xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
};

system.activationScripts.createHyprlandConfig = {
  deps = ["users"];
  text = ''
    USER_HOME="/home/puter"
    HYPR_CONFIG="$USER_HOME/.config/hypr"
    
    if [ ! -d "$HYPR_CONFIG" ]; then
      mkdir -p "$HYPR_CONFIG"
      cat > "$HYPR_CONFIG/hyprland.conf" << 'EOL'
monitor=,preferred,auto,1

# Execute at launch
exec-once = waybar
exec-once = dunst
exec-once = swww init

# Set programs
$terminal = ghostty
$fileManager = thunar
$menu = wofi --show drun

# Some default env vars
env = XCURSOR_SIZE,24

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = true
    }
    sensitivity = 0
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee)
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
}

animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = true
    preserve_split = true
}

# Window rules
windowrule = float, ^(pavucontrol)$
windowrule = float, ^(blueman-manager)$

# Key bindings
bind = SUPER, Return, exec, $terminal
bind = SUPER, Q, killactive,
bind = SUPER SHIFT, E, exit,
bind = SUPER, E, exec, $fileManager
bind = SUPER, Space, togglefloating,
bind = SUPER, D, exec, $menu
bind = SUPER, P, pseudo,
bind = SUPER, F, fullscreen
bind = SUPER, C, exec, firefox

# Move focus with mainMod + arrow keys
bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9
bind = SUPER, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4
bind = SUPER SHIFT, 5, movetoworkspace, 5
bind = SUPER SHIFT, 6, movetoworkspace, 6
bind = SUPER SHIFT, 7, movetoworkspace, 7
bind = SUPER SHIFT, 8, movetoworkspace, 8
bind = SUPER SHIFT, 9, movetoworkspace, 9
bind = SUPER SHIFT, 0, movetoworkspace, 10

# Mouse bindings
bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow
EOL
      chown -R puter:users "$HYPR_CONFIG"
    fi
  '';
};




  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.puter = {
    isNormalUser = true;
    description = "-Puter";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "input"];
    packages = with pkgs; [
    #  thunderbird
    pkgs.docker
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
	pkgs.localsend
	# GIT
	pkgs.gh
	pkgs.git
	pkgs.git-lfs
	pkgs.github-desktop
	# SYSTEM
	pkgs.gparted
	pkgs.gnumake
	pkgs.unzip
	pkgs.gcc
	pkgs.ripgrep
	pkgs.ghostty
	pkgs.tmux
	pkgs.yazi
	pkgs.stremio
	pkgs.code-cursor
	xclip
	# language
	pkgs.go
	pkgs.fnm
	pkgs.docker
	pkgs.glibc
	 # Wayland Essentials
	  waybar
	  dunst
	  rofi-wayland

	    # System Tray
	  swaynotificationcenter # Notification daemon
	  
	  # Additional utilities
	  jq # JSON processor
	  socat # Multipurpose relay
	  light # Backlight control
	  
	  # System Utilities
	  networkmanagerapplet
	  blueman
	  pavucontrol
	  
	  # Screenshots and Notifications
	  grim
	  slurp
	  wl-clipboard
	  
	  # File Manager
	  # thunar
	  
	  # Appearance
	  qt5.qtwayland
	  qt6.qtwayland
	  xdg-desktop-portal-hyprland
  ];

	environment.sessionVariables = {
	  NIXOS_OZONE_WL = "1";
	  WLR_NO_HARDWARE_CURSORS = "1";
	  TERMINAL = "ghostty";
	  EDITOR = "nvim";
	  BROWSER = "firefox";
	  # For NVIDIA GPU
	  WLR_RENDERER = "vulkan";
	  XDG_CURRENT_DESKTOP = "Hyprland";
	  XDG_SESSION_DESKTOP = "Hyprland";
	  XDG_SESSION_TYPE = "wayland";
	};



  virtualisation.docker.enable = true;
  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Script to clone and setup kickstart.nvim
  system.activationScripts.cloneKickstartNvim = {
    deps = ["users"];
    text = ''
      USER_HOME="/home/puter"  # Replace with your username
      NVIM_CONFIG="$USER_HOME/.config/nvim"
      
      if [ ! -d "$NVIM_CONFIG" ]; then
        ${pkgs.git}/bin/git clone https://github.com/puterhimself/nvim "$NVIM_CONFIG"
        chown -R puter:users "$NVIM_CONFIG"  
      fi
    '';
  };

  # Games
  programs.steam.enable = true;

  

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 42d";
  };
}
