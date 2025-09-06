{
	config,
	pkgs,
}: {
	services.samba = {
		enable = false;
		package =
			pkgs.samba.override {
				enableLDAP = true;
				enableProfiling = false;
				enableMDNS = false;
				enableDomainController = true;
				enableRegedit = true;
			};
		smbd.extraArgs = [];

		nmbd.enable = false;
		# nmbd.extraArgs = [];
		# winbindd.enable = false;
		winbindd.extraArgs = [];
		usershares.enable = false;

		# TODO: gpo,dns=no
		settings.global = {
			# Configuration
			"comment" = "Welcome to the Dark Side";
			"deadtime" = "15";
			"dns hostname" = "netbios.realm.changeme";
			"force user" = config.custom.user; # ?
			"guest ok" = "yes"; # ?
			"logging" = "systemd";
			"log writeable files on exit" = "yes";
			# "machine password timeout"
			# "mdns name" = "mdns";

			# "idmap backend" = "ad";
			"idmap config * : backend" = "ad / nss";

			"ldap admin dn" = "cn=admin,dc=samba,dc=CHANGEME";
			"ldap delete dn" = "yes";
			"ldap group suffix" = "ou=groups";
			"ldap idmap suffix" = "ou=idmap";
			"ldap machine suffix" = "ou=computers";
			"ldap user suffix" = "ou=users";
			"ldap suffix" = "dc=samba,dc=org";

			"ldapsam:editposix" = "yes"; # ???
			"ldapsam:trusted" = "yes";

			# Compatibility
			"ad dc functional level" = "2016";
			"client min protocol" = "SMB3_11";
			"case sensitive" = "yes";
			"case preserve" = "yes";
			"short preserve case" = "yes";

			# Performance
			"cache directory" = "/tmp/samba/cache";

			"client ldap sasl wrapping" = "plain";
			"client protection" = "plain";
			"client signing" = "disabled";
			"client smb encrypt" = "off";
			"client smb3 encryption algorithms" = "AES-128-GCM";
			"client smb3 signing algorithms" = "AES-128-GCM";
			"kdc default domain supported enctypes" = "aes256-cts-sk";
			"kdc supported enctypes" = "aes128-cts";
			"kerberos encryption types" = "strong";
			# "kerberos method" = "system keytab";
			"ldap server require strong auth" = "no";
			"lm announce" = "no";

			"client use kerberos" = "required";
			# "client use krb5 netlogon" = "yes";

			"disable netbios" = "yes";
			"ea support" = "no"; # ?, xattrs
		};
		settings.public = {
			backend = "tdb";
			dhcp = true;
		};
	};
	# samba-wsdd.enable = true;
}
