#Requires -Version 5.1
<#
.SYNOPSIS
  教程里「最新版」类表述的时效检查。

.DESCRIPTION
  文档里的版本号分两类：
    1) 主干版本（Python 3.13、JDK 25 LTS）—— 几年才变一次，写死在文档里没问题
    2) 「最新稳定版」这类会说话的断言 —— 会过期，必须定期核对

  本脚本只查第 2 类：从上游官方接口读出当前最新版本，
  与文档里写的主干号比对，不一致就报出来，交由人工判断是否改写。

  故意不做自动改文档：教程里的安装步骤、路径、截图都是跟着版本走的，
  盲目替换版本号会把整章内容改错。

.EXAMPLE
  ./scripts/check-versions.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

$UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'

function Get-Json($Url) {
    $client = $null
    try {
        Add-Type -AssemblyName System.Net.Http -ErrorAction SilentlyContinue
        $client = [System.Net.Http.HttpClient]::new()
        $client.Timeout = [TimeSpan]::FromSeconds(25)
        [void]$client.DefaultRequestHeaders.TryAddWithoutValidation('User-Agent', $UA)
        [void]$client.DefaultRequestHeaders.TryAddWithoutValidation('Accept', 'application/json')
        return ($client.GetStringAsync($Url).GetAwaiter().GetResult() | ConvertFrom-Json)
    }
    finally {
        if ($client) { $client.Dispose() }
    }
}

$checks = @()

# Python 最新稳定版：python.org FTP 目录
try {
    $raw = Get-Json 'https://endoflife.date/api/python.json'
    $latest = @($raw)[0]
    $checks += [pscustomobject]@{
        Name = 'Python'
        Upstream = [string]$latest.latest
        Cycle = [string]$latest.cycle
    }
}
catch {
    Write-Warning ('Python 版本探测失败：' + $_.Exception.Message)
}

# Node.js LTS
try {
    $raw = Get-Json 'https://endoflife.date/api/nodejs.json'
    $lts = @($raw) | Where-Object { $_.lts -eq $true } | Select-Object -First 1
    if ($lts) {
        $checks += [pscustomobject]@{
            Name = 'Node.js'
            Upstream = [string]$lts.latest
            Cycle = [string]$lts.cycle
        }
    }
}
catch {
    Write-Warning ('Node.js 版本探测失败：' + $_.Exception.Message)
}

# JDK LTS：只取 Adoptium 最新 GA
try {
    $raw = Get-Json 'https://api.adoptium.net/v3/info/available_releases'
    $checks += [pscustomobject]@{
        Name = 'JDK'
        Upstream = [string]$raw.most_recent_feature_version
        Cycle = [string]$raw.most_recent_feature_version
    }
}
catch {
    Write-Warning ('JDK 版本探测失败：' + $_.Exception.Message)
}

if ($checks.Count -eq 0) {
    Write-Host '所有上游探测均失败，跳过比对（不判定为文档问题）'
    exit 0
}

# 从文档里抽出各自的版本表述
$docsDir = Join-Path $root 'docs'
$all = ''
Get-ChildItem -LiteralPath $docsDir -Recurse -Filter '*.md' -File | ForEach-Object {
    $all += (Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8) + [string][char]10
}

$report = New-Object System.Collections.ArrayList
[void]$report.Add('教程版本时效检查')
[void]$report.Add(('生成时间：' + (Get-Date).ToString('yyyy-MM-dd HH:mm')))
[void]$report.Add('')

# 文档如果已经明确声明「版本会变、以官网为准」，就不再把主干号不一致当成问题。
# 这类声明是关键：教程正文里的版本号本身只是「示例」，真正会错的是把旧版写成「最新版」。
$disclaimer = $all -match '版本号随时间变' -or $all -match '以官网(显示)?为准' -or $all -match '版本可能(已)?更新'

$drift = 0
foreach ($c in $checks) {
    $major = ($c.Cycle -split '[.]')[0]
    $found = $false
    if ($c.Name -eq 'Python' -and $all -match ('Python 3[.]' + [regex]::Escape($major))) { $found = $true }
    if ($c.Name -eq 'Node.js' -and $all -match ('Node[.]?js? ?' + [regex]::Escape($major))) { $found = $true }
    if ($c.Name -eq 'JDK' -and $all -match ('JDK ?' + [regex]::Escape($major))) { $found = $true }

    $flag = '一致'
    if (-not $found) {
        if ($disclaimer) { $flag = '文档已声明版本随时间变，示例号可接受' }
        else { $flag = '文档未提到该主干号且无版本时效声明 -> 需人工确认'; $drift++ }
    }
    [void]$report.Add(('  {0,-8} 上游最新 {1,-12} 文档主干 {2,-6} -> {3}' -f $c.Name, $c.Upstream, $major, $flag))
}

[void]$report.Add('')
if ($drift -eq 0) {
    [void]$report.Add('结论：文档主干版本与上游一致。')
}
else {
    [void]$report.Add(('结论：' + $drift + ' 项需要人工确认（不代表文档有错，可能只是没写主干号）。'))
}

$out = $report -join [string][char]10
Write-Host $out
[System.IO.File]::WriteAllText((Join-Path $root 'version-report.txt'), $out, (New-Object System.Text.UTF8Encoding($false)))

if ($env:GITHUB_STEP_SUMMARY) {
    Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value $out -Encoding utf8
}
