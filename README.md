Flake created with Claude 

# Hidamari Nix Flake

A Nix flake for [Hidamari](https://github.com/jeffshee/hidamari), a video wallpaper application for Linux.

## Usage

### Using with Nix Flakes

```bash
# Run directly
nix run github:yourusername/hidamari-flake

# Install to profile
nix profile install github:yourusername/hidamari-flake

# Add to NixOS configuration
{
  inputs.hidamari.url = "github:yourusername/hidamari-flake";
  
  # In your system packages
  environment.systemPackages = [
    inputs.hidamari.packages.${system}.default
  ];
}
# hidamari-flake
