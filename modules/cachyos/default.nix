{
	lib,
	pkgs,
	...
} @ inputs:
pkgs.callPackage ./packages-for.nix {
	inherit
		(inputs)
		basicCachy
		mArch
		cpuSched
		ticksHz
		tickRate
		preempt
		# withDAMON
		withNTSync
		withHDR
		withoutDebug
		;
	taste = "linux-cachyos-rc";
	configPath = ./config-nix/cachyos-rc.x86_64-linux.nix;
	versions = lib.trivial.importJSON ./versions-rc.json;
}
