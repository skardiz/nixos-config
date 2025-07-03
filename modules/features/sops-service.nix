# modules/features/sops-service.nix
#
# Наш собственный, надежный сервис-медвежатник для расшифровки секретов.
{ config, pkgs, lib, ... }:

{
  # 1. Мы по-прежнему используем sops-nix, но только для одной цели:
  #    чтобы получить доступ к зашифрованному файлу в /nix/store.
  #    Имя 'github_token_placeholder' не имеет значения, это просто метка.
  sops.secrets.github_token_placeholder = {
    sopsFile = ../../secrets.yaml;
  };

  # 2. Создаем системный сервис.
  systemd.services.decrypt-github-token = {
    description = "Decrypt GitHub token from sops file";

    # Мы хотим, чтобы он запустился один раз и остался "активным".
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    # 3. Самая главная магия - скрипт расшифровки.
    script = ''
      # Создаем директорию для нашего расшифрованного секрета в /run (временная память).
      mkdir -p /run/secrets
      # Используем бинарник sops, чтобы расшифровать наш файл
      # и положить результат в /run/secrets/github_token.
      # Мы используем ПРИВАТНЫЙ ключ хоста для расшифровки.
      ${pkgs.sops}/bin/sops --decrypt \
        --identity /etc/ssh/ssh_host_ed25519_key \
        ${config.sops.secrets.github_token_placeholder.path} > /run/secrets/github_token

      # Устанавливаем правильные права, чтобы никто лишний не мог его прочитать.
      chmod 400 /run/secrets/github_token
    '';

    # 4. Запускаем нашего медвежатника при старте системы.
    wantedBy = [ "multi-user.target" ];
  };

  # 5. Говорим Nix, чтобы он ждал, пока наш сервис отработает.
  nix.settings.access-tokens = "github.com=/run/secrets/github_token";
  # Мы должны убедиться, что nix-daemon запустится ПОСЛЕ нашего сервиса.
  systemd.services.nix-daemon.after = [ "decrypt-github-token.service" ];
}
