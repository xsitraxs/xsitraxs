# Метаданные репозиториев

Готовые описания и топики для всех 16 репозиториев профиля. Вставь через веб-интерфейс
(**Settings → Description / Topics**) или примени командами `gh` из раздела «Как применить».

Топики — единственное, по чему GitHub ищет репозитории. Сейчас они есть у 3 из 16.

---

## Профиль

| Поле | Значение |
| --- | --- |
| **Bio** | `Инструменты для модов HoI4 и Dota 2, настольные приложения. Rust · TypeScript · Python · GDScript` |
| **Location** | `Россия, Красноярск` |
| **Website** | `https://xsitraxs.github.io/dota-2/` (пока нет лендинга) |

Bio видна в каждом комментарии, issue и pull request — это самое дешёвое изменение из всех.

---

## Закреплённые репозитории (1 из 6 занято)

Порядок имеет значение: первые два видны без прокрутки.

1. `Moonwave` — плеер SoundCloud (18 релизов, 711 скачиваний)
2. `Hoi4_translator` — переводчик локализации HoI4 (20 релизов, 164 скачивания)
3. `home-manager` — домашние дела и трекер воды
4. `dota2analyser` — разбор матчей Dota 2
5. `walking-house` — игра на Godot 4 (93 автотеста)
6. `Smart_File_Organizer` — сортировка файлов с откатом

---

## Описания и топики

### Moonwave
- **Описание:** `Плеер SoundCloud для Windows, macOS и Linux: без рекламы, с текстами песен, эквалайзером и своим оформлением.`
- **Топики:** `soundcloud`, `music-player`, `electron`, `typescript`, `desktop-app`, `lyrics`, `windows`, `macos`, `linux`

### Hoi4_translator
- **Описание:** оставить как есть — оно корректное.
- **Топики:** убрать `python` и `customtkinter` (проект переписан на Rust), добавить `rust`, `cli`.
  Итог: `hoi4`, `hearts-of-iron-iv`, `paradox-interactive`, `game-localization`, `localization`, `translation`, `translator`, `modding`, `hoi4-mod`, `rust`, `cli`, `windows-app`

### home-manager
- **Описание:** оставить как есть.
- **Топики:** оставить как есть (8 штук).

### dota2analyser
- **Описание:** оставить как есть.
- **Топики:** `dota2`, `dota-2`, `esports`, `match-analysis`, `coaching`, `react`, `typescript`, `browser-app`, `opendota`, `steam-api`

### dota-2
- **Описание:** `Драфт-помощник Dota 2 патча 7.41: чем отвечать на их драфт, как играть лейн и что покупать. Работает офлайн в браузере.`
- **Топики:** `dota2`, `draft`, `counter-picks`, `static-site`, `javascript`, `github-pages`, `offline`

### walking-house
- **Описание:** оставить как есть.
- **Топики:** `godot`, `godot4`, `gdscript`, `game`, `survival-game`, `2d`, `indie-game`

### tunatuvuhoi4mod
- **Описание:** оставить как есть.
- **Топики:** `hoi4`, `hearts-of-iron-iv`, `hoi4-mod`, `modding`, `paradox-interactive`, `tuva`, `focus-tree`

### Smart_File_Organizer
- **Описание:** `Сортировка файлов по категориям: dry-run, наблюдение за папкой, поиск дубликатов по SHA-256 и полный откат любого перемещения.`
- **Топики:** `python`, `file-organizer`, `automation`, `cli`, `productivity`, `duplicate-files`, `file-management`

### counter-items
- **Описание:** `Контр-предметы для Dota 2 в Lua-окружении Umbrella: учитывает способности и предметы врагов, роль и уже имеющуюся защиту.`
- **Топики:** `dota2`, `lua`, `umbrella`, `items`, `counter-picks`

### hoi4translator-web
- **Описание:** `Веб-прототип переводчика локализации HoI4 на React: DeepL → Google → MyMemory с фолбэком, глоссарий, предпросмотр.`
- **Топики:** `hoi4`, `localization`, `translation`, `react`, `typescript`, `web-app`

### timernew
- **Описание:** `Таймер для Windows 10/11 на C# + WinUI 3: Mica-фон, тёмная тема, установщик MSIX.`
- **Топики:** `windows`, `winui3`, `csharp`, `dotnet`, `timer`, `desktop-app`, `msix`

### farm-life
- **Описание:** `Прототип фермерского мода для Minecraft на Fabric: продажа урожая, магазин семян, опыт фермера и квесты.`
- **Топики:** `minecraft`, `fabric`, `minecraft-mod`, `java`, `farming`

### lean-late-game
- **Описание:** `Эксперимент: снижение нагрузки на CPU в поздней игре Hearts of Iron IV (1943+) через ИИ, defines и on_actions.`
- **Топики:** `hoi4`, `hearts-of-iron-iv`, `performance`, `optimization`, `modding`

### invoker-sunstrike-game
- **Описание:** `Ранний каркас исследования производительности Hearts of Iron IV в поздней игре.`
- **Топики:** `hoi4`, `performance`, `research`, `modding`

### umbrlua
- **Описание:** либо заполнить, когда появится код, либо **заархивировать** — сейчас в репозитории только LICENSE.
- **Топики:** `lua`, `umbrella`, `library`

---

## Как применить

Готовые команды (выполнять по одной, заменив описание на нужное):

```bash
# Описание
gh repo edit xsitraxs/Moonwave \
  --description "Плеер SoundCloud для Windows, macOS и Linux: без рекламы, с текстами песен, эквалайзером и своим оформлением."

# Топики
gh repo edit xsitraxs/Moonwave \
  --add-topic soundcloud --add-topic music-player --add-topic electron \
  --add-topic typescript --add-topic desktop-app --add-topic lyrics

# Убрать неверные топики у Hoi4_translator
gh repo edit xsitraxs/Hoi4_translator --remove-topic python --remove-topic customtkinter
gh repo edit xsitraxs/Hoi4_translator --add-topic rust --add-topic cli

# Профиль
gh api -X PATCH user --input - <<'JSON'
{"bio": "Инструменты для модов HoI4 и Dota 2, настольные приложения. Rust · TypeScript · Python · GDScript",
 "location": "Россия, Красноярск"}
JSON
```

Закрепление репозиториев настраивается только в веб-интерфейсе:
профиль → **Customize your pins** → выбрать 6 репозиториев.

---

## Отдельно: пропущенные лицензии

Без файла `LICENSE` формально нельзя использовать, форкать и распространять код, даже если
репозиторий публичный. Сейчас лицензии нет у:

| Репозиторий | Почему важно |
| --- | --- |
| `timernew` | 8 релизов, установщик MSIX — люди скачивают бинарник без прав на использование |
| `home-manager` | В README заявлено «free open-source», но лицензии нет |
| `tunatuvuhoi4mod` | Мод для HoI4 — без лицензии нельзя включать в сборки |
| `invoker-sunstrike-game` | Каркас, но публичный |

`farm-life` определяется как `NOASSERTION` — скорее всего нестандартный текст, стоит привести к MIT.

Рекомендация: MIT для утилит и библиотек, GPL-3.0 для приложений (как у Moonwave).
