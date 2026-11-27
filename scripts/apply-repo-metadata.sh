#!/usr/bin/env bash
# Применяет описания и топики ко всем репозиториям профиля xsitraxs.
#
# Запуск (нужен gh, авторизованный как владелец аккаунта — токен с правом repo):
#   ./scripts/apply-repo-metadata.sh
#
# Флаг --dry-run показывает, что будет сделано, ничего не меняя:
#   ./scripts/apply-repo-metadata.sh --dry-run
#
# Скрипт идемпотентен: повторный запуск ничего не сломает.

set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Ошибка: не найден gh (GitHub CLI). Установи: https://cli.github.com" >&2
  exit 1
fi

run() {
  if $DRY_RUN; then
    echo "  [dry-run] $*"
  else
    echo "  $*"
    "$@" >/dev/null
  fi
}

# repo|описание|топики через запятую
REPOS=$(cat <<'DATA'
Moonwave|Плеер SoundCloud для Windows, macOS и Linux: без рекламы, с текстами песен, эквалайзером и своим оформлением.|soundcloud,music-player,electron,typescript,desktop-app,lyrics,windows,macos,linux
dota2analyser|Браузерный разбор матчей Dota 2: оценка по шести осям, авто-коуч и персональный план тренировки. Без регистрации и бэкенда.|dota2,dota-2,esports,match-analysis,coaching,react,typescript,browser-app,opendota,steam-api
dota-2|Драфт-помощник Dota 2 патча 7.41: чем отвечать на их драфт, как играть лейн и что покупать. Работает офлайн в браузере.|dota2,draft,counter-picks,static-site,javascript,github-pages,offline
Smart_File_Organizer|Сортировка файлов по категориям: dry-run, наблюдение за папкой, поиск дубликатов по SHA-256 и полный откат любого перемещения.|python,file-organizer,automation,cli,productivity,duplicate-files,file-management
counter-items|Контр-предметы для Dota 2 в Lua-окружении Umbrella: учитывает способности и предметы врагов, роль и уже имеющуюся защиту.|dota2,lua,umbrella,items,counter-picks
farm-life|Прототип фермерского мода для Minecraft на Fabric: продажа урожая, магазин семян, опыт фермера и квесты.|minecraft,fabric,minecraft-mod,java,farming
timernew|Таймер для Windows 10/11 на C# + WinUI 3: Mica-фон, тёмная тема, установщик MSIX.|windows,winui3,csharp,dotnet,timer,desktop-app,msix
lean-late-game|Эксперимент: снижение нагрузки на CPU в поздней игре Hearts of Iron IV (1943+) через ИИ, defines и on_actions.|hoi4,hearts-of-iron-iv,performance,optimization,modding
invoker-sunstrike-game|Ранний каркас исследования производительности Hearts of Iron IV в поздней игре.|hoi4,performance,research,modding
walking-house|«Шагающий дом» — атмосферное 2D-выживание на Godot 4: механический дом идёт через полярную пустошь к геотермальной станции.|godot,godot4,gdscript,game,survival-game,2d,indie-game
hoi4translator-web|Веб-прототип переводчика локализации HoI4 на React: DeepL → Google → MyMemory с фолбэком, глоссарий, предпросмотр.|hoi4,localization,translation,react,typescript,web-app
home-manager|Домашние дела, семейный рейтинг и трекер воды в одном приложении для Windows, macOS и Linux. Данные локально в SQLite.|electron,react,typescript,sqlite,chores,water-tracker,desktop-app,productivity
tunatuvuhoi4mod|Мод Hearts of Iron IV: превращает Танну-Туву из одной провинции в державу — 46 фокусов, два политических пути, 36 событий.|hoi4,hearts-of-iron-iv,hoi4-mod,modding,paradox-interactive,tuva,focus-tree
DATA
)

echo "== Описания и топики =="
while IFS='|' read -r repo desc topics; do
  [[ -z "$repo" ]] && continue
  echo "$repo"
  run gh repo edit "xsitraxs/$repo" --description "$desc"
  # --add-topic идемпотентен: повторный вызов с тем же топиком не падает
  args=()
  IFS=',' read -ra TOPIC_LIST <<< "$topics"
  for t in "${TOPIC_LIST[@]}"; do
    args+=(--add-topic "$t")
  done
  run gh repo edit "xsitraxs/$repo" "${args[@]}"
done <<< "$REPOS"

echo
echo "== Исправление неверных топиков Hoi4_translator =="
# Проект переписан с Python на Rust: старые топики вводят в заблуждение при поиске.
for t in python customtkinter; do
  run gh repo edit xsitraxs/Hoi4_translator --remove-topic "$t"
done
for t in rust cli; do
  run gh repo edit xsitraxs/Hoi4_translator --add-topic "$t"
done

echo
echo "== Готово =="
echo "Осталось вручную (API этого не умеет):"
echo "  1. Профиль → Customize your pins → закрепить 6 репозиториев:"
echo "     Moonwave, Hoi4_translator, home-manager, dota2analyser, walking-house, Smart_File_Organizer"
echo "  2. Settings → Profile → Bio:"
echo "     Инструменты для модов HoI4 и Dota 2, настольные приложения. Rust · TypeScript · Python · GDScript"
