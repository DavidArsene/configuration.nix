{lib, ...}: {
	fileSystems."/tmp/nix/.rw-store" =
		lib.mkImageMediaOverride {
			fsType = "tmpfs";
			options = ["mode=0755" "size=16G"];
			neededForBoot = true;
		};
	# fileSystems."/tmp/nix/.ro-store" =
	# 	lib.mkImageMediaOverride
	# 	{
	# 		fsType = "nfs4";
	# 		device = "192.168.2.192:/export/nix-store";
	# 		options = ["ro"];
	# 		neededForBoot = true;
	# 	};
	# # TODO: ENABLE
	# fileSystems."/nix/store" =
	# 	lib.mkImageMediaOverride
	# 	{
	# 		fsType = "overlay";
	# 		device = "overlay";
	# 		options = [
	# 			"lowerdir=/nix/store"
	# 			"upperdir=/tmp/nix/.rw-store/store"
	# 			"workdir=/tmp/nix/.rw-store/work"
	# 		];
	# 		depends = [
	# 			"/nix/store"
	# 			"/tmp/nix/.rw-store/store"
	# 			"/tmp/nix/.rw-store/work"
	# 		];
	# 	};
}
