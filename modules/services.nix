{ ... }:
{
  # Включаем PipeWire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Создаем кастомное правило для WirePlumber,
  # чтобы задать аудиоустройства по умолчанию.
  environment.etc."wireplumber/main.lua.d/51-default-devices.lua" = {
    text = ''
      -- Правило для устройства вывода звука
      rule = {
        matches = {
          {
            -- Условие 1: Это должно быть устройство вывода (sink)
            { "media.class", "equals", "Audio/Sink" },
            -- Условие 2: Название должно содержать "Built-in Audio"
            { "node.description", "matches", "*Built-in Audio*" }
          }
        },
        apply_properties = {
          -- Присваиваем высокий приоритет, чтобы сделать его устройством по умолчанию
          ["node.priority"] = 2001
        }
      }

      -- Правило для микрофона
      rule = {
        matches = {
          {
            -- Условие 1: Это должно быть устройство ввода (source)
            { "media.class", "equals", "Audio/Source" },
            -- Условие 2: Название должно содержать "Razer Seiren Pro"
            { "node.description", "matches", "*Razer Seiren Pro*" }
          }
        },
        apply_properties = {
          -- Присваиваем высокий приоритет, чтобы сделать его устройством по умолчанию
          ["node.priority"] = 2001
        }
      }
    '';
  };
}
