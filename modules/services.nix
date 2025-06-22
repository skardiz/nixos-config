{ ... }:
{
  services.pipewire = { enable = true; pulse.enable = true; };

  # Минимально необходимая настройка: повышаем приоритет нужных устройств
  environment.etc."wireplumber/main.lua.d/51-default-devices.lua" = {
    text = ''
      -- Правило 1: Сделать "Встроенное аудио" выходом по умолчанию
      rule = {
        matches = {
          { "node.name", "equals", "alsa_output.pci-0000_00_1f.3.analog-stereo" }
        },
        apply_properties = { ["node.priority"] = 2001 }
      }

      -- Правило 2: Сделать "Razer Seiren Pro" микрофоном по умолчанию
      rule = {
        matches = {
          { "node.name", "equals", "alsa_input.usb-Razer_Inc._Razer_Seiren_Pro_UC1712132400427-00.analog-stereo" }
        },
        apply_properties = { ["node.priority"] = 2001 }
      }
    '';
  };
}
