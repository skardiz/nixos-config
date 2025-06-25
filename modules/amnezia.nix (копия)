# /home/alex/nixos-config/modules/amnezia.nix
{ config, pkgs, ... }:

{
  # --- КЛЮЧЕВОЕ ИЗМЕНЕНИЕ ---
  # 1. Загружаем модуль ядра AmneziaWG при старте системы.
  # Указываем конкретный пакет модуля ядра, соответствующий твоему ядру.
  # Если у тебя Zen-ядро, используй 'linux_zen'.
  # Если стандартное ядро, возможно 'linux_latest' или 'linux_6_6' (проверь свое ядро!).
  boot.extraModulePackages = [
    # config.boot.kernelPackages.amneziawg # Это обычно сработает для стандартного ядра
    # ЕСЛИ У ТЕБЯ ZEN-ЯДРО (или другое специфичное), РАСКОММЕНТИРУЙ СЛЕДУЮЩУЮ СТРОКУ
    # И ЗАКОММЕНТИРУЙ ПРЕДЫДУЩУЮ (config.boot.kernelPackages.amneziawg)!
    pkgs.linuxKernel.packages.linux_zen.amneziawg
  ];

  # 2. Устанавливаем необходимые пакеты для всех пользователей.
  environment.systemPackages = with pkgs; [
    amnezia-vpn       # Графический клиент Amnezia
    amneziawg-tools   # Консольные утилиты, включая awg-quick
    amneziawg-go      # Userspace-реализация как запасной вариант (ОСТАВЛЯЕМ!)
  ];

}
