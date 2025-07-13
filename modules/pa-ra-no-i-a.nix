{...}: {
	# fileSystems."/tmp/nix/.rw-store" = {
	# 	device = "nix-store";
	# 	fsType = "tmpfs";
	# 	options = ["mode=0755" "size=16G"];
	# 	neededForBoot = true;
	# };
	# fileSystems."/tmp/nix/.ro-store" =
	# 	lib.mkImageMediaOverride
	# 	{
	# 		fsType = "nfs4";
	# 		device = "192.168.2.192:/export/nix-store";
	# 		options = ["ro"];
	# 		neededForBoot = true;
	# 	};

	# # TODO: ENABLE
			# fileSystems."/nix/store" = {
			# 	# device = "overlay";
			# 	# fsType = "overlay";
			# 	overlay = {
			# 		lowerdir = ["/nix/store"]; # lol
			# 		upperdir = "/tmp/nixnup";
			# 		workdir = "/tmp/nixwk";
			# 	};
			# 	neededForBoot?
			#   depends ?
			# };
	# Not needed because of the overlay
	#boot.readOnlyNixStore = false;
	# boot.nixStoreMountOpts=["nosuid" "nodev"];

}
