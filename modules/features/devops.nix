# modules/features/devops.nix
#
# Эта фича отвечает за установку инструментов для DevOps:
# Kubernetes, Docker Compose и т.д.
{ pkgs, ... }:

{
  # Просто добавляем нужные пакеты в системные пути.
  # NixOS сама скачает, соберет и установит их.
  environment.systemPackages = with pkgs; [
    # Инструменты для Kubernetes
    minikube
    kubectl
    ansible
    terraform

    # Инструменты для Docker (docker-compose уже часть пакета docker,
    # но можно явно указать, если нужна конкретная версия)
    # docker-compose
  ];
}
