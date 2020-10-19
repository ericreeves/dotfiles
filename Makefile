install:
	@scripts/install_zinit.sh
	@scripts/install_brew.sh
	@scripts/install_fonts.sh
	@scripts/configure_mac_defaults.sh
	@scripts/install_dotfiles.sh
	@scripts/install_python_modules.sh

python:
	@scripts/install_python_modules.sh