# apply-metadata.ps1 -- pure ASCII source, no Cyrillic, no downloads.
#
# Fetches the Russian descriptions straight from GitHub via `gh api`
# (gh returns the file content base64-encoded, so encoding is never an issue),
# then applies descriptions and topics to every repository.
#
# Preview (changes nothing):
#   .\apply-metadata.ps1 -DryRun
# Apply:
#   .\apply-metadata.ps1
#
# If PowerShell refuses to run the script:
#   powershell -ExecutionPolicy Bypass -File .\apply-metadata.ps1 -DryRun

param([switch]$DryRun)

$ErrorActionPreference = 'Continue'
$User  = 'xsitraxs'
$Repo  = 'xsitraxs/xsitraxs'
$Ref   = 'arena/77654604-xsitraxs'
$Path  = 'scripts/metadata.json'

Write-Host 'apply-metadata.ps1' -ForegroundColor Cyan
Write-Host ''

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host 'ERROR: gh (GitHub CLI) not found.' -ForegroundColor Red
    Write-Host 'Install:  winget install GitHub.cli'
    Write-Host 'Then:     gh auth login'
    exit 1
}

gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'ERROR: gh is not authenticated. Run: gh auth login' -ForegroundColor Red
    exit 1
}

# ---- Fetch data (base64 from GitHub API -> JSON in memory) --------------
Write-Host ('Fetching ' + $Path + ' from ' + $Ref + ' ...')
$b64 = gh api ("repos/" + $Repo + "/contents/" + $Path + "?ref=" + $Ref) --jq '.content' 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host ('ERROR: could not fetch data: ' + $b64) -ForegroundColor Red
    exit 1
}

try {
    $json = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))
    $meta = $json | ConvertFrom-Json
} catch {
    Write-Host ('ERROR: could not decode data: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}

if (-not $meta.repos -or $meta.repos.Count -eq 0) {
    Write-Host 'ERROR: no repositories in data file.' -ForegroundColor Red
    exit 1
}

Write-Host ('Loaded ' + $meta.repos.Count + ' repositories.') -ForegroundColor Green
if ($DryRun) { Write-Host 'DRY RUN -- nothing will be changed.' -ForegroundColor Yellow }
Write-Host ''

function Invoke-Gh {
    param([string[]]$GhArgs)
    $shown = 'gh ' + ($GhArgs -join ' ')
    if ($DryRun) {
        Write-Host ('  [dry-run] ' + $shown) -ForegroundColor DarkGray
        return $true
    }
    $out  = & gh @GhArgs 2>&1 | Out-String
    $code = $LASTEXITCODE
    if ($code -ne 0) {
        Write-Host ('  FAILED (' + $code + '): ' + $out.Trim()) -ForegroundColor Red
        return $false
    }
    Write-Host '  ok' -ForegroundColor Green
    return $true
}

$failed = @()

Write-Host '== Descriptions and topics ==' -ForegroundColor Cyan
foreach ($r in $meta.repos) {
    Write-Host $r.repo -ForegroundColor White
    $target = $User + '/' + $r.repo

    if (-not (Invoke-Gh @('repo', 'edit', $target, '--description', $r.description))) {
        $failed += ($r.repo + ' (description)')
    }

    $topicArgs = @('repo', 'edit', $target)
    foreach ($t in $r.topics) {
        $topicArgs += '--add-topic'
        $topicArgs += $t
    }
    if (-not (Invoke-Gh $topicArgs)) {
        $failed += ($r.repo + ' (topics)')
    }
}

$fix = $meta.topic_fix
if ($fix) {
    Write-Host ''
    Write-Host ('== ' + $fix.repo + ': remove python/customtkinter, add rust/cli ==') -ForegroundColor Cyan
    $tgt = $User + '/' + $fix.repo
    foreach ($t in $fix.remove) {
        if (-not (Invoke-Gh @('repo', 'edit', $tgt, '--remove-topic', $t))) {
            $failed += ($fix.repo + ' (remove ' + $t + ')')
        }
    }
    foreach ($t in $fix.add) {
        if (-not (Invoke-Gh @('repo', 'edit', $tgt, '--add-topic', $t))) {
            $failed += ($fix.repo + ' (add ' + $t + ')')
        }
    }
}

Write-Host ''
if ($failed.Count -eq 0) {
    if ($DryRun) {
        Write-Host '== Dry run finished, no errors. Run without -DryRun to apply. ==' -ForegroundColor Green
    } else {
        Write-Host '== Done ==' -ForegroundColor Green
    }
} else {
    Write-Host '== Finished with errors ==' -ForegroundColor Yellow
    foreach ($f in $failed) { Write-Host ('  - ' + $f) -ForegroundColor Yellow }
    Write-Host '  Re-run the script: it is idempotent and will finish what is left.'
}

Write-Host ''
Write-Host 'Verify:' -ForegroundColor Cyan
Write-Host '  gh repo view xsitraxs/Moonwave --json description,repositoryTopics'
Write-Host '  or open https://github.com/xsitraxs?tab=repositories'
