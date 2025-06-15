{
	pkgs,
	specialArgs,
	...
}: {
	environment.systemPackages = with pkgs; [
		# Nix
		alejandra
		nix-tree
		nixd
		nh
		nix-du
		nix-fast-build
		nix-inspect
		nix-weather
		nvd
		specialArgs.nox.packages.x86_64-linux.default

		# Modern utilities
		bat
		btop
		curlie
		eza
		fastfetch
		fd
		micro
		ncdu
		nushell
		ripgrep #-all?

		# Everything else
		wget
		gh
		iotop-c
		powertop
		efivar
		efitools
		efibootmgr
		sbctl
		sbsigntool
		tinyxxd
	];

	environment.etc."ncdu.conf".text = ''
		--extended
		--exclude-kernfs
		--threads 4
		--show-itemcount
		--show-mtime
		--graph-style eighth-block
		--shared-column unique
		--color dark
	'';

	# programs.gnupg.agent = {
	#   enable = true;
	#   enableSSHSupport = true;
	# };

	programs.git.enable = true;

	programs.yazi = {
		enable = true;
		settings.yazi = {
			manager = {
				sort_by = "natural";
				sort_dir_first = true;
				linemode = "size";
				show_hidden = true;
			};
		};
	};

	services.code-server = {
		enable = false; # true
		user = "david"; # TODO
		group = "users";
		host = "0.0.0.0"; # Allow access from outside
		# port = 4444;
		auth = "none";
		disableTelemetry = true;
		disableUpdateCheck = true;
		disableWorkspaceTrust = true;
	};

	services.tailscale.enable = true;
}
