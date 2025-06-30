# pkgs/dpitunnel/default.nix
# Наш чертеж для сборки НОВОГО DPITunnel на C++.
{ lib, stdenv, fetchFromGitHub, cmake, libnl, cpp-httplib, openssl }:

stdenv.mkDerivation rec {
  pname = "DPITunnel";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "txtsd";
    repo = "DPITunnel";
    rev = "v${version}";
    hash = "sha256-11f8F/fK1i+e8V5v/w4t6X9b+p7Y9z/C6f8V9s/d7A8=";
  };

  # Указываем инструменты для сборки
  nativeBuildInputs = [ cmake ];

  # --- ГЛАВНОЕ ЗДЕСЬ! ---
  # Мы явно указываем ВСЕ зависимости, которые нужны для сборки,
  # включая 'cpp-httplib' и его зависимость 'openssl'.
  buildInputs = [ libnl cpp-httplib openssl ];

  meta = with lib; {
    description = "A C++ proxy server that uses desync attacks to bypass DPI";
    homepage = "https://github.com/txtsd/DPITunnel";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ maintainers.skardizone ];
  };
}
