# Состояние CI и что с ним делать

Проверено 27.11.2026 через GitHub API и локальным прогоном.

---

## Главное: сайт dota-2 работает

Мой прошлый вывод был неверным — исправляю.

`https://xsitraxs.github.io/dota-2/` **живой**: `status: built`, режим публикации `workflow`,
последний успешный деплой — 23.10.2026 (`push` в `main`).

Красные прогоны «GitHub Pages» — это **не деплои, а проверки на pull request'ах Dependabot**.
Они не влияют на опубликованный сайт: деплой выполняется только для `push` в `main`.

Демо-ссылку в README можно оставлять.

---

## Что действительно сломано

Четыре pull request'а Dependabot висят незакрытыми, три из них падают на одном и том же шаге
`Audit dependencies`:

| PR | Обновление | Дата | Результат |
| --- | --- | --- | --- |
| #22 | `playwright-core` 1.64.1 → 1.65.1 | 23.11 | `Audit dependencies` — failure |
| #21 | `eslint` 10.13.0 → 10.15.0 | 23.11 | success |
| #20 | `jsdom` 30.1.3 → 31.0.1 | 16.11 | `Audit dependencies` — failure |
| #16 | `globals` 17.13.0 → 17.14.0 | 09.11 | `Audit dependencies` — failure |
| #13 | `feat: синергия своей команды 5×5` | 19.10 | failure (не зависит от аудита, требует разбора) |

### Причина

`npm audit --audit-level=moderate` находит 3 moderate-уязвимости в цепочке ESLint:

```
minimatch 7.0.0 - 11.0.0
Severity: moderate
minimatch has potential denial of service via globparts amplification
GHSA-g3hv-75wg-m249

3 moderate severity vulnerabilities
```

Уязвимая версия приходит транзитивно: `eslint → @eslint/config-array → minimatch`.
Поэтому **любой** PR, который не обновляет ESLint, падает на аудите — даже если меняет
посторонний пакет. PR #21 прошёл именно потому, что подтянул исправленный `minimatch`.

### Проверенный фикс

Локально воспроизведено и проверено на копии репозитория:

```bash
npm audit fix
```

Меняет 5 пакетов в `package-lock.json`, исходный код не трогает:

```
@eslint/config-array  0.23.5  -> 0.23.6
@isaacs/nonrecursive-glob-match  (новый) -> 1.1.0
brace-expansion       5.0.12  -> 5.1.0
eslint                10.13.0 -> 10.15.0
minimatch             10.2.6  -> 11.0.9
```

После фикса:

- `npm audit --audit-level=moderate` → `found 0 vulnerabilities`
- `npm run lint` → проходит без замечаний
- `npm test` → «Политика CI соблюдена», все проверки зелёные

Тест `tools/test_ci.mjs` шаг аудита не проверяет, поэтому его правки не требуются —
фикс только в lock-файле.

### Порядок действий

1. В `dota-2` выполнить `npm audit fix`, закоммитить `package-lock.json`.
2. Перезапустить проверки на PR #22, #20, #16 — они станут зелёными и смержатся.
3. PR #21 можно смержить сразу.
4. PR #13 разобрать отдельно: это функциональная ветка от 19.10, она могла устареть
   относительно текущего `main`.

---

## Системная проблема: аудит блокирует всё

Сейчас одна moderate-уязвимость в **dev-зависимости** останавливает любые изменения в репозитории.
Это неверный приоритет: dev-зависимости не попадают в артефакт, который уезжает на сайт
(`index.html` + `assets/` + `data/`).

Два варианта, оба лучше текущего:

**Вариант А — оставить блокирующим, но обновлять заранее.**
Добавить `.github/dependabot.yml` с еженедельным обновлением и группировкой,
чтобы lock-файл не отставал:

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

**Вариант Б — вынести аудит в отдельный необязательный job.**
Проверки, которые защищают прод (lint, тесты движка, распознавание, браузерные тесты),
остаются блокирующими; аудит становится сигналом:

```yaml
      - name: Audit dependencies
        continue-on-error: true
        run: npm audit --audit-level=moderate
```

Я бы выбрал **А**: аудит остаётся гейтом, но перестаёт копиться в виде мёртвых PR.

---

## Другие репозитории

| Репозиторий | Последний прогон | Статус |
| --- | --- | --- |
| Moonwave | 27.11 | success (Release) |
| Hoi4_translator | 15.11 | success |
| walking-house | 04.11 | success |
| tunatuvuhoi4mod | 08.11 | success |
| Smart_File_Organizer | 14.10 | success |
| counter-items | 19.10 | success (`lua.yml`) |
| farm-life | 18.10 | **failure** — шаг `Build mod` (`gradle build`), логи истекли, нужен локальный прогон |
| timernew | 14.10 | success |
| hoi4translator-web | 26.10 | failure — последний прогон, больше не запускался |
| home-manager | — | workflow отсутствует |
| dota2analyser | — | workflow отсутствует |

Что стоит сделать:

- **`home-manager` и `dota2analyser`** — нет CI вообще, хотя это два самых крупных приложения
  после Moonwave. Минимум: `npm ci` + `npm run build` на push и PR.
- **`hoi4translator-web`** — упавший прогон от 26.10 так и висит. Если проект заморожен,
  лучше написать это в README, а не оставлять красный крестик.
- **Бейджи.** Ни в одном README нет бейджа CI, поэтому падения никто не замечает.
  Готовые строки:

```markdown
[![CI](https://github.com/xsitraxs/dota-2/actions/workflows/pages.yml/badge.svg)](https://github.com/xsitraxs/dota-2/actions/workflows/pages.yml)
[![CI](https://github.com/xsitraxs/Hoi4_translator/actions/workflows/build.yml/badge.svg)](https://github.com/xsitraxs/Hoi4_translator/actions/workflows/build.yml)
[![CI](https://github.com/xsitraxs/walking-house/actions/workflows/godot-tests.yml/badge.svg)](https://github.com/xsitraxs/walking-house/actions/workflows/godot-tests.yml)
[![CI](https://github.com/xsitraxs/Moonwave/actions/workflows/ci.yml/badge.svg)](https://github.com/xsitraxs/Moonwave/actions/workflows/ci.yml)
```

---

## Резюме

| Приоритет | Задача | Трудоёмкость |
| --- | --- | --- |
| P0 | `npm audit fix` в `dota-2`, разблокировать 3 PR | 5 минут |
| P1 | Разобрать PR #13 или закрыть его | 15 минут |
| P1 | `dependabot.yml` с группировкой | 5 минут |
| P2 | CI для `home-manager` и `dota2analyser` | 30 минут |
| P2 | Бейджи CI в README проектов | 10 минут |
| P3 | Решить судьбу `hoi4translator-web` | — |
