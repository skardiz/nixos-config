# pkgs/dpitunnel/default.nix
# Наш чертеж для сборки НОВОГО DPITunnel на C++.
{ lib, stdenv, fetchFromGitHub, cmake, libnl, cpp-httplib }:

stdenv.mkDerivation rec {
  pname = "DPITunnel";
  version = "1.0.3"; # Берем последнюю версию релиза

  src = fetchFromGitHub {
    owner = "txtsd";
    repo = "DPITunnel";
    rev = "v${version}";
    # Обновите хеш, если версия изменится
    hash = "sha256-11f8F/fK1i+e8V5v/w4t6X9b+p7Y9z/C6f8V9s/d7A8=";
  };

  # Указываем инструменты для сборки
  nativeBuildInputs = [ cmake ];
  # Указываем зависимости, которые нужны для сборки
  buildInputs = [ libnl cpp-httplib ];

  meta = with lib; {
    description = "A C++ proxy server that uses desync attacks to bypass DPI";
    homepage = "https://github.com/txtsd/DPITunnel";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ maintainers.skardizone ]; # Вы все еще мейнтейнер!
  };
}
