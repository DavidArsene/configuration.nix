{pkgs, ...}: {
	environment.systemPackages = with pkgs; [
		(prismlauncher.override
			{
				controllerSupport = false;
				# gamemodeSupport = false;
				textToSpeechSupport = false;
				jdks = [
					# zulu23
					zulu24
				];
			})
			umu-launcher-unwrapped
	];
}
