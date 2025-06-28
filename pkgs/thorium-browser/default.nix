# pkgs/thorium-browser/default.nix
{ pkgs, ... }:

# Используем стандартный сборщик Nix
pkgs.stdenv.mkDerivation rec {
  pname = "thorium-browser";
  # Версия на момент написания. Можно обновить, сменив версию и хеш.
  version = "126.0.6478.114";

  # Скачиваем официальный .deb пакет
  src = pkgs.fetchurl {
    url = "https://github.com/Alex313031/thorium/releases/download/M${version}/thorium-browser_${version}_amd64.deb";
    # Хеш SHA256 для проверки целостности файла
    sha256 = "0q2f3p9j1k423z4j89j9h1m0g9f2j3h1l2g3k4j5h6g7f8d9s0a1b2c3d4e5f6g7"; # Замените на актуальный хеш
  };

  # Нам нужна утилита dpkg для распаковки .deb архива
  nativeBuildInputs = [ pkgs.dpkg ];

  # Говорим сборщику не пытаться выполнять configure, build и check
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;

  # Фаза установки: здесь происходит вся магия
  installPhase = ''
    # Создаем директорию для установки
    mkdir -p $out

    # Распаковываем .deb архив в нашу директорию $out
    dpkg-deb -x $src $out

    # .deb распаковывается в структуру /usr/...
    # Перемещаем все из $out/usr/ в корень нашей установки $out
    mv $out/usr/* $out/
    rm -rf $out/usr

    # Важный шаг: исправляем .desktop файл, чтобы он указывал на правильный путь
    # внутри Nix-хранилища, а не на /usr/bin/thorium-browser
    substituteInPlace $out/share/applications/thorium-browser.desktop \
      --replace "/usr/bin/thorium-browser" "$out/bin/thorium-browser"
  '';

  # Мета-информация о пакете
  meta = with pkgs.lib; {
    description = "A fast and privacy-focused Chromium fork";
    homepage = "https://thorium.rocks/";
    license = licenses.bsd3; # Thorium использует лицензию BSD
    platforms = platforms.linux;
    maintainers = with maintainers; [ ]; # Можете добавить свое имя
  };
}
