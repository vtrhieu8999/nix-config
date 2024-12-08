# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];
  
  boot = {
    kernelModules = [ "kvmgt" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ 
  	"intel_iommu=on" 
  	"iomem=relaxed"
  	"nvidia-drm.fbdev=1" 
  	"nvidia.NVreg_PreserveVideoMemoryAllocations=1" 
    ];
    blacklistedKernelModules = [ 
      #"nouveau" 
    ];
    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub = {
        device = "nodev";
        efiSupport = true;
      };
    };
  };
  

  # "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" 
  #boot.extraModprobeConfig = ''
  #  softdep drm pre: vfio-pci
  #  options vfio-pci ids=10de:1d10
  #'';
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };
  
  i18n.inputMethod = {
    #enabled = "ibus";
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ m17n bamboo ];
    #type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      libsForQt5.fcitx5-unikey
      fcitx5-bamboo
    ];
  };

  services.flatpak.enable = true;
  services.fwupd.enable = true;
  #services.xscreensaver.enable = true;

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
    excludePackages = with pkgs; [ xorg.xorgserver ];
    
    displayManager.gdm.enable = true;	
    desktopManager = {
      gnome.enable = true;
      # plasma5.enable = true;
    };
    
    videoDrivers = [ "nvidia" "fbdev" "modesetting" ];
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  services.pcscd.enable = true; 
  services.pcscd.plugins = with pkgs; [ acsccid ];

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  #sound.enable = true;
  security.rtkit.enable = true;
  #services.jack.jackd.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hieu = {
    isNormalUser = true;
    description = "Vuong Trung Hieu";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    ];
  };
  
  home-manager.users.hieu = { pkgs, ... }: {
    home.stateVersion = "25.05";
    home.packages = [  ];
  };
  
  environment.sessionVariables = {
  	WLR_NO_HARDWARE_CURSORS = "1";
  	#VK_DRIVER_FILES= "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  	#GBM_BACKEND= "nvidia-drm";
  	#__GLX_VENDOR_LIBRARY_NAME= "nvidia";
  	#LIBVA_DRIVER_NAME="i915";
  	NIXOS_OZONE_WL = "1";
  #	VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
  	#VULKAN_SDK = config.hardware.opengl.path;
  	#XCURSOR_PATH="/usr/share/icons";
	XCURSOR_THEME="Adwaita";
	#XDG_DATA_DIRS="/home/hieu/.nix-profile/share:" + "$XDG_DATA_DIRS";
  };
  
  services.pipewire.wireplumber.configPackages = [
	(pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
		bluez_monitor.properties = {
			["bluez5.enable-sbc-xq"] = true,
			["bluez5.enable-msbc"] = true,
			["bluez5.enable-hw-volume"] = true,
			["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
		}
	'')
  ];
  
  hardware.enableAllFirmware = true;
  systemd.services.NetworkManager-wait-online.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller on boot
  
  hardware = {
  	graphics = {
  		enable = true;
  		enable32Bit = true;
  		extraPackages = with pkgs; [
  		  nvidia-vaapi-driver
                  intel-media-driver # LIBVA_DRIVER_NAME=iHD
                  #libvdpau
                  libvdpau-va-gl
                  #libGL
                  #egl-wayland
                  #eglexternalplatform
                ];
  	};
  	nvidia = {
  		modesetting.enable = true;
  		open = false;
  		powerManagement.enable = true;
  		powerManagement.finegrained = false;
  		nvidiaSettings = true;
  		prime = {
  			offload = {
  				enable = true;
  				enableOffloadCmd = true;
  			};
  			#reverseSync.enable = true;
  			allowExternalGpu = true;
  			
  			#sync.enable = true;
  			intelBusId = "PCI:0:2:0";
    			nvidiaBusId = "PCI:1:0:0";
  		};
  		package = config.boot.kernelPackages.nvidiaPackages.beta;
  	};
  };

  
  # XDG portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-gnome
    ];
  };
  
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
      qemu.ovmf.enable = true;
      qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
      qemu.verbatimConfig = ''
        seccomp_sandbox = 0
      '';
    };
    #lxd.enable = true;
    kvmgt.enable = true;
    kvmgt.vgpus = {
      "i915-GVTg_V5_4" = {
        uuid = [ "d43e3472-bc58-11ee-88e4-8f4e6821c103" ];
      };
    };
    spiceUSBRedirection.enable = true;
    docker.enableNvidia = true;
    waydroid.enable = true;
  };
  
  services.persistent-evdev.enable = true;
  


  # Allow unfree packages
  nixpkgs.config = {
  	allowUnfree = true;
  	enableParallelBuilding = true;
  	max-jobs = 3;
  	cores = 7;
  	permittedInsecurePackages = [
 	  #"electron-28.3.3"
 	  #"electron-27.3.11"
 	  #"electron-29.4.6"
        ];
  };
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    mattermost-desktop
    #teams-for-linux
    zoom
    nethogs
    iftop
    kitty
    vmware-horizon-client
    authenticator
    whatsapp-for-linux
    telegram-desktop
    ats2
    ats-acc
    wezterm
    waybar
    tmux
    #ghc
    #ghcid
    jetbrains.idea-community
    protonvpn-gui
    duckdb
    rustup
    tor
    vulkan-tools
    #rustc
    dotnet-sdk_8
    #haskellPackages.language-ats
    scsh
    curl
    neovim-unwrapped
    ffmpeg-full
    vlc
    brave
    lutris-free
    libportal
    #gradle
    vscodium
    obsidian
    #logseq
    thunderbird
    caprine-bin
    dunst
    eww
    pciutils
    direnv
    git
    libnotify
    swww
    lshw
    wget
    networkmanagerapplet
    localsend
    steam-tui
    wineWow64Packages.stagingFull
    rPackages.graphite
    opencore-amr
    protonup-ng
    proton-caller
    protonup-qt
    winetricks
    protontricks
    vkd3d-proton
    cartridges
    clojure
    clojure-lsp
    leiningen
    clj-kondo
    babashka
    sbcl
    abcl
    jdk17
    #lispPackages.quicklisp
    bun
    nodejs_20
    docker
    docker-compose
    confluent-platform
    ibus-engines.bamboo
    #pulseeffects-legacy
    gnirehtet
    libimobiledevice
    unrar
    pcscliteWithPolkit
    #sssd
    cardpeek
    pcsctools
    opensc
    #woeusb-ng
    ntfs3g
    kvmtool
    spice
    virtio-win
    spice-gtk
    qpwgraph
    xlayoutdisplay
    win-spice
    virtiofsd
    libreoffice-qt
    #quickemu
    #quickgui
    iproute2
    libosinfo
    thunderbolt
    adwaita-icon-theme
    #mdevd
    linuxKernel.packages.linux_xanmod.vhba
    linuxKernel.packages.linux_xanmod.mstflint_access
    #linuxKernel.packages.linux_zen.vmware
    linuxKernel.packages.linux_xanmod.kvmfr
  ]) ++ (with pkgs.gnomeExtensions; [
      thinkpad-battery-threshold
      settingscenter
      window-state-manager
      window-gestures
      forge
      gtile
      tiling-assistant
      vitals
      kimpanel
      coverflow-alt-tab
      dash-to-dock
      #dash-to-dock-animator
      dock-from-dash
      caffeine
      gsconnect
      custom-hot-corners-extended
      clipboard-indicator
  ]);
  
  programs.direnv.enable = true;
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.uwsm.enable = true;
  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };
  programs.cdemu.enable = true;
  programs.xwayland.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = true;
  };
  programs.virt-manager.enable = true;
  #profile-sync-daemon
  programs.mdevctl.enable = true;
  programs.adb.enable = true;
  programs.atop.atopgpu.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.hardware.bolt.enable = true;
  #services.apache-kafka.enable = true;
  # Profile sync daemon
  services.psd.enable = true;
  #services.clamav.daemon.enable = true;
  #@services.clamav.updater.enable = true;
  #services.hoogle.enable = true;
  services.throttled.enable = true;
  #powerManagement.cpufreq.max = 3600000;
  services.undervolt = {
    #temp = 85;
    enable = true;
    coreOffset = -120;
    gpuOffset = -85;
    uncoreOffset = -85;
    #analogioOffset = -45;
  };

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
  system.stateVersion = "23.05"; # Did you read the comment?

}
