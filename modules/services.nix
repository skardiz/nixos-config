{ ... }:
{
  services.pipewire = { enable = true; pulse.enable = true; };
  environment.etc."wireplumber/main.lua.d/51-default-devices.lua" = {
    text = ''
      rule = {
        matches = { { "node.name", "equals", "alsa_output.pci-0000_00_1f.3.analog-stereo" } },
        apply_properties = { ["node.priority"] = 2001 }
      }
      rule = {
        matches = { { "node.name", "equals", "alsa_input.usb-Razer_Inc._Razer_Seiren_Pro_UC1712132400427-00.analog-stereo" } },
        apply_properties = { ["node.priority"] = 2001 }
      }
    '';
  };
}
