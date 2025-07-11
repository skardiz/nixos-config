# Декларативная Конфигурация NixOS

## 1. Цель

Этот репозиторий представляет собой production-ready фреймворк для управления парком систем и пользовательских окружений на базе NixOS, реализованный по принципам GitOps. Вся конфигурация управляется декларативно, что гарантирует полный версионный контроль, воспроизводимость и аудируемость каждого аспекта инфраструктуры.

Ключевая философия — рассматривать инфраструктуру не как набор серверов для настройки, а как единую, целостную систему, полностью определяемую кодом.

---

## 2. Ключевые Принципы

*   **Инфраструктура как Код (IaC):** 100% состояния системы, от модулей ядра до пакетов на уровне пользователя, определено как код. Ручная настройка или императивные скрипты после развертывания не требуются.
*   **GitOps Workflow:** Репозиторий Git является Единственным Источником Правды (Single Source of Truth). Все изменения в инфраструктуре управляются через коммиты и пул-реквесты, обеспечивая полный аудиторский след.
*   **Атомарные и Воспроизводимые Развертывания:** Nix Flakes и файл `flake.lock` гарантируют, что любая сборка будет побитово воспроизводима. Обновления системы атомарны; неудачное развертывание приводит к автоматическому откату до последнего рабочего состояния.
*   **Управление Секретами (DevSecOps):** Интеграция с `sops-nix` для сквозного шифрования секретов. Конфиденциальные данные хранятся в зашифрованном виде непосредственно в репозитории Git и расшифровываются только в памяти или во временные файлы во время выполнения.
*   **Модульная и Масштабируемая Архитектура:** Конфигурация разделена на логические, переиспользуемые модули (`hosts`, `users`, `features`, `roles`). Такая структура позволяет быстро добавлять новые хосты и пользователей с минимальным дублированием кода.

---

## 3. Ключевые Технические Решения

### Динамическое Управление Хостами и Пользователями
*   **Архитектура:** Корневые файлы `flake.nix` и `outputs.nix` спроектированы для автоматического обнаружения и сборки всех конфигураций хостов и пользователей.
*   **Функциональность:** Для добавления нового хоста достаточно создать новую директорию в `./hosts`. Чтобы назначить пользователя этому хосту, его имя добавляется в список в локальном файле `flake.nix` хоста. Модификация корневой конфигурации не требуется.
*   **Результат:** Радикально упрощает масштабирование и управление, снижая накладные расходы и риск человеческой ошибки.

### Пользовательский API для Конфигурации
*   **Архитектура:** В `modules/system/options.nix` определена высокоуровневая система опций. Это создает кастомный API (например, `my.optimizations.enableSsdTweaks = true;`), который абстрагирует низкоуровневые настройки NixOS.
*   **Функциональность:** Вместо того чтобы разбрасывать настройки по множеству файлов, параметры управляются через централизованный, человекочитаемый API.
*   **Результат:** Обеспечивает консистентность по всему парку систем, упрощает конфигурацию и делает систему самодокументируемой.

### Безопасное Управление Сервисами: Пример `AmneziaWG`
*   **Интеграция на уровне ядра:** Модуль ядра `amneziawg` собирается декларативно для конкретного используемого ядра (`config.boot.kernelPackages.amneziawg`) и явно загружается при старте системы (`boot.kernelModules`).
*   **Безопасная инъекция конфигурации:** Системный сервис `amnezia-vpn.service` не использует статический файл конфигурации. Вместо этого его стартовый `script` динамически выполняет следующие действия:
    1.  Ожидает запуска сервиса `sops-nix`, который монтирует расшифрованные секреты.
    2.  Считывает `PrivateKey` из защищенного пути (`${config.sops.secrets.vpn_private_key.path}`).
    3.  Генерирует временный файл конфигурации в эфемерной директории `/run/amnezia-vpn/`.
    4.  Устанавливает на временный файл строгие права доступа (`chmod 600`).
    5.  Запускает VPN, используя эту временную, безопасную конфигурацию.
*   **Результат:** Демонстрирует эталонный подход к управлению сервисами с конфиденциальными данными, гарантируя, что приватные ключи никогда не хранятся на диске в открытом виде.

---

## 4. Развертывание

Управление системой осуществляется стандартными командами Nix.

**Применить общесистемную конфигурацию для конкретного хоста:**
```
sudo nixos-rebuild switch --flake .#shershulya
