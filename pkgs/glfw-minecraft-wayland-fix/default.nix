{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libGL,
  vulkan-loader,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libxkbcommon,
  libdecor,
}:
let
  inherit (lib) getLib;
  version = "3.4";
in
stdenv.mkDerivation {
  pname = "glfw-minecraft-wayland-fix";
  inherit version;

  src = fetchFromGitHub {
    owner = "glfw";
    repo = "glfw";
    rev = version;
    hash = "sha256-FcnQPDeNHgov1Z07gjFze0VMz2diOrpbKZCsI96ngz0=";
  };

  patches = [
    ./0001-Key-Modifiers-Fix.patch
    ./0002-Fix-duplicate-pointer-scroll-events.patch
    ./0003-Implement-glfwSetCursorPosWayland.patch
    ./0004-Fix-Window-size-on-unset-fullscreen.patch
    ./0005-Avoid-error-on-startup.patch
    # 0006 Add warning about being an unofficial patch
    ./0007-Fix-fullscreen-location.patch
    ./0008-Fix-forge-crash.patch
  ];

  propagatedBuildInputs = [ libGL ];

  nativeBuildInputs = [
    cmake
    pkg-config

    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
  ];

  postPatch = ''
    substituteInPlace src/wl_init.c \
      --replace-fail '"libdecor-0.so.0"' '"${getLib libdecor}/lib/libdecor-0.so.0"' \
      --replace-fail '"libwayland-client.so.0"' '"${getLib wayland}/lib/libwayland-client.so.0"' \
      --replace-fail '"libwayland-cursor.so.0"' '"${getLib wayland}/lib/libwayland-cursor.so.0"' \
      --replace-fail '"libwayland-egl.so.1"' '"${getLib wayland}/lib/libwayland-egl.so.1"' \
      --replace-fail '"libxkbcommon.so.0"' '"${getLib libxkbcommon}/lib/libxkbcommon.so.0"'
  '';

  cmakeFlags = [
    # Static linking isn't supported
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)

    # the wayland cult isn't real and can't hurt you
    (lib.cmakeBool "GLFW_BUILD_X11" false)
  ];

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-D_GLFW_GLX_LIBRARY=\"${getLib libGL}/lib/libGLX.so.0\""
      "-D_GLFW_EGL_LIBRARY=\"${getLib libGL}/lib/libEGL.so.1\""
      "-D_GLFW_OPENGL_LIBRARY=\"${getLib libGL}/lib/libGL.so.1\""
      "-D_GLFW_GLESV1_LIBRARY=\"${getLib libGL}/lib/libGLESv1_CM.so.1\""
      "-D_GLFW_GLESV2_LIBRARY=\"${getLib libGL}/lib/libGLESv2.so.2\""
      "-D_GLFW_VULKAN_LIBRARY=\"${getLib vulkan-loader}/lib/libvulkan.so.1\""
      # This currently omits _GLFW_OSMESA_LIBRARY. Is it even used?
    ];
  };

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "The same GLFW y'all know and love but extensively patched for Minecraft on Wayland (no X11 support)";
    homepage = "https://www.glfw.org/";
    license = lib.licenses.zlib;
    platforms = lib.platforms.unix;
  };
}
