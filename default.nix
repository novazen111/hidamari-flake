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
}:

python3Packages.buildPythonApplication rec {
  pname = "hidamari";
  version = "3.6";
  pyproject = false; # Uses meson, not pyproject

  src = fetchFromGitHub {
    owner = "jeffshee";
    repo = "hidamari";
    rev = "v${version}";
    hash = "sha256-4hpznrnV1Mc2GVh2Oo4y6/M++YtEO3snHkfzP2kog50="; # Replace with actual hash
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
      libvdpau   # provides vdpauinfo for hardware acceleration detection
    ]}"
    # Add Python path for proper module imports
    "--prefix PYTHONPATH : $out/share/hidamari"
    # GSchema path for dconf and desktop integration
    "--prefix XDG_DATA_DIRS : ${gnome-desktop}/share"
    "--prefix XDG_DATA_DIRS : ${shared-mime-info}/share"
  ];

  # Enable hardware acceleration support
  postInstall = ''
    # Ensure the application can find its schemas
    glib-compile-schemas $out/share/glib-2.0/schemas/
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
    '';
    homepage = "https://github.com/jeffshee/hidamari";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ]; # Add your name here
    platforms = platforms.linux;
    mainProgram = "hidamari";
  };
}
