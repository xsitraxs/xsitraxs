# Требуется PowerShell 5.1+ или PowerShell 7+
# Применяет описания и топики ко всем репозиториям профиля xsitraxs.
#
# Запуск (сначала проверка без изменений):
#   .\apply-metadata.ps1 -DryRun
# Затем применение:
#   .\apply-metadata.ps1
#
# Если PowerShell блокирует запуск скрипта:
#   powershell -ExecutionPolicy Bypass -File .\apply-metadata.ps1 -DryRun
#
# Скрипт идемпотентен: повторный запуск ничего не сломает.

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# --- Проверка gh ---------------------------------------------------------
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host 'Ошибка: не найден gh (GitHub CLI).' -ForegroundColor Red
    Write-Host 'Установи: winget install GitHub.cli'
    Write-Host 'Потом авторизуйся: gh auth login'
    exit 1
}

gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Ошибка: gh не авторизован. Выполни: gh auth login' -ForegroundColor Red
    exit 1
}

$user = 'xsitraxs'

# --- Данные --------------------------------------------------------------
# repo | описание | топики через запятую
$repos = @(
    @{ Name = 'Moonwave';
       Desc = 'Плеер SoundCloud для Windows, macOS и Linux: без рекламы, с текстами песен, эквалайзером и своим оформлением.';
       Topics = 'soundcloud,music-player,electron,typescript,desktop-app,lyrics,windows,macos,linux' },

    @{ Name = 'dota2analyser';
       Desc = 'Браузерный разбор матчей Dota 2: оценка по шести осям, авто-коуч и персональный план тренировки. Без регистрации и бэкенда.';
       Topics = 'dota2,dota-2,esports,match-analysis,coaching,react,typescript,browser-app,opendota,steam-api' },

    @{ Name = 'dota-2';
       Desc = 'Драфт-помощник Dota 2 патча 7.41: чем отвечать на их драфт, как играть лейн и что покупать. Работает офлайн в браузере.';
       Topics = 'dota2,draft,counter-picks,static-site,javascript,github-pages,offline' },

    @{ Name = 'Smart_File_Organizer';
       Desc = 'Сортировка файлов по категориям: dry-run, наблюдение за папкой, поиск дубликатов по SHA-256 и полный откат любого перемещения.';
       Topics = 'python,file-organizer,automation,cli,productivity,duplicate-files,file-management' },

    @{ Name = 'counter-items';
       Desc = 'Контр-предметы для Dota 2 в Lua-окружении Umbrella: учитывает способности и предметы врагов, роль и уже имеющуюся защиту.';
       Topics = 'dota2,lua,umbrella,items,counter-picks' },

    @{ Name = 'farm-life';
       Desc = 'Прототип фермерского мода для Minecraft на Fabric: продажа урожая, магазин семян, опыт фермера и квесты.';
       Topics = 'minecraft,fabric,minecraft-mod,java,farming' },

    @{ Name = 'timernew';
       Desc = 'Таймер для Windows 10/11 на C# + WinUI 3: Mica-фон, тёмная тема, установщик MSIX.';
       Topics = 'windows,winui3,csharp,dotnet,timer,desktop-app,msix' },

    @{ Name = 'lean-late-game';
       Desc = 'Эксперимент: снижение нагрузки на CPU в поздней игре Hearts of Iron IV (1943+) через ИИ, defines и on_actions.';
       Topics = 'hoi4,hearts-of-iron-iv,performance,optimization,modding' },

    @{ Name = 'invoker-sunstrike-game';
       Desc = 'Ранний каркас исследования производительности Hearts of Iron IV в поздней игре.';
       Topics = 'hoi4,performance,research,modding' },

    @{ Name = 'walking-house';
       Desc = '«Шагающий дом» — атмосферное 2D-выживание на Godot 4: механический дом идёт через полярную пустошь к геотермальной станции.';
       Topics = 'godot,godot4,gdscript,game,survival-game,2d,indie-game' },

    @{ Name = 'hoi4translator-web';
       Desc = 'Веб-прототип переводчика локализации HoI4 на React: DeepL → Google → MyMemory с фолбэком, глоссарий, предпросмотр.';
       Topics = 'hoi4,localization,translation,react,typescript,web-app' },

    @{ Name = 'home-manager';
       Desc = 'Домашние дела, семейный рейтинг и трекер воды в одном приложении для Windows, macOS и Linux. Данные локально в SQLite.';
       Topics = 'electron,react,typescript,sqlite,chores,water-tracker,desktop-app,productivity' },

    @{ Name = 'tunatuvuhoi4mod';
       Desc = 'Мод Hearts of Iron IV: превращает Танну-Туву из одной провинции в державу — 46 фокусов, два политических пути, 36 событий.';
       Topics = 'hoi4,hearts-of-iron-iv,hoi4-mod,modding,paradox-interactive,tuva,focus-tree' }
)

$failed = @()

function Invoke-Gh {
    param([string[]]$GhArgs)

    $shown = "gh $($GhArgs -join ' ')"
    if ($DryRun) {
        Write-Host "  [dry-run] $shown" -ForegroundColor DarkGray
        return $true
    }

    Write-Host "  $shown" -ForegroundColor DarkGray
    $output = & gh @GhArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ОШИБКА: $output" -ForegroundColor Red
        return $false
    }
    return $true
}

# --- Описания и топики ---------------------------------------------------
Write-Host ''
Write-Host '== Описания и топики ==' -ForegroundColor Cyan

foreach ($r in $repos) {
    Write-Host $r.Name -ForegroundColor White
    $target = "$user/$($r.Name)"

    if (-not (Invoke-Gh -Args @('repo', 'edit', $target, '--description', $r.Desc))) {
        $failed += "$($r.Name) (описание)"
    }

    $topicArgs = @('repo', 'edit', $target)
    foreach ($t in ($r.Topics -split ',')) {
        $topicArgs += '--add-topic'
        $topicArgs += $t.Trim()
    }
    if (-not (Invoke-Gh -Args $topicArgs)) {
        $failed += "$($r.Name) (топики)"
    }
}

# --- Исправление неверных топиков Hoi4_translator ------------------------
Write-Host ''
Write-Host '== Hoi4_translator: убрать python и customtkinter, добавить rust и cli ==' -ForegroundColor Cyan

foreach ($t in @('python', 'customtkinter')) {
    if (-not (Invoke-Gh -Args @('repo', 'edit', "$user/Hoi4_translator", '--remove-topic', $t))) {
        $failed += "Hoi4_translator (убрать $t)"
    }
}
foreach ($t in @('rust', 'cli')) {
    if (-not (Invoke-Gh -Args @('repo', 'edit', "$user/Hoi4_translator", '--add-topic', $t))) {
        $failed += "Hoi4_translator (добавить $t)"
    }
}

# --- Итог ----------------------------------------------------------------
Write-Host ''
if ($failed.Count -eq 0) {
    Write-Host '== Готово ==' -ForegroundColor Green
} else {
    Write-Host '== Завершено с ошибками ==' -ForegroundColor Yellow
    foreach ($f in $failed) { Write-Host "  - $f" -ForegroundColor Yellow }
    Write-Host '  Запусти скрипт ещё раз: он идемпотентен и доделает пропущенное.'
}

Write-Host ''
Write-Host 'Проверить результат:' -ForegroundColor Cyan
Write-Host '  gh repo view xsitraxs/Moonwave --json description,repositoryTopics'
Write-Host '  или открой https://github.com/xsitraxs?tab=repositories'
