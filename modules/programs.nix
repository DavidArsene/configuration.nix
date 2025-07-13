{
	config,
	pkgs,
	...
}: {
	# TODO: use chaotic v4
	environment.systemPackages = with pkgs; [
		# Nix
		alejandra
		nix-tree
		nixd
		nh
		# nix-du
		# nix-fast-build
		# nix-inspect
		# nix-weather
		nvd
		# specialArgs.nox.packages.x86_64-linux.default

		# Modern utilities
		atuin
		bat
		broot
		btop
		curlie
		delta
		eza
		fastfetch
		fd
		micro
		ncdu
		nushell
		ripgrep
		superfile
		zoxide

		# Everything else
		fatrace
		file
		gh
		iotop-c
		powertop
		rustup
		smartmontools
		strace
		strace-analyzer
		sysdig
		tinyxxd

		efivar
		efitools
		efibootmgr
		sbctl
		sbsigntool
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

	programs.java = {
		enable = true;
		package = pkgs.zulu24;
		# binfmt = true;
	};

	programs.git = {
		enable = true;
		config = {
			# TODO: cannot be read from VSCode FSHenv
			user.name = "DavidArsene";
			user.email = "80218600+DavidArsene@users.noreply.github.com";

			core.pager = "delta";
			interactive.diffFilter = "delta --color-only";
			delta.line-numbers = true;
			delta.navigate = true;
			merge.conflictstyle = "zdiff3";
		};
	};

	programs.yazi = {
		enable = true;
		settings.yazi = {
			mgr = {
				sort_by = "natural";
				sort_dir_first = true;
				linemode = "size";
				show_hidden = true;
			};
		};
	};

	services.code-server = {
		enable = false; # true
		user = config.users.flakeGlobal;
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
