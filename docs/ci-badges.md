# Бейджи CI для README проектов

Ни в одном README проекта нет бейджа CI — поэтому падения прогонов никто не замечает.
Все бейджи ниже проверены: соответствующий workflow на `main` **зелёный**.

Вставь строку сразу после заголовка README нужного репозитория.

---

## Готовые бейджи

### Moonwave
```markdown
[![CI](https://github.com/xsitraxs/Moonwave/actions/workflows/ci.yml/badge.svg)](https://github.com/xsitraxs/Moonwave/actions/workflows/ci.yml)
[![Release](https://github.com/xsitraxs/Moonwave/actions/workflows/release.yml/badge.svg)](https://github.com/xsitraxs/Moonwave/actions/workflows/release.yml)
```
Последний прогон: `ci.yml` — success (27.11).

### Hoi4_translator
```markdown
[![CI](https://github.com/xsitraxs/Hoi4_translator/actions/workflows/build.yml/badge.svg)](https://github.com/xsitraxs/Hoi4_translator/actions/workflows/build.yml)
```
Последний прогон: success (15.11). Бейджи релиза и скачиваний уже есть в самом репозитории.

### walking-house
```markdown
[![Tests](https://github.com/xsitraxs/walking-house/actions/workflows/godot-tests.yml/badge.svg)](https://github.com/xsitraxs/walking-house/actions/workflows/godot-tests.yml)
```
Последний прогон: success (04.11).

### dota-2
```markdown
[![CI](https://github.com/xsitraxs/dota-2/actions/workflows/pages.yml/badge.svg?branch=main)](https://github.com/xsitraxs/dota-2/actions/workflows/pages.yml)
```
Последний прогон на `main`: success (23.10). **Параметр `?branch=main` обязателен** — без него
бейдж показывает последний прогон вообще, то есть упавшую проверку на pull request Dependabot.

### tunatuvuhoi4mod
```markdown
[![Tests](https://github.com/xsitraxs/tunatuvuhoi4mod/actions/workflows/tests.yml/badge.svg)](https://github.com/xsitraxs/tunatuvuhoi4mod/actions/workflows/tests.yml)
```
Последний прогон: success (08.11).

### Smart_File_Organizer
```markdown
[![CI](https://github.com/xsitraxs/Smart_File_Organizer/actions/workflows/ci.yml/badge.svg)](https://github.com/xsitraxs/Smart_File_Organizer/actions/workflows/ci.yml)
```
Последний прогон: success (14.10).

### counter-items
```markdown
[![Lua](https://github.com/xsitraxs/counter-items/actions/workflows/lua.yml/badge.svg)](https://github.com/xsitraxs/counter-items/actions/workflows/lua.yml)
```
Последний прогон: success (19.10).

### timernew
```markdown
[![Build](https://github.com/xsitraxs/timernew/actions/workflows/build-msix.yml/badge.svg)](https://github.com/xsitraxs/timernew/actions/workflows/build-msix.yml)
```
Последний прогон: success (14.10).

---

## Не добавлять, пока не починено

### farm-life — бейдж будет красным
```markdown
[![Build](https://github.com/xsitraxs/farm-life/actions/workflows/build.yml/badge.svg)](https://github.com/xsitraxs/farm-life/actions/workflows/build.yml)
```
Последний прогон на `main` (18.10) упал на шаге **Build mod** (`gradle build`).
Логи прогона уже истекли, поэтому причину нужно воспроизвести локально:

```bash
git clone https://github.com/xsitraxs/farm-life.git
cd farm-life
gradle build
```

Наиболее вероятные причины: несовместимость `Java 25` / `Gradle 9.7.1` с версией Fabric Loom,
или отсутствие `gradle-wrapper.jar` (в workflow используется `gradle/actions/setup-gradle`,
а не `./gradlew`, поэтому локальный `gradle` тоже нужен).

### home-manager и dota2analyser — бейджа нет, потому что нет CI

У этих двух приложений workflow отсутствует полностью. Минимальный вариант, который даст
бейдж и поймает поломки сборки (`~/.github/workflows/ci.yml` в каждом репозитории):

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm ci
      - run: npm run build
```

Бейдж после добавления:
```markdown
[![CI](https://github.com/xsitraxs/home-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/xsitraxs/home-manager/actions/workflows/ci.yml)
```

### hoi4translator-web — красный
Последний прогон (26.10) упал, новых не было. Пока проект не реанимирован, бейдж не нужен.
