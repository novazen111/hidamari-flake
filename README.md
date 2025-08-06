

# Hidamari Nix Flake (created using Claude)

A Nix flake for [Hidamari](https://github.com/jeffshee/hidamari), a video wallpaper application for Linux.

## Usage

### Using with Nix Flakes

```bash
# Run directly
nix run github:novazen111/hidamari-flake

# Install to profile
nix profile install github:novazen111/hidamari-flake

# Add to NixOS configuration
{
  inputs.hidamari.url = "github:novazen111/hidamari-flake";
  
  # In your system packages
  environment.systemPackages = [
    inputs.hidamari.packages.${system}.default
    inputs.hidamari.packages.${system}.compat #compatibility ver
  ];
}
# hidamari-flake
# hidamari-flake
