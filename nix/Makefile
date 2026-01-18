rebuild:
	@echo "Running darwin-rebuild..."
	sudo -v && sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/.config/nix
	@echo "Running home-manager switch..."
	nix run home-manager/master -- switch -b backup --flake ~/.config/nix
	@echo "All configurations applied!"

home:
	@echo "Running home-manager switch..."
	nix run home-manager/master -- switch -b backup --flake ~/.config/nix
	@echo "Home configurations applied!"

darwin:
	@echo "Running darwin-rebuild..."
	sudo -v && sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/.config/nix
	@echo "Darwin configurations applied!"

cleanup:
	@echo "Cleaning up orphan symlinks..."
	@find "$$HOME" \
		-path "$$HOME/OrbStack/*" -prune -o \
		-path "$$HOME/Library/Containers/*" -prune -o \
		-type l ! -exec test -e {} \; -print | while read -r link; do \
			echo "Removing broken link: $$link"; \
			rm -f "$$link" 2>/dev/null || true; \
		done
	@echo "Cleanup complete!"
