{ ... }:
{
  services.pipewire = { enable = true; pulse.enable = true; };

  # Точная настройка аудиоустройств по умолчанию через WirePlumber
  environment.etc."wireplumber/main.lua.d/51-default-devices.lua" = {
    text = ''
      -- Правило 1: Установить высокий приоритет для встроенного аудиовыхода
      rule = {
        matches = { { { "media.class", "equals", "Audio/Sink" }, { "node.description", "equals", "Built-in Audio Analog Stereo" } } },
        apply_properties = { ["node.priority"] = 2001 }
      }

      -- Правило 2: Принудительно понизить приоритет для аудиовыхода Razer Seiren
      rule = {
        matches = { { { "media.class", "equals", "Audio/Sink" }, { "node.description", "equals", "Razer Seiren Pro Analog Stereo" } } },
        apply_properties = { ["node.priority"] = 1 } -- Очень низкий приоритет
      }

      -- Правило 3: Установить высокий приоритет для микрофона Razer Seiren
      rule = {
        matches = { { { "media.class", "equals", "Audio/Source" }, { "node.description", "equals", "Razer Seiren Pro Analog Stereo" } } },
        apply_properties = { ["node.priority"] = 2001 }
      }
    '';
  };
}
