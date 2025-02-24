{
  description = "A very basic flake to get maomaowm running";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {

    packages.x86_64-linux.maomaowm = pkgs.stdenv.mkDerivation {
      pname = "maomao";
      version = "v0.1.5";

      src = ./.;

      patches = [
        (pkgs.writeText "fix.diff" /* diff */
         ''
diff --git a/meson.build b/meson.build
index eeec918..a73139b 100644
--- a/meson.build
+++ b/meson.build
@@ -71,5 +48,5 @@ executable('maomao',
 prefix = get_option('prefix')
 desktop_install_dir = join_paths(prefix, 'share/wayland-sessions')
 install_data('maomao.desktop', install_dir : desktop_install_dir)
-install_data('config.conf', install_dir : '/etc/maomao')
+#install_data('config.conf', install_dir : 'etc/maomao')
         ''
        )
      ];

      nativeBuildInputs = with pkgs; [ 
        meson
        cmake
        pkg-config
        ninja
      ];

      buildInputs = with pkgs; [
        wlroots_0_17
        wayland
        wayland-protocols 
        wayland-scanner
        xorg.libxcb.dev
        xorg.xcbutilwm
        libxkbcommon
        libinput
        pixman
        xorg.libX11
      ];

    };

    packages.x86_64-linux.default = self.packages.x86_64-linux.maomaowm;

    nixosModules.default = 
    {config, lib, ...}: 
    with lib; 
    let 
      cfg = config.programs.maomao;
    in
    {
      options = {
        programs.maomao = {
          enable = mkEnableOption ''
            maomaowm is a wayland compositor based on dwl(0.5) , adding many
            operation that supported in hyprland and a hyprland-like keybinds,
            niri-like scroll layout and sway-like scratchpad. See below for
            more features.
          '';

          configFile = mkOption {
            default = ./config.conf;
            type = with types; nullOr path;
            description = ''
              The fallback configuration to use at /etc/maomao/config.conf
              '';
          };

        };
      };

      config = mkIf cfg.enable {
        environment = {
          etc."maomao/config.conf".source = cfg.configFile;
          systemPackages = [ self.packages.x86_64-linux.default ];
        };
      };

    }
    ;
  };
}




