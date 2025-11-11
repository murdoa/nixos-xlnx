{ fetchFromGitHub
, buildUBoot
, platform ? "zynqmp"
, xlnxVersion ? "2025.1"
, enableSPL ? false
, deviceTree ? null
}:

let
  ubootVersion = {
    "2024.1" = "2024.01";
    "2025.1" = "2025.01";
  }.${xlnxVersion};
in

buildUBoot {
  version = "${ubootVersion}-xilinx-v${xlnxVersion}";

  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "u-boot-xlnx";
    rev = {
      "2024.1" = "xlnx_rebase_v2024.01_2024.1";
      "2025.1" = "xlnx_rebase_v2025.01_2025.1";
    }.${xlnxVersion};
    hash = {
      "2024.1" = "sha256-G6GOcazwY4A/muG2hh4pj8i9jm536kYhirrOzcn77WE=";
      "2025.1" = "sha256-RTcd7MR37E4yVGWP3RMruyKBI4tz8ex7mY1f5F2xd00=";
    }.${xlnxVersion};
  };

  defconfig = "xilinx_${platform}_virt_defconfig";
  extraMeta.platforms = if platform == "zynq" then [ "armv7l-linux" ] else [ "aarch64-linux" ];

  # Add device tree override if specified for SPL builds
  extraConfig = if enableSPL && deviceTree != null then ''
    CONFIG_DEFAULT_DEVICE_TREE="${deviceTree}"
  '' else "";

  filesToInstall = [ "u-boot.elf" ] ++ (if enableSPL then [
    "spl/boot.bin"
    "u-boot.img"
  ] else []);
}
