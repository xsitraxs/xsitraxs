# Готовые исправления

Здесь лежит то, что я не смог применить сам: доступ интеграции ограничен этим репозиторием
(`xsitraxs/xsitraxs`). На другие репозитории есть права на чтение, но любая запись —
push, `gh api -X PATCH`, создание ветки — возвращает `403 Resource not accessible by integration`.

Поэтому изменения подготовлены так, чтобы применить их одной командой у себя локально.

---

## 1. `dota-2-npm-audit-fix.patch` — разблокирует три PR Dependabot

**Проблема.** Шаг `Audit dependencies` (`npm audit --audit-level=moderate`) падает на
транзитивной moderate-уязвимости `minimatch` (GHSA-g3hv-75wg-m249) в цепочке
`eslint → @eslint/config-array → minimatch`. Из-за этого падают **любые** PR, которые не
обновляют ESLint, — включая обновления посторонних пакетов от Dependabot (#22, #20, #16).

**Проверено мной локально на клоне репозитория:**

| Проверка | Результат |
| --- | --- |
| `npm audit --audit-level=moderate` до фикса | 3 moderate уязвимости |
| `npm audit fix` | меняет 5 пакетов, только `package-lock.json` |
| `npm audit --audit-level=moderate` после | `found 0 vulnerabilities` |
| `npm run lint` | проходит |
| `npm test` | «Политика CI соблюдена» |
| `npm run test:ui` | «Проблем не найдено» |
| `npm run test:recognize` | точность 14/14 на реальных кадрах |

Исходный код не менялся — только lock-файл (26 строк добавлено, 18 удалено).
Тест политики `tools/test_ci.mjs` шаг аудита не проверяет, поэтому правки workflow не нужны.

### Применение

```bash
git clone https://github.com/xsitraxs/dota-2.git
cd dota-2
git checkout -b fix/npm-audit-minimatch
git apply /path/to/fixes/dota-2-npm-audit-fix.patch
npm ci
npm audit --audit-level=moderate   # должно быть: found 0 vulnerabilities
git commit -am "fix(deps): обновить lock-файл — снять moderate-уязвимость minimatch"
git push -u origin fix/npm-audit-minimatch
```

Либо ещё короче, без патча — тот же результат:

```bash
npm audit fix && npm run lint && npm test
```

После мержа перезапустить проверки на PR #22, #20, #16 — они станут зелёными.
PR #21 (`eslint` 10.13 → 10.15) уже зелёный, его можно мержить сразу.

### Заодно — чтобы это не повторялось

Добавь `.github/dependabot.yml`: обновления будут приходить сгруппированными и lock-файл
не будет отставать.

```yaml
version: 2
updates:
  - package-ecosystem: npm
    directory: "/"
    schedule:
      interval: weekly
    groups:
      dev-dependencies:
        dependency-type: development
```

---

## 2. Метаданные репозиториев

Скрипт `../scripts/apply-repo-metadata.sh` применяет описания и топики ко всем 14 репозиториям,
которым они нужны, и исправляет неверные топики `Hoi4_translator` (`python`, `customtkinter` →
`rust`, `cli`).

**Linux / macOS:**
```bash
./scripts/apply-repo-metadata.sh --dry-run   # посмотреть, что будет сделано
./scripts/apply-repo-metadata.sh            # применить
```

**Windows (PowerShell):**
```powershell
.\scripts\apply-repo-metadata.ps1 -DryRun   # посмотреть
.\scripts\apply-repo-metadata.ps1          # применить
```

Если PowerShell блокирует запуск скриптов:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\apply-repo-metadata.ps1 -DryRun
```

Нужен `gh`, авторизованный как владелец аккаунта. Оба скрипта идемпотентны и содержат одинаковые данные.

**Вручную** (API этого не умеет): закрепить 6 репозиториев в профиле
(Customize your pins) и заполнить bio.
Список и тексты — в `../docs/repo-metadata.md`.

---

## 3. Что осталось незакрытым

| Задача | Где | Почему не сделано |
| --- | --- | --- |
| `npm audit fix` в `dota-2` | `dota-2` | нет прав на запись |
| Описания и топики | все репозитории | нет прав на изменение метаданных |
| Bio и закреплённые | профиль | GitHub API не поддерживает |
| CI для `home-manager`, `dota2analyser` | те репозитории | нет прав на запись |
| Упавший `farm-life` | `farm-life` | логи истекли, нужен локальный прогон |
| Файлы `LICENSE` | `timernew`, `home-manager`, `tunatuvuhoi4mod`, `invoker-sunstrike-game` | нет прав на запись |
| PR #13 в `dota-2` | `dota-2` | функциональная ветка от 19.10, нужно решение автора |
