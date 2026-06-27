{
  config,
  custom,
  lib,
  pkgs,
  ...
}:
let
  res = {
    w = 3200;
    h = 2000;
    s = 1;
    # str.__functor = this: _: traceVal "${toString w}x${toString h}";
    # __functor = this: scl: mapAttrs (_: v: if isInt v then v * scl else v) this;
  };

  # Revert the scale applied by KDE
  scaleRes = scl: lib.mapAttrs (_: v: lib.ceil (v * scl));
  resScaled = scaleRes (1 / 1.25) res;
  resString = with resScaled; "${toString w}x${toString h}";

  ini = {
    app = {
      # configFile = null; # A file to read additional configuration from
      # renderer = "EGL"; # Specify the renderer to use
      # license = "no"; # Show the license for this application and then terminate
      # cursorPollInterval = 1000; # How often to check for a cursor update in microseconds
      # framePollInterval = 1000; # How often to check for a frame update in microseconds
      # allowDMA = true; # Allow direct DMA transfers if supported
      # shmFile = "/dev/kvmfr0"; # The shared memory file path or kvmfr device name
    };

    win = {
      title = "Looking Glass"; # The window title
      # position = "center"; # Initial position
      size = resString; # Initial size
      # autoResize = false; # Auto resize the window to the guest
      # allowResize = true; # Allow manual resize
      # keepAspect = true; # Maintain aspect ratio
      # forceAspect = true; # Force window to maintain aspect ratio
      dontUpscale = true; # Never upscale the window
      # intUpscale = false; # Only integer upscaling
      shrinkOnUpscale = true; # Limit dimensions when dontUpscale is enabled
      # borderless = false; # Borderless mode
      fullScreen = true; # Launch fullscreen
      # maximize = false; # Maximized window
      # minimizeOnFocusLoss = false; # Minimize on focus loss
      # fpsMin = - 1; # Minimum frame rate
      # ignoreQuit = false; # Ignore quit requests
      noScreensaver = true; # Prevent screensaver
      # autoScreensaver = false; # Disable screensaver on guest request
      # alerts = true; # Show on-screen alert messages
      quickSplash = true; # Skip splash screen fade-out
      # overlayDimsDesktop = false; # Dim desktop in overlay mode
      # rotate = 0; # Rotate displayed image (0, 90, 180, 270)
      # uiFont = "DejaVu Sans Mono"; # UI font
      # uiSize = 14; # UI font size
      # jitRender = false; # Just-in-time rendering FIXME: test
      # requestActivation = true; # Request activation when needed
      showFPS = true; # Enable FPS and UPS display
    };

    input = {
      captureOnFocus = true; # Enable capture on focus
      # grabKeyboard = true; # Grab keyboard in capture mode
      # grabKeyboardOnFocus = false; # Grab keyboard on focus
      # releaseKeysOnFocusLoss = true; # Release keys on focus loss
      # escapeKey = 70; # Escape/menu key (70 = KEY_SCROLLLOCK)
      escapeKey = 634; # Escape/menu key (634 = KEY_SELECTIVE_SCREENSHOT)
      # ignoreWindowsKeys = false; # Do not pass Windows key events to the guest
      # hideCursor = true; # Hide local mouse cursor
      # mouseSens = 0; # Mouse sensitivity (-9 to 9)
      # mouseSmoothing = true; # Apply smoothing (if rawMouse not used)
      # rawMouse = true; # Use RAW mouse input
      # mouseRedraw = true; # Mouse movements trigger redraw
      # autoCapture = false; # Keep mouse captured
      # captureOnly = false; # Enable input via SPICE only in capture mode
      # helpMenuDelay = 200; # Escape key help menu delay in ms
    };

    spice = {
      ################### enable = false; # Enable built-in SPICE client
      # host = "/opt/PVM/vms/Windows/windows.sock"; # SPICE server host/socket
      # port = 0; # SPICE server port (0 = UNIX socket)
      # input = true; # Use SPICE for input
      # clipboard = true; # Synchronize clipboard
      # clipboardToVM = true; # Allow clipboard to VM
      # clipboardToLocal = true; # Allow clipboard from VM
      # audio = true; # Enable SPICE audio
      # scaleCursor = true; # Scale cursor input for screen size
      # captureOnStart = false; # Capture on start
      # alwaysShowCursor = false; # Always show host cursor
      # showCursorDot = true; # Use dot cursor when unfocused
      # largeCursorDot = true; # Use larger dot cursor
    };

    audio = {
      # periodSize = 256; # Audio device period size
      # bufferLatency = 12; # Buffer latency in ms
      # micDefault = "allow"; # Microphone default action
      # micShowIndicator = true; # Show microphone usage indicator
      # syncVolume = true; # Synchronize volume with guest
    };

    egl = {
      # vsync = false; # Enable VSYNC
      # doubleBuffer = false; # Enable double buffering
      # multisample = true; # Enable multisampling
      # nvGainMax = 1; # Maximum night vision gain
      # nvGain = 0; # Initial night vision gain
      # cbMode = 0; # Color Blind Mode
      # scale = 0; # Scaling algorithm
      # debug = false; # Enable debug output
      # noBufferAge = false; # Disable buffer-age rendering
      # noSwapDamage = false; # Disable damage-based swapping
      # scalePointer = true; # Maintain 1:1 pointer size
      # mapHDRtoSDR = true; # Map HDR to SDR color space
      # peakLuminance = 250; # Peak luminance (HDR to SDR)
      # maxCLL = 10000; # Maximum content light level (HDR to SDR)
      # preset = null; # Initial filter preset
    };

    opengl = {
      # mipmap = true; # Enable mipmapping
      # vsync = false; # Enable VSYNC
      # preventBuffer = true; # Prevent driver buffering
      amdPinnedMem = true; # Use GL_AMD_pinned_memory
    };

    wayland = {
      # warpSupport = true; # Enable cursor warping
      # fractionScale = true; # Enable fractional scale
    };

    i3 = {
      # globalFullScreen = true; # Use i3 global fullscreen
    };

    pipewire = {
      # outDevice = "Looking Glass"; # Default playback device
      # recDevice = "PureNoise Mic"; # Default record device
    };
  };

  vmName = "win2k25";
  qemuHook = pkgs.writeShellScript "libvirt-qemu-hook" ''
    #!/usr/bin/env bash
    set -euo pipefail

    vm="$1"
    phase="$2"
    stage="''${3-}"

    [[ "$vm" == "${vmName}" ]] || exit 0

    case "$phase:$stage" in
      prepare:begin)
        systemctl stop -v nvidia-powerd.service
        modprobe -rv nvidia_{drm,modeset,uvm} nvidia
        ;;
      release:end)
        modprobe -v nvidia_{drm,modeset,uvm} nvidia
        systemctl start -v nvidia-powerd.service
        ;;
    esac
  '';
in
{
  # FIXME H:
  disabledModules = [
    "programs/wayland/hyprland.nix"
  ];

  # 1. libvirt and qemu
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;

      # FIXME input?
      verbatimConfig = ''
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm",

          "/dev/userfaultfd",
          "/dev/kvmfr0", "/dev/vfio/vfio"
        ]
      '';

      # FIXME: check
      vhostUserPackages = with pkgs; [
        vhost-device-sound
        virtiofsd
      ];
    };
    nss.enableGuest = true;

    # FIXME hooks.qemu = qemuHook;
  };

  #! 2. virt-manager
  programs.virt-manager.enable = true;

  # tap.vhost = true; # ?

  # FIXME: virsh net-[auto]start default
  # to start the virbr0 network (on boot)
  # TODO: declarative

  # x. Looking Glass client & Co.
  environment.systemPackages = with pkgs; [
    looking-glass-client
    evsieve
  ];

  # Replace the need for the user to be in the kvm group
  #! FIXME: , TAG+="uaccess"
  services.udev.extraRules = ''
    SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660"
  '';
  users.users.${custom.myself}.extraGroups = [ "kvm" ];

  # https://github.com/NixOS/nixpkgs/pull/318204 TODO: watch for merges / hm module
  environment.etc."looking-glass-client.ini".text =
    with lib.generators;
    toINI {
      mkKeyValue = mkKeyValueDefault {
        mkValueString = v: if lib.isBool v then lib.boolToYesNo v else mkValueStringDefault { } v;
      } "=";
    } ini;

  #! 3. kernel tweaking
  boot = {
    kernelParams = [
      "amd_iommu=on"
      "amd_iommu_dump=1"
      "iommu=pt"
      # FIXME: ?
      "transparent_hugepage=madvise"
    ];

    kernelModules = [
      "kvm-amd"
      "kvmfr"
      "vfio_pci"
    ];

    # TODO: check actually needed
    initrd.kernelModules = [
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
    ];

    extraModulePackages = with config.boot.kernelPackages; [ kvmfr ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=256
      options kvm_amd avic=1
    '';
    # https://blogs.oracle.com/linux/amd-avic TODO read from "QEMU parameters" down
  };

}
