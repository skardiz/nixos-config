# overlays/default.nix
#
# Мы полностью убираем отсюда dpitunnel.
# Этот файл может остаться для других пакетов в будущем,
# но сейчас он должен быть либо пустым, либо не содержать dpitunnel.
final: prev: {
  # dpitunnel = prev.callPackage ../pkgs/dpitunnel; <-- ЭТА СТРОКА УДАЛЕНА
}
