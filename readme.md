# PimOCShop Installer

Простой инсталлер для OpenComputers (OpenOS), который скачивает содержимое публичного GitHub репозитория в домашнюю директорию `/home`, сохраняя структуру папок и файлов.

---

## Требования

- Компьютер с OpenComputers и установленным OpenOS
- В компьютере должен быть компонент `internet` и он должен быть включён
- Lua-библиотека `json.lua` (например, [rxi/json.lua](https://github.com/rxi/json.lua)) должна быть установлена в `/lib/json.lua`

---

## Установка

1. Скачайте скрипт `install.lua` и сохраните его в вашем OpenComputers, например в `/home/install.lua`.

2. Скачайте библиотеку JSON и положите её в `/lib/json.lua`:

   ```sh
   wget https://raw.githubusercontent.com/rxi/json.lua/master/json.lua -O /lib/json.lua
   ```

   Если `wget` недоступен, скачайте файл вручную и скопируйте его в `/lib/json.lua`.

---

## Использование

Запускайте инсталлер с передачей ссылки на GitHub репозиторий и (опционально) ветки:

```sh
lua /home/install.lua <GitHub repo URL> [branch]
```

Пример:

```sh
lua /home/install.lua https://github.com/31415-n/PimOCShop main
```

Если ветка не указана, используется `main` по умолчанию.

---

## Что делает скрипт

- Парсит URL репозитория, получает пользователя и имя репозитория
- Запрашивает список всех файлов и папок из выбранной ветки через GitHub API
- Создаёт папки в `/home` по структуре репозитория
- Скачивает каждый файл по raw.githubusercontent.com и сохраняет в `/home`
- Перезаписывает существующие файлы

---

## Примечания

- Скрипт работает только с публичными репозиториями GitHub
- Для приватных репозиториев нужна дополнительная авторизация (не реализовано)
- Убедитесь, что интернет-компонент в компьютере включён и настроен

---