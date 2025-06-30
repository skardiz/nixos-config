# modules/hardware/intel-cpu.nix
#
# Этот модуль применяет общие оптимизации для процессоров Intel
# из репозитория nixos-hardware.
{ inputs, ... }:
{
  imports = [
    # Указываем путь к модулю внутри нашего нового 'inputs.hardware'
    inputs.hardware.nixosModules.common-cpu-intel
  ];
}
