{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, python3
, python3Packages
, gtk4
, glib
, gobject-introspection
, wrapGAppsHook4
, dconf
, gnome-desktop
, libappindicator-gtk3
, libwnck3
, mesa-demos
, webkitgtk_4_1
, webkitgtk_6_0
, xdg-user-dirs
, yt-dlp
, desktop-file-utils
, shared-mime-info
, gdk-pixbuf
, gtk3
, ffmpeg
, libvdpau
, vdpauinfo
, vlc
}:

python3Packages.buildPythonApplication rec {
  pname = "hidamari";
  version = "3.6";
  pyproject = false; # Uses meson, not pyproject

  src = fetchFromGitHub {
    owner = "jeffshee";
    repo = "hidamari";
    rev = "c57502076a0272cd09971ec4c8c4a07b9bf0c959";
    hash = "sha256-4hpznrnV1Mc2GVh2Oo4y6/M++YtEO3snHkfzP2kog50=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
    shared-mime-info
    gdk-pixbuf # for icon cache generation
  ];

  buildInputs = [
    gtk4
    gtk3
    glib
    dconf
    gnome-desktop
    libappindicator-gtk3
    libwnck3
    webkitgtk_4_1
    webkitgtk_6_0
    xdg-user-dirs
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    pillow
    pydbus
    requests
    setproctitle
    python-vlc
    yt-dlp  # Python module for yt-dlp
  ];

  # Runtime dependencies that need to be available in PATH
  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [
      mesa-demos # provides glxinfo, used for hardware info
      yt-dlp     # for streaming URL support
      ffmpeg     # provides ffprobe for video metadata
      vdpauinfo  # provides vdpauinfo for VDPAU hardware acceleration detection
      vlc        # VLC media player
    ]}"
    # Force XWayland for better NVIDIA compatibility (more aggressive)
    "--set GDK_BACKEND x11"
    "--set QT_QPA_PLATFORM xcb"
    "--set SDL_VIDEODRIVER x11"
    "--unset WAYLAND_DISPLAY"
    # Ensure we have X11 display
    "--set-default DISPLAY :0"
    # Enable hardware acceleration
    "--set LIBVA_DRIVER_NAME nvidia"
    "--set VDPAU_DRIVER nvidia"
    # Additional NVIDIA optimizations
    "--set __GL_SYNC_TO_VBLANK 1"
    "--set __GL_VRR_ALLOWED 0"
    # VLC specific optimizations and configuration
    "--set VLC_PLUGIN_PATH ${vlc}/lib/vlc/plugins"
    "--set VLC_CONFIG_DIR $out/share/hidamari/vlc"
    "--set VLC_DATA_PATH ${vlc}/share/vlc"
    # Force VLC to use our hardware acceleration config
    "--set VLC_VERBOSE 2"
    # Add Python path for proper module imports
    "--prefix PYTHONPATH : $out/share/hidamari"
    # GSchema path for dconf and desktop integration
    "--prefix XDG_DATA_DIRS : ${gnome-desktop}/share"
    "--prefix XDG_DATA_DIRS : ${shared-mime-info}/share"
  ];

  # Enable hardware acceleration support
  postInstall = ''
    # Ensure the application can find its schemas
    if [ -d "$out/share/glib-2.0/schemas" ]; then
      glib-compile-schemas $out/share/glib-2.0/schemas/
    fi
    
    # Create VLC configuration for hardware acceleration
    mkdir -p $out/share/hidamari/vlc
    cat > $out/share/hidamari/vlc/vlcrc << EOF
# VLC configuration for hidamari - optimized for NVIDIA hardware acceleration
[core]
# Force hardware acceleration
avcodec-hw=vdpau
# Video output
vout=gl
# Disable unnecessary video filters
video-filter=
# Increase caching for better performance
file-caching=5000
network-caching=5000
# Force X11 backend
intf=dummy
# Disable hardware overlay (can cause issues with wallpapers)
overlay=0
# Optimize for video wallpaper use case
video-on-top=0
no-video-title-show=1
EOF
    
    # Compile Python bytecode for better performance and import reliability
    ${python3.pythonOnBuildForHost.interpreter} -m compileall -f $out/share/hidamari/ || true
  '';

  # Skip phases that don't apply to meson builds
  dontUsePipInstall = true;
  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  meta = with lib; {
    description = "Video wallpaper for Linux. Written in Python";
    longDescription = ''
      Hidamari is a video wallpaper application for Linux that offers features like:
      - Autostart after login
      - Apply static wallpaper with blur effect
      - Detect maximized window and fullscreen mode
      - Volume control and pause/mute functionality
      - Hardware accelerated video decoding
      - GNOME Wayland support
      - Multi-monitor support
      - Streaming URL support (YouTube, etc.)
      - Webpage as wallpaper support
      
      This package is optimized for NVIDIA users and forces XWayland mode
      for better hardware acceleration while keeping your Wayland session.
    '';
    homepage = "https://github.com/jeffshee/hidamari";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ]; # Add your name here
    platforms = platforms.linux;
    mainProgram = "hidamari";
  };
}
