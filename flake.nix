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
      # src = pkgs.fetchFromGitHub {
      #   owner = "DreamMaoMao";
      #   repo = "maomaowm";
      #   rev = "0.1.5";
      #   hash = "sha256-YhEIZptEYa03jRlG3v/Hv7ULh905quws/qZ9vFR3coE=";
      # };

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
        programs.maomao.enable = mkEnableOption "test";
      };

      config = mkIf cfg.enable {
        environment = {
          etc."maomao/config.conf".source = ./config.conf;
          systemPackages = [ self.packages.x86_64-linux.default ];
        };
      };

    }
    ;
  };
}




