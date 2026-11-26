# Уютно — клиент платформы аренды

Flutter-приложение для [rental_platform](https://github.com/Forumbit/rental_platform):
лента объявлений, карточка с галереей, вход и регистрация с подтверждением почты,
свои объявления с фото (загрузка, удаление, порядок перетаскиванием).

Android, iOS и Web. Адаптивный интерфейс: нижняя навигация на телефоне,
боковая панель на планшете и десктопе. Светлая и тёмная тема, русский и английский.

## Запуск

Версия Flutter закреплена в `.fvmrc`, все команды — через [fvm](https://fvm.app):

```sh
fvm install            # один раз: ставит нужную версию Flutter
fvm flutter pub get
fvm flutter run        # выберите устройство: эмулятор, телефон или Chrome
```

По умолчанию приложение работает с `https://api.your-project.site`. С локальным API:

```sh
fvm flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Для Android-эмулятора локальный компьютер доступен как `http://10.0.2.2:8080`.
Используйте `127.0.0.1`, а не `localhost`: иначе браузер может обратиться к IPv6-адресу.

## Проверки

```sh
fvm flutter analyze
fvm flutter test
```

Тесты покрывают разбор API-ответов и форматирование цен, автообновление токенов
(одновременные 401 → один refresh), адаптивную навигацию, смену языка и темы
и форму объявления (валидация, отправляемые данные, диалог несохранённых изменений).

## Сборка

```sh
fvm flutter build apk --release
fvm flutter build ipa --release
fvm flutter build web --release --no-web-resources-cdn
```

`--no-web-resources-cdn` кладёт движок CanvasKit в сборку, чтобы веб-версия
не зависела от `gstatic.com`. Веб использует адреса без `#` (`/listings/2`),
поэтому сервер должен отдавать `index.html` на любой неизвестный путь.

Веб-версии нужен CORS на API: адрес сайта должен быть в `CORS_ALLOWED_ORIGINS`
на сервере.

## Устройство

```
lib/
  core/      API-клиент с обновлением токенов, тема, форматирование, конфиг
  data/      модели и репозитории (вызовы API)
  state/     Riverpod-провайдеры: авторизация, настройки, ленты с пагинацией
  ui/        роутер (go_router), экраны и общие виджеты
  l10n/      строки: app_ru.arb (основной) и app_en.arb
```

- Токены хранятся в `flutter_secure_storage` (Keychain, зашифрованные
  настройки Android, зашифрованный localStorage в браузере).
- Material подключён через пакет `material_ui`: начиная с Flutter 3.47
  `package:flutter/material.dart` устарел. Делегаты локализации берутся из
  `material_ui` (см. `main.dart`).

Демо-фото объявлений — с Wikimedia Commons под лицензиями CC BY / CC BY-SA,
авторы указаны в описаниях объявлений.
