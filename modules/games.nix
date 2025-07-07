{pkgs, ...}: {
	environment.systemPackages = with pkgs; [
		(prismlauncher.override
			{
				controllerSupport = false;
				# gamemodeSupport = false;
				textToSpeechSupport = false;
				jdks = [
					zulu24
				];
			})
	];
}
