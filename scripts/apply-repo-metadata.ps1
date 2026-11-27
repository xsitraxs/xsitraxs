# apply-metadata.ps1 -- ASCII ONLY, do not add non-ASCII characters here.
# Russian text lives in scripts/metadata.json (UTF-8) and is decoded by this script.
#
# Run a preview first:
#   .\apply-metadata.ps1 -DryRun
# Then apply:
#   .\apply-metadata.ps1
#
# This file is pure ASCII on purpose: Windows PowerShell 5.1 reads .ps1 files
# without a BOM as Windows-1251, which breaks any Cyrillic text in the source.
#
# Data file: https://github.com/xsitraxs/xsitraxs/blob/arena/77654604-xsitraxs/scripts/metadata.json
# Download with:
#   curl.exe -fsSL https://raw.githubusercontent.com/xsitraxs/xsitraxs/arena/77654604-xsitraxs/scripts/metadata.json -o metadata.json

param([switch]$DryRun)

# Native commands (gh) write to stderr even on success. Under 'Stop' that can become
# a terminating error in Windows PowerShell 5.1, so errors are handled via $LASTEXITCODE.
$ErrorActionPreference = 'Continue'
$User = 'xsitraxs'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host 'ERROR: gh (GitHub CLI) not found. Install: winget install GitHub.cli' -ForegroundColor Red
    exit 1
}
$prevEap = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
gh auth status *> $null
$authCode = $LASTEXITCODE
$ErrorActionPreference = $prevEap
if ($authCode -ne 0) {
    Write-Host 'ERROR: gh is not authenticated. Run: gh auth login' -ForegroundColor Red
    exit 1
}

# ---- Embedded copy of metadata.json, base64 of UTF-8 JSON ----
$B64 = @(
  'ewogICJyZXBvcyI6IFsKICAgIHsKICAgICAgInJlcG8iOiAiTW9vbndhdmUiLAogICAgICAiZGVzY3JpcHRpb24iOiAi0J/Qu9C1' +
  '0LXRgCBTb3VuZENsb3VkINC00LvRjyBXaW5kb3dzLCBtYWNPUyDQuCBMaW51eDog0LHQtdC3INGA0LXQutC70LDQvNGLLCDRgSDR' +
  'gtC10LrRgdGC0LDQvNC4INC/0LXRgdC10L0sINGN0LrQstCw0LvQsNC50LfQtdGA0L7QvCDQuCDRgdCy0L7QuNC8INC+0YTQvtGA' +
  '0LzQu9C10L3QuNC10LwuIiwKICAgICAgInRvcGljcyI6IFsKICAgICAgICAic291bmRjbG91ZCIsCiAgICAgICAgIm11c2ljLXBs' +
  'YXllciIsCiAgICAgICAgImVsZWN0cm9uIiwKICAgICAgICAidHlwZXNjcmlwdCIsCiAgICAgICAgImRlc2t0b3AtYXBwIiwKICAg' +
  'ICAgICAibHlyaWNzIiwKICAgICAgICAid2luZG93cyIsCiAgICAgICAgIm1hY29zIiwKICAgICAgICAibGludXgiCiAgICAgIF0K' +
  'ICAgIH0sCiAgICB7CiAgICAgICJyZXBvIjogImRvdGEyYW5hbHlzZXIiLAogICAgICAiZGVzY3JpcHRpb24iOiAi0JHRgNCw0YPQ' +
  't9C10YDQvdGL0Lkg0YDQsNC30LHQvtGAINC80LDRgtGH0LXQuSBEb3RhIDI6INC+0YbQtdC90LrQsCDQv9C+INGI0LXRgdGC0Lgg' +
  '0L7RgdGP0LwsINCw0LLRgtC+LdC60L7Rg9GHINC4INC/0LXRgNGB0L7QvdCw0LvRjNC90YvQuSDQv9C70LDQvSDRgtGA0LXQvdC4' +
  '0YDQvtCy0LrQuC4g0JHQtdC3INGA0LXQs9C40YHRgtGA0LDRhtC40Lgg0Lgg0LHRjdC60LXQvdC00LAuIiwKICAgICAgInRvcGlj' +
  'cyI6IFsKICAgICAgICAiZG90YTIiLAogICAgICAgICJkb3RhLTIiLAogICAgICAgICJlc3BvcnRzIiwKICAgICAgICAibWF0Y2gt' +
  'YW5hbHlzaXMiLAogICAgICAgICJjb2FjaGluZyIsCiAgICAgICAgInJlYWN0IiwKICAgICAgICAidHlwZXNjcmlwdCIsCiAgICAg' +
  'ICAgImJyb3dzZXItYXBwIiwKICAgICAgICAib3BlbmRvdGEiLAogICAgICAgICJzdGVhbS1hcGkiCiAgICAgIF0KICAgIH0sCiAg' +
  'ICB7CiAgICAgICJyZXBvIjogImRvdGEtMiIsCiAgICAgICJkZXNjcmlwdGlvbiI6ICLQlNGA0LDRhNGCLdC/0L7QvNC+0YnQvdC4' +
  '0LogRG90YSAyINC/0LDRgtGH0LAgNy40MTog0YfQtdC8INC+0YLQstC10YfQsNGC0Ywg0L3QsCDQuNGFINC00YDQsNGE0YIsINC6' +
  '0LDQuiDQuNCz0YDQsNGC0Ywg0LvQtdC50L0g0Lgg0YfRgtC+INC/0L7QutGD0L/QsNGC0YwuINCg0LDQsdC+0YLQsNC10YIg0L7R' +
  'hNC70LDQudC9INCyINCx0YDQsNGD0LfQtdGA0LUuIiwKICAgICAgInRvcGljcyI6IFsKICAgICAgICAiZG90YTIiLAogICAgICAg' +
  'ICJkcmFmdCIsCiAgICAgICAgImNvdW50ZXItcGlja3MiLAogICAgICAgICJzdGF0aWMtc2l0ZSIsCiAgICAgICAgImphdmFzY3Jp' +
  'cHQiLAogICAgICAgICJnaXRodWItcGFnZXMiLAogICAgICAgICJvZmZsaW5lIgogICAgICBdCiAgICB9LAogICAgewogICAgICAi' +
  'cmVwbyI6ICJTbWFydF9GaWxlX09yZ2FuaXplciIsCiAgICAgICJkZXNjcmlwdGlvbiI6ICLQodC+0YDRgtC40YDQvtCy0LrQsCDR' +
  'hNCw0LnQu9C+0LIg0L/QviDQutCw0YLQtdCz0L7RgNC40Y/QvDogZHJ5LXJ1biwg0L3QsNCx0LvRjtC00LXQvdC40LUg0LfQsCDQ' +
  'v9Cw0L/QutC+0LksINC/0L7QuNGB0Log0LTRg9Cx0LvQuNC60LDRgtC+0LIg0L/QviBTSEEtMjU2INC4INC/0L7Qu9C90YvQuSDQ' +
  'vtGC0LrQsNGCINC70Y7QsdC+0LPQviDQv9C10YDQtdC80LXRidC10L3QuNGPLiIsCiAgICAgICJ0b3BpY3MiOiBbCiAgICAgICAg' +
  'InB5dGhvbiIsCiAgICAgICAgImZpbGUtb3JnYW5pemVyIiwKICAgICAgICAiYXV0b21hdGlvbiIsCiAgICAgICAgImNsaSIsCiAg' +
  'ICAgICAgInByb2R1Y3Rpdml0eSIsCiAgICAgICAgImR1cGxpY2F0ZS1maWxlcyIsCiAgICAgICAgImZpbGUtbWFuYWdlbWVudCIK' +
  'ICAgICAgXQogICAgfSwKICAgIHsKICAgICAgInJlcG8iOiAiY291bnRlci1pdGVtcyIsCiAgICAgICJkZXNjcmlwdGlvbiI6ICLQ' +
  'mtC+0L3RgtGALdC/0YDQtdC00LzQtdGC0Ysg0LTQu9GPIERvdGEgMiDQsiBMdWEt0L7QutGA0YPQttC10L3QuNC4IFVtYnJlbGxh' +
  'OiDRg9GH0LjRgtGL0LLQsNC10YIg0YHQv9C+0YHQvtCx0L3QvtGB0YLQuCDQuCDQv9GA0LXQtNC80LXRgtGLINCy0YDQsNCz0L7Q' +
  'siwg0YDQvtC70Ywg0Lgg0YPQttC1INC40LzQtdGO0YnRg9GO0YHRjyDQt9Cw0YnQuNGC0YMuIiwKICAgICAgInRvcGljcyI6IFsK' +
  'ICAgICAgICAiZG90YTIiLAogICAgICAgICJsdWEiLAogICAgICAgICJ1bWJyZWxsYSIsCiAgICAgICAgIml0ZW1zIiwKICAgICAg' +
  'ICAiY291bnRlci1waWNrcyIKICAgICAgXQogICAgfSwKICAgIHsKICAgICAgInJlcG8iOiAiZmFybS1saWZlIiwKICAgICAgImRl' +
  'c2NyaXB0aW9uIjogItCf0YDQvtGC0L7RgtC40L8g0YTQtdGA0LzQtdGA0YHQutC+0LPQviDQvNC+0LTQsCDQtNC70Y8gTWluZWNy' +
  'YWZ0INC90LAgRmFicmljOiDQv9GA0L7QtNCw0LbQsCDRg9GA0L7QttCw0Y8sINC80LDQs9Cw0LfQuNC9INGB0LXQvNGP0L0sINC+' +
  '0L/Ri9GCINGE0LXRgNC80LXRgNCwINC4INC60LLQtdGB0YLRiy4iLAogICAgICAidG9waWNzIjogWwogICAgICAgICJtaW5lY3Jh' +
  'ZnQiLAogICAgICAgICJmYWJyaWMiLAogICAgICAgICJtaW5lY3JhZnQtbW9kIiwKICAgICAgICAiamF2YSIsCiAgICAgICAgImZh' +
  'cm1pbmciCiAgICAgIF0KICAgIH0sCiAgICB7CiAgICAgICJyZXBvIjogInRpbWVybmV3IiwKICAgICAgImRlc2NyaXB0aW9uIjog' +
  'ItCi0LDQudC80LXRgCDQtNC70Y8gV2luZG93cyAxMC8xMSDQvdCwIEMjICsgV2luVUkgMzogTWljYS3RhNC+0L0sINGC0ZHQvNC9' +
  '0LDRjyDRgtC10LzQsCwg0YPRgdGC0LDQvdC+0LLRidC40LogTVNJWC4iLAogICAgICAidG9waWNzIjogWwogICAgICAgICJ3aW5k' +
  'b3dzIiwKICAgICAgICAid2ludWkzIiwKICAgICAgICAiY3NoYXJwIiwKICAgICAgICAiZG90bmV0IiwKICAgICAgICAidGltZXIi' +
  'LAogICAgICAgICJkZXNrdG9wLWFwcCIsCiAgICAgICAgIm1zaXgiCiAgICAgIF0KICAgIH0sCiAgICB7CiAgICAgICJyZXBvIjog' +
  'ImxlYW4tbGF0ZS1nYW1lIiwKICAgICAgImRlc2NyaXB0aW9uIjogItCt0LrRgdC/0LXRgNC40LzQtdC90YI6INGB0L3QuNC20LXQ' +
  'vdC40LUg0L3QsNCz0YDRg9C30LrQuCDQvdCwIENQVSDQsiDQv9C+0LfQtNC90LXQuSDQuNCz0YDQtSBIZWFydHMgb2YgSXJvbiBJ' +
  'ViAoMTk0MyspINGH0LXRgNC10Lcg0JjQmCwgZGVmaW5lcyDQuCBvbl9hY3Rpb25zLiIsCiAgICAgICJ0b3BpY3MiOiBbCiAgICAg' +
  'ICAgImhvaTQiLAogICAgICAgICJoZWFydHMtb2YtaXJvbi1pdiIsCiAgICAgICAgInBlcmZvcm1hbmNlIiwKICAgICAgICAib3B0' +
  'aW1pemF0aW9uIiwKICAgICAgICAibW9kZGluZyIKICAgICAgXQogICAgfSwKICAgIHsKICAgICAgInJlcG8iOiAiaW52b2tlci1z' +
  'dW5zdHJpa2UtZ2FtZSIsCiAgICAgICJkZXNjcmlwdGlvbiI6ICLQoNCw0L3QvdC40Lkg0LrQsNGA0LrQsNGBINC40YHRgdC70LXQ' +
  'tNC+0LLQsNC90LjRjyDQv9GA0L7QuNC30LLQvtC00LjRgtC10LvRjNC90L7RgdGC0LggSGVhcnRzIG9mIElyb24gSVYg0LIg0L/Q' +
  'vtC30LTQvdC10Lkg0LjQs9GA0LUuIiwKICAgICAgInRvcGljcyI6IFsKICAgICAgICAiaG9pNCIsCiAgICAgICAgInBlcmZvcm1h' +
  'bmNlIiwKICAgICAgICAicmVzZWFyY2giLAogICAgICAgICJtb2RkaW5nIgogICAgICBdCiAgICB9LAogICAgewogICAgICAicmVw' +
  'byI6ICJ3YWxraW5nLWhvdXNlIiwKICAgICAgImRlc2NyaXB0aW9uIjogIsKr0KjQsNCz0LDRjtGJ0LjQuSDQtNC+0LzCuyDigJQg' +
  '0LDRgtC80L7RgdGE0LXRgNC90L7QtSAyRC3QstGL0LbQuNCy0LDQvdC40LUg0L3QsCBHb2RvdCA0OiDQvNC10YXQsNC90LjRh9C1' +
  '0YHQutC40Lkg0LTQvtC8INC40LTRkdGCINGH0LXRgNC10Lcg0L/QvtC70Y/RgNC90YPRjiDQv9GD0YHRgtC+0YjRjCDQuiDQs9C1' +
  '0L7RgtC10YDQvNCw0LvRjNC90L7QuSDRgdGC0LDQvdGG0LjQuC4iLAogICAgICAidG9waWNzIjogWwogICAgICAgICJnb2RvdCIs' +
  'CiAgICAgICAgImdvZG90NCIsCiAgICAgICAgImdkc2NyaXB0IiwKICAgICAgICAiZ2FtZSIsCiAgICAgICAgInN1cnZpdmFsLWdh' +
  'bWUiLAogICAgICAgICIyZCIsCiAgICAgICAgImluZGllLWdhbWUiCiAgICAgIF0KICAgIH0sCiAgICB7CiAgICAgICJyZXBvIjog' +
  'ImhvaTR0cmFuc2xhdG9yLXdlYiIsCiAgICAgICJkZXNjcmlwdGlvbiI6ICLQktC10LEt0L/RgNC+0YLQvtGC0LjQvyDQv9C10YDQ' +
  'tdCy0L7QtNGH0LjQutCwINC70L7QutCw0LvQuNC30LDRhtC40LggSG9JNCDQvdCwIFJlYWN0OiBEZWVwTCDihpIgR29vZ2xlIOKG' +
  'kiBNeU1lbW9yeSDRgSDRhNC+0LvQsdGN0LrQvtC8LCDQs9C70L7RgdGB0LDRgNC40LksINC/0YDQtdC00L/RgNC+0YHQvNC+0YLR' +
  'gC4iLAogICAgICAidG9waWNzIjogWwogICAgICAgICJob2k0IiwKICAgICAgICAibG9jYWxpemF0aW9uIiwKICAgICAgICAidHJh' +
  'bnNsYXRpb24iLAogICAgICAgICJyZWFjdCIsCiAgICAgICAgInR5cGVzY3JpcHQiLAogICAgICAgICJ3ZWItYXBwIgogICAgICBd' +
  'CiAgICB9LAogICAgewogICAgICAicmVwbyI6ICJob21lLW1hbmFnZXIiLAogICAgICAiZGVzY3JpcHRpb24iOiAi0JTQvtC80LDR' +
  'iNC90LjQtSDQtNC10LvQsCwg0YHQtdC80LXQudC90YvQuSDRgNC10LnRgtC40L3QsyDQuCDRgtGA0LXQutC10YAg0LLQvtC00Ysg' +
  '0LIg0L7QtNC90L7QvCDQv9GA0LjQu9C+0LbQtdC90LjQuCDQtNC70Y8gV2luZG93cywgbWFjT1Mg0LggTGludXguINCU0LDQvdC9' +
  '0YvQtSDQu9C+0LrQsNC70YzQvdC+INCyIFNRTGl0ZS4iLAogICAgICAidG9waWNzIjogWwogICAgICAgICJlbGVjdHJvbiIsCiAg' +
  'ICAgICAgInJlYWN0IiwKICAgICAgICAidHlwZXNjcmlwdCIsCiAgICAgICAgInNxbGl0ZSIsCiAgICAgICAgImNob3JlcyIsCiAg' +
  'ICAgICAgIndhdGVyLXRyYWNrZXIiLAogICAgICAgICJkZXNrdG9wLWFwcCIsCiAgICAgICAgInByb2R1Y3Rpdml0eSIKICAgICAg' +
  'XQogICAgfSwKICAgIHsKICAgICAgInJlcG8iOiAidHVuYXR1dnVob2k0bW9kIiwKICAgICAgImRlc2NyaXB0aW9uIjogItCc0L7Q' +
  'tCBIZWFydHMgb2YgSXJvbiBJVjog0L/RgNC10LLRgNCw0YnQsNC10YIg0KLQsNC90L3Rgy3QotGD0LLRgyDQuNC3INC+0LTQvdC+' +
  '0Lkg0L/RgNC+0LLQuNC90YbQuNC4INCyINC00LXRgNC20LDQstGDIOKAlCA0NiDRhNC+0LrRg9GB0L7Qsiwg0LTQstCwINC/0L7Q' +
  'u9C40YLQuNGH0LXRgdC60LjRhSDQv9GD0YLQuCwgMzYg0YHQvtCx0YvRgtC40LkuIiwKICAgICAgInRvcGljcyI6IFsKICAgICAg' +
  'ICAiaG9pNCIsCiAgICAgICAgImhlYXJ0cy1vZi1pcm9uLWl2IiwKICAgICAgICAiaG9pNC1tb2QiLAogICAgICAgICJtb2RkaW5n' +
  'IiwKICAgICAgICAicGFyYWRveC1pbnRlcmFjdGl2ZSIsCiAgICAgICAgInR1dmEiLAogICAgICAgICJmb2N1cy10cmVlIgogICAg' +
  'ICBdCiAgICB9CiAgXSwKICAidG9waWNfZml4IjogewogICAgInJlcG8iOiAiSG9pNF90cmFuc2xhdG9yIiwKICAgICJyZW1vdmUi' +
  'OiBbCiAgICAgICJweXRob24iLAogICAgICAiY3VzdG9tdGtpbnRlciIKICAgIF0sCiAgICAiYWRkIjogWwogICAgICAicnVzdCIs' +
  'CiAgICAgICJjbGkiCiAgICBdCiAgfQp9Cg=='
) -join ''

function Get-Metadata {
    $bytes = [Convert]::FromBase64String($B64)
    $json = [Text.Encoding]::UTF8.GetString($bytes)
    return $json | ConvertFrom-Json
}

function Invoke-Gh {
    param([string[]]$GhArgs)
    $shown = 'gh ' + ($GhArgs -join ' ')
    if ($DryRun) {
        Write-Host ('  [dry-run] ' + $shown) -ForegroundColor DarkGray
        return $true
    }
    Write-Host ('  ' + $shown) -ForegroundColor DarkGray
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = & gh @GhArgs 2>&1 | Out-String
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0) {
        Write-Host ('  FAILED: ' + $out) -ForegroundColor Red
        return $false
    }
    return $true
}

$meta = Get-Metadata
$failed = @()

Write-Host ''
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
    Write-Host '== Done ==' -ForegroundColor Green
} else {
    Write-Host '== Finished with errors ==' -ForegroundColor Yellow
    foreach ($f in $failed) { Write-Host ('  - ' + $f) -ForegroundColor Yellow }
    Write-Host '  Re-run the script: it is idempotent and will finish what is left.'
}
Write-Host ''
Write-Host 'Verify:' -ForegroundColor Cyan
Write-Host '  gh repo view xsitraxs/Moonwave --json description,repositoryTopics'
Write-Host '  or open https://github.com/xsitraxs?tab=repositories'
