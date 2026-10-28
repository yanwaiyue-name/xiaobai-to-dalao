#Requires -Version 5.1
<#
.SYNOPSIS
  docs/ 下的 Markdown 教程 -> 静态站点 site/
.DESCRIPTION
  仅用 PowerShell 自带能力，无 padoc / node / 第三方依赖。
.EXAMPLE
  ./scripts/build-site.ps1
#>
[CmdletBinding()]
param([string]$DocsDir, [string]$OutDir)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not $DocsDir) { $DocsDir = Join-Path $root 'docs' }
if (-not $OutDir)  { $OutDir  = Join-Path $root 'site' }

$utf8 = New-Object System.Text.UTF8Encoding($false)
$NL = [string][char]10
$BQ = [string][char]96
$PH = [string][char]1
$Q  = [string][char]34
$SEP = [string][char]92
$PIPE = [string][char]124

function ConvertTo-HtmlText([string]$Value) {
    if ([string]::IsNullOrEmpty($Value)) { return "" }
    $v = $Value.Replace('&', '&amp;')
    $v = $v.Replace('<', '&lt;')
    $v = $v.Replace('>', '&gt;')
    $v = $v.Replace($Q, '&quot;')
    return $v
}

function Split-Path2([string]$Path) {
    return @($Path -split '/' | Where-Object { $_ -ne '' -and $_ -ne '.' })
}

function Get-Slug([string]$Value) {
    if ([string]::IsNullOrEmpty($Value)) { return "" }
    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $Value.ToLowerInvariant().ToCharArray()) {
        if ([char]::IsLetterOrDigit($ch)) { [void]$sb.Append($ch) }
        elseif ($ch -eq [char]45 -or $ch -eq [char]95) { [void]$sb.Append($ch) }
        elseif ($ch -eq [char]32) { [void]$sb.Append([char]45) }
    }
    $s = $sb.ToString()
    $dd = [string][char]45 + [string][char]45
    while ($s.Contains($dd)) { $s = $s.Replace($dd, [string][char]45) }
    return $s.Trim([char]45)
}

function Get-RelLink([string]$FromDir, [string]$ToPath) {
    $from = @(Split-Path2 $FromDir)
    $to = @(Split-Path2 $ToPath)
    $same = 0
    while ($same -lt $from.Count -and $same -lt $to.Count -and $from[$same] -eq $to[$same]) { $same++ }
    $prefix = ""
    for ($z = 0; $z -lt ($from.Count - $same); $z++) { $prefix += '../' }
    return $prefix + (@($to | Select-Object -Skip $same) -join "/")
}

function Rewrite-Href([string]$Href) {
    if ([string]::IsNullOrEmpty($Href)) { return $Href }
    if ($Href -match '^(https?:|mailto:|#|//)') { return $Href }

    $anchor = ""
    $path = $Href
    $hash = $Href.IndexOf("#")
    if ($hash -ge 0) {
        $anchor = $Href.Substring($hash)
        $path = $Href.Substring(0, $hash)
    }
    if ($path -eq "") { return $anchor }

    # 图片等静态资源保持相对路径；其余仓库文件（LICENSE 等）站点不复制，指回 GitHub
    if (-not $path.ToLower().EndsWith(".md")) {
        $lower = $path.ToLower()
        $isAsset = ($lower.EndsWith(".png") -or $lower.EndsWith(".jpg") -or $lower.EndsWith(".jpeg") -or $lower.EndsWith(".gif") -or $lower.EndsWith(".svg") -or $lower.EndsWith(".webp") -or $lower.EndsWith(".ico"))
        if ($isAsset) { return $Href }
        $clean = $path.TrimStart('.', '/')
        return "https://github.com/yanwaiyue-name/xiaobai-to-dalao/blob/main/" + $clean
    }

    $stack = New-Object System.Collections.ArrayList
    foreach ($seg in (Split-Path2 $script:CurDocDir)) { [void]$stack.Add($seg) }
    foreach ($seg in (Split-Path2 $path)) {
        if ($seg -eq "..") { if ($stack.Count -gt 0) { $stack.RemoveAt($stack.Count - 1) } }
        else { [void]$stack.Add($seg) }
    }

    $parts = New-Object System.Collections.ArrayList
    foreach ($seg in $stack) { [void]$parts.Add($seg) }
    if ($parts.Count -eq 0) { return (Get-RelLink -FromDir $script:CurSiteDir -ToPath "index.html") + $anchor }

    # 仓库根 README.md（相对文档根解析后就是单独一段 README.md）-> 站点根 index.html
    # 根级的 README.en.md / README.xx.md 渲染成 README.en.html / README.xx.html，这里必须同样映射，
    # 否则 [English](README.en.md) 会生成一个不存在的 README.en.html（历史 bug：Pages CI 因此变红）。
    $last = [string]$parts[$parts.Count - 1]
    if ($parts.Count -eq 1 -and $last -match '^README(\.[A-Za-z-]+)?\.md$') {
        $leafOut = if ($last -eq "README.md") { "index.html" } else { $last.Substring(0, $last.Length - 3) + ".html" }
        return (Get-RelLink -FromDir $script:CurSiteDir -ToPath $leafOut) + $anchor
    }

    # docs 这层在站点里被抹平（docs/a/b.md -> a/b.html）
    if ($parts.Count -ge 2 -and $parts[0] -eq "docs") { $parts.RemoveAt(0) }

    $last = [string]$parts[$parts.Count - 1]
    if ($last -eq "README.md") {
        # 目录内的 README.md 在站点里渲染成该目录的 index.html
        $parts.RemoveAt($parts.Count - 1)
        [void]$parts.Add("index.html")
    }
    else {
        $parts[$parts.Count - 1] = $last.Substring(0, $last.Length - 3) + ".html"
    }
    # docs 根的裸 README.md 已在上面的分支处理；此处兜底，避免出现 README.html

    return (Get-RelLink -FromDir $script:CurSiteDir -ToPath ($parts -join "/")) + $anchor
}


function Convert-Bold([string]$Text) {
    if ([string]::IsNullOrEmpty($Text)) { return "" }

    $star2 = [string][char]42 + [string][char]42
    $sb = New-Object System.Text.StringBuilder
    $i = 0
    $n = $Text.Length

    while ($i -lt $n) {
        if (($i + 1) -lt $n -and $Text[$i] -eq [char]42 -and $Text[$i + 1] -eq [char]42) {
            $close = $Text.IndexOf($star2, $i + 2)
            if ($close -gt $i) {
                $inner = $Text.Substring($i + 2, $close - $i - 2)
                if ($inner.Length -gt 0) {
                    [void]$sb.Append("<strong>").Append($inner).Append("</strong>")
                    $i = $close + 2
                    continue
                }
            }
        }
        [void]$sb.Append($Text[$i])
        $i++
    }
    return $sb.ToString()
}

function Convert-Inline([string]$Text) {
    if ([string]::IsNullOrEmpty($Text)) { return "" }

    $codes = New-Object System.Collections.ArrayList
    $sb = New-Object System.Text.StringBuilder
    $i = 0
    while ($i -lt $Text.Length) {
        if ([string]$Text[$i] -eq $BQ) {
            $end = $Text.IndexOf($BQ, $i + 1)
            if ($end -gt $i) {
                [void]$codes.Add($Text.Substring($i + 1, $end - $i - 1))
                [void]$sb.Append($PH).Append("c").Append($codes.Count - 1).Append($PH)
                $i = $end + 1
                continue
            }
        }
        [void]$sb.Append($Text[$i])
        $i++
    }

    $work = ConvertTo-HtmlText ($sb.ToString())

    # 链接：[文本](地址)。手工扫描，避免正则转义问题
    $work = Convert-Links $work

    # 粗体：手工扫描 **，避免 PS 5.1 与 PS 7 的 Split 行为差异
    $star2 = [string][char]42 + [string][char]42
    $work = Convert-Bold $work
    for ($k = 0; $k -lt $codes.Count; $k++) {
        $token = $PH + "c" + [string]$k + $PH
        $work = $work.Replace($token, "<code>" + (ConvertTo-HtmlText ([string]$codes[$k])) + "</code>")
    }
    return $work
}

function Convert-Links([string]$Text) {
    # 手工扫描 [文本](地址)，不用正则：Windows PS 5.1 与 PS 7 的正则转义行为一致，
    # 但把表达式写进字符串常量容易被各层转义搞坏，这里直接按字符扫，最稳。
    if ([string]::IsNullOrEmpty($Text)) { return "" }

    $sb = New-Object System.Text.StringBuilder
    $i = 0
    $n = $Text.Length

    while ($i -lt $n) {
        $ch = $Text[$i]

        if ($ch -eq [char]91) {
            # 找 ]
            $close = $Text.IndexOf([char]93, $i + 1)
            if ($close -gt $i -and ($close + 1) -lt $n -and $Text[$close + 1] -eq [char]40) {
                $end = $Text.IndexOf([char]41, $close + 2)
                if ($end -gt $close) {
                    $label = $Text.Substring($i + 1, $close - $i - 1)
                    $href = $Text.Substring($close + 2, $end - $close - 2)
                    $fixed = Rewrite-Href $href
                    [void]$sb.Append("<a href=").Append($Q).Append($fixed).Append($Q).Append(">").Append($label).Append("</a>")
                    $i = $end + 1
                    continue
                }
            }
        }

        [void]$sb.Append($ch)
        $i++
    }

    return $sb.ToString()
}

function Convert-Markdown([string[]]$Lines) {
    $out = New-Object System.Collections.ArrayList
    $para = New-Object System.Collections.ArrayList
    $i = 0
    $fence = $BQ + $BQ + $BQ
    $H = [char]35
    $DASH = [char]45
    $STAR = [char]42

    $usedIds = @{}

    $flushPara = {
        if ($para.Count -gt 0) {
            [void]$out.Add("<p>" + (Convert-Inline (($para -join " ").Trim())) + "</p>")
            $para.Clear()
        }
    }

    while ($i -lt $Lines.Count) {
        $trim = $Lines[$i].Trim()

        # 代码块
        if ($trim.StartsWith($fence)) {
            . $flushPara
            $lang = $trim.Substring(3).Trim()
            $buf = New-Object System.Collections.ArrayList
            $i++
            while ($i -lt $Lines.Count -and -not $Lines[$i].Trim().StartsWith($fence)) {
                [void]$buf.Add($Lines[$i])
                $i++
            }
            $i++
            # 没写语言标记时，按内容粗略判断：含命令特征的多半是终端命令
            if (-not $lang) {
                $joined = ($buf -join " ").ToLowerInvariant()
                if ($joined -match '^(npm|pip|git|cd |mkdir|curl|wget|node|python|docker|java|mysql|set-|export|\$env|echo|copy|xcopy|where|winget|choco|nvm)') { $lang = 'powershell' }
                elseif ($joined.Contains('select ') -or $joined.Contains('create table')) { $lang = 'sql' }
                elseif ($joined.Contains('import ') -and $joined.Contains('print(')) { $lang = 'python' }
            }
            $cls = ""
            if ($lang) { $cls = " class=" + $Q + "language-" + (ConvertTo-HtmlText $lang) + $Q }
            [void]$out.Add("<pre><code" + $cls + ">" + (ConvertTo-HtmlText ($buf -join $NL)) + "</code></pre>")
            continue
        }

        if ($trim -eq "") { . $flushPara; $i++; continue }

        # 分隔线：整行只有 - 或 * 或 _
        $onlyDash = ($trim.Length -ge 3)
        if ($onlyDash) {
            foreach ($c in $trim.ToCharArray()) {
                if ($c -ne $DASH -and $c -ne $STAR -and $c -ne [char]95) { $onlyDash = $false; break }
            }
        }
        if ($onlyDash) { . $flushPara; [void]$out.Add("<hr>"); $i++; continue }

        # 标题
        if ($trim.Length -gt 1 -and $trim[0] -eq $H) {
            $lvl = 0
            while ($lvl -lt $trim.Length -and $trim[$lvl] -eq $H) { $lvl++ }
            if ($lvl -le 6 -and $lvl -lt $trim.Length -and $trim[$lvl] -eq [char]32) {
                . $flushPara
                $text = $trim.Substring($lvl).Trim()
                $slug = Get-Slug $text
                # 同一页允许重复标题（如两处「✅ 验证」），id 必须唯一，否则锚点跳转失效
                if ($usedIds.ContainsKey($slug)) {
                    $usedIds[$slug] = $usedIds[$slug] + 1
                    $slug = $slug + [string][char]45 + [string]$usedIds[$slug]
                }
                else { $usedIds[$slug] = 1 }
                [void]$out.Add("<h" + $lvl + " id=" + $Q + $slug + $Q + ">" + (Convert-Inline $text) + "</h" + $lvl + ">")
                $i++
                continue
            }
        }

        # 表格
        $isSep = $false
        if ($trim.Contains($PIPE) -and ($i + 1) -lt $Lines.Count) {
            $nx = $Lines[$i + 1].Trim()
            if ($nx.Contains($DASH) -and $nx.Contains($PIPE)) {
                $bad = $false
                foreach ($c in $nx.ToCharArray()) {
                    if ($c -ne $DASH -and $c -ne $PIPE -and $c -ne [char]58 -and $c -ne [char]32) { $bad = $true; break }
                }
                if (-not $bad) { $isSep = $true }
            }
        }
        if ($isSep) {
            . $flushPara
            $header = Split-Cells $trim
            $i += 2
            $rows = New-Object System.Collections.ArrayList
            while ($i -lt $Lines.Count -and $Lines[$i].Trim().Contains($PIPE) -and $Lines[$i].Trim() -ne "") {
                [void]$rows.Add((Split-Cells $Lines[$i].Trim()))
                $i++
            }
            $t = New-Object System.Text.StringBuilder
            [void]$t.Append("<div class=" + $Q + "table-wrap" + $Q + "><table><thead><tr>")
            foreach ($h in $header) { [void]$t.Append("<th>" + (Convert-Inline $h) + "</th>") }
            [void]$t.Append("</tr></thead><tbody>")
            foreach ($r in $rows) {
                [void]$t.Append("<tr>")
                foreach ($c in $r) { [void]$t.Append("<td>" + (Convert-Inline $c) + "</td>") }
                [void]$t.Append("</tr>")
            }
            [void]$t.Append("</tbody></table></div>")
            [void]$out.Add($t.ToString())
            continue
        }

        # 引用
        if ($trim.StartsWith(">")) {
            . $flushPara
            $buf = New-Object System.Collections.ArrayList
            while ($i -lt $Lines.Count -and $Lines[$i].Trim().StartsWith(">")) {
                [void]$buf.Add($Lines[$i].Trim().Substring(1).Trim())
                $i++
            }
            [void]$out.Add("<blockquote><p>" + (Convert-Inline (($buf -join " ").Trim())) + "</p></blockquote>")
            continue
        }

        # 列表
        $bullet = $false
        if ($trim.Length -gt 1 -and ($trim[0] -eq $DASH -or $trim[0] -eq $STAR) -and $trim[1] -eq [char]32) { $bullet = $true }
        if ($bullet) {
            . $flushPara
            [void]$out.Add("<ul>")
            while ($i -lt $Lines.Count) {
                $t2 = $Lines[$i].Trim()
                if ($t2.Length -gt 1 -and ($t2[0] -eq $DASH -or $t2[0] -eq $STAR) -and $t2[1] -eq [char]32) {
                    [void]$out.Add("<li>" + (Convert-Inline $t2.Substring(2).Trim()) + "</li>")
                    $i++
                } else { break }
            }
            [void]$out.Add("</ul>")
            continue
        }

        $ordered = $false
        $dot = $trim.IndexOf(".")
        if ($dot -gt 0 -and ($dot + 1) -lt $trim.Length -and $trim[$dot + 1] -eq [char]32) {
            $numOk = $true
            for ($z = 0; $z -lt $dot; $z++) { if (-not [char]::IsDigit($trim[$z])) { $numOk = $false; break } }
            if ($numOk) { $ordered = $true }
        }
        if ($ordered) {
            . $flushPara
            [void]$out.Add("<ol>")
            while ($i -lt $Lines.Count) {
                $t2 = $Lines[$i].Trim()
                $d2 = $t2.IndexOf(".")
                if ($d2 -gt 0 -and ($d2 + 1) -lt $t2.Length -and $t2[$d2 + 1] -eq [char]32) {
                    [void]$out.Add("<li>" + (Convert-Inline $t2.Substring($d2 + 1).Trim()) + "</li>")
                    $i++
                } else { break }
            }
            [void]$out.Add("</ol>")
            continue
        }

        [void]$para.Add($trim)
        $i++
    }

    . $flushPara
    return ($out -join $NL)
}

function Split-Cells([string]$Row) {
    $c = $Row
    if ($c.StartsWith($PIPE)) { $c = $c.Substring(1) }
    if ($c.EndsWith($PIPE)) { $c = $c.Substring(0, $c.Length - 1) }
    return @($c -split [char]124 | ForEach-Object { $_.Trim() })
}

function New-SideNav([string]$ActiveRel, [string]$RootPrefix) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($g in $script:Groups) {
        [void]$sb.Append("<div class=" + $Q + "grp" + $Q + ">" + (ConvertTo-HtmlText $g) + "</div><ul>")
        foreach ($item in $script:GroupItems[$g]) {
            if ($item.IsIndex) {
                $rel = $RootPrefix + "index.html"
                $label = "首页"
            } else {
                $rel = $item.Rel -replace "[.]md$", ".html"
                if ($item.Rel.EndsWith("README.md")) {
                    $dirPart = ""
                    $s2 = $item.Rel.LastIndexOf("/")
                    if ($s2 -gt 0) { $dirPart = $item.Rel.Substring(0, $s2 + 1) }
                    $rel = $dirPart + "index.html"
                }
                $rel = $RootPrefix + $rel
                $label = (Split-Path -Leaf $item.Rel)
                if ($label.EndsWith(".md")) { $label = $label.Substring(0, $label.Length - 3) }
                $p = $label.IndexOf("-")
                if ($p -gt 0 -and $label.Substring(0, $p) -match "^[0-9]+$") { $label = $label.Substring($p + 1) }
            }
            $cls = ""
            if ($item.Rel -eq $ActiveRel) { $cls = " class=" + $Q + "active" + $Q }
            [void]$sb.Append("<li><a" + $cls + " href=" + $Q + $rel + $Q + ">" + (ConvertTo-HtmlText $label) + "</a></li>")
        }
        [void]$sb.Append("</ul>")
    }
    return $sb.ToString()
}

$cssLines = @(
'    :root{--bg:#0d1117;--border:#30363d;--text:#e6edf3;--muted:#8b949e;--accent:#58a6ff}',
'    *{box-sizing:border-box}',
'    body{margin:0;background:var(--bg);color:var(--text);font:15px/1.75 -apple-system,"Segoe UI","Microsoft YaHei",sans-serif}',
'    a{color:var(--accent);text-decoration:none}a:hover{text-decoration:underline}',
'    .layout{display:flex;max-width:1180px;margin:0 auto;gap:28px;padding:0 16px}',
'    nav.side{position:sticky;top:0;align-self:flex-start;height:100vh;overflow-y:auto;width:255px;flex:none;padding:22px 0;border-right:1px solid var(--border)}',
'    nav.side .brand{font-weight:700;font-size:16px;color:var(--text);margin-bottom:14px;display:block}',
'    nav.side ul{list-style:none;margin:0;padding:0}',
'    nav.side a{display:block;padding:5px 10px;border-radius:6px;color:var(--muted);font-size:13.5px}',
'    nav.side a:hover{background:#21262d;color:var(--text);text-decoration:none}',
'    nav.side a.active{background:rgba(31,111,235,.15);color:var(--accent);font-weight:600}',
'    nav.side .grp{margin-top:14px;font-size:11px;letter-spacing:.08em;color:#6e7681;padding-left:10px}',
'    main{flex:1;min-width:0;padding:26px 0 80px}',
'    h1{font-size:26px;border-bottom:1px solid var(--border);padding-bottom:12px;margin-top:0}',
'    h2{font-size:20px;margin-top:32px;padding-left:10px;border-left:4px solid var(--accent)}',
'    h3{font-size:17px;margin-top:24px}',
'    code{background:#21262d;padding:2px 6px;border-radius:5px;font-size:13px;font-family:Consolas,"Courier New",monospace}',
'    pre{background:#161b22;border:1px solid var(--border);border-radius:10px;padding:14px 16px;overflow-x:auto}',
'    pre code{background:none;padding:0;font-size:13px;line-height:1.6}',
'    .table-wrap{overflow-x:auto;border:1px solid var(--border);border-radius:10px;margin:16px 0}',
'    table{width:100%;border-collapse:collapse;font-size:14px}',
'    th,td{padding:9px 12px;text-align:left;border-bottom:1px solid var(--border);vertical-align:top}',
'    th{background:#1c2128;color:var(--muted);font-weight:600;white-space:nowrap}',
'    tr:last-child td{border-bottom:none}',
'    blockquote{margin:16px 0;padding:10px 16px;border-left:4px solid var(--border);background:#161b22;color:var(--muted);border-radius:0 8px 8px 0}',
'    blockquote p{margin:0}',
'    hr{border:none;border-top:1px solid var(--border);margin:28px 0}',
'    ul,ol{padding-left:24px}li{margin:6px 0}',
'    .pager{display:flex;justify-content:space-between;gap:12px;margin-top:44px;padding-top:20px;border-top:1px solid var(--border);font-size:14px}',
'    .pager a{max-width:46%}',
'    .pager .next{margin-left:auto;text-align:right}',
'    footer{margin-top:40px;color:#6e7681;font-size:12.5px}',
'    @media(max-width:820px){.layout{flex-direction:column}nav.side{position:static;height:auto;width:auto;border-right:none;border-bottom:1px solid var(--border)}}'
)
$css = $cssLines -join $NL

function New-PageHtml([string]$Title, [string]$Body, [string]$SideNav, [string]$Pager, [string]$RootPrefix) {
    $b = New-Object System.Text.StringBuilder
    [void]$b.AppendLine("<!DOCTYPE html>")
    [void]$b.AppendLine("<html lang=" + $Q + "zh-CN" + $Q + ">")
    [void]$b.AppendLine("<head>")
    [void]$b.AppendLine("<meta charset=" + $Q + "UTF-8" + $Q + ">")
    [void]$b.AppendLine("<meta name=" + $Q + "viewport" + $Q + " content=" + $Q + "width=device-width, initial-scale=1" + $Q + ">")
    [void]$b.AppendLine("<title>" + (ConvertTo-HtmlText $Title) + " · 小白成为计算机大佬</title>")
    [void]$b.AppendLine("<meta name=" + $Q + "description" + $Q + " content=" + $Q + "写给纯小白的计算机入门教程：科学上网 + Windows 软件环境部署" + $Q + ">")
    [void]$b.AppendLine("<style>" + $css + "</style>")
    [void]$b.AppendLine("</head>")
    [void]$b.AppendLine("<body>")
    [void]$b.AppendLine("<div class=" + $Q + "layout" + $Q + ">")
    [void]$b.AppendLine("<nav class=" + $Q + "side" + $Q + "><a class=" + $Q + "brand" + $Q + " href=" + $Q + $RootPrefix + "index.html" + $Q + ">📖 小白成为计算机大佬</a>" + $SideNav + "</nav>")
    [void]$b.AppendLine("<main>")
    [void]$b.AppendLine($Body)
    [void]$b.AppendLine($Pager)
    [void]$b.AppendLine("<footer>本页由 docs 下的 Markdown 自动生成 · <a href=" + $Q + "https://github.com/yanwaiyue-name/xiaobai-to-dalao" + $Q + ">查看源仓库</a></footer>")
    [void]$b.AppendLine("</main>")
    [void]$b.AppendLine("</div>")
    [void]$b.AppendLine("</body>")
    [void]$b.AppendLine("</html>")
    return $b.ToString()
}

# ---------------- 主流程 ----------------

if (-not (Test-Path -LiteralPath $DocsDir)) { throw ("找不到文档目录：" + $DocsDir) }
if (Test-Path -LiteralPath $OutDir) { Remove-Item -LiteralPath $OutDir -Recurse -Force }
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

$rootReadme = Join-Path $root "README.md"
$hasRootReadme = Test-Path -LiteralPath $rootReadme

$mdFiles = @(Get-ChildItem -LiteralPath $DocsDir -Recurse -Filter "*.md" -File | ForEach-Object {
    $rel = $_.FullName.Substring($DocsDir.Length).TrimStart([char]92, [char]47)
    $rel = $rel.Replace([string][char]92, "/")
    [pscustomobject]@{ Abs = $_.FullName; Rel = $rel }
} | Sort-Object Rel)

if ($mdFiles.Count -eq 0) { throw "docs 下没有找到任何 .md 文件" }

$script:Groups = New-Object System.Collections.ArrayList
$script:GroupItems = @{}

if ($hasRootReadme) {
    [void]$script:Groups.Add("开始")
    $script:GroupItems["开始"] = New-Object System.Collections.ArrayList
    [void]$script:GroupItems["开始"].Add([pscustomobject]@{ Rel = "../README.md"; IsIndex = $true })
}

foreach ($f in $mdFiles) {
    $segs = @(Split-Path2 $f.Rel)
    $g = "开始"
    if ($segs.Count -gt 1) {
        $g = $segs[0]
        $dash = $g.IndexOf("-")
        if ($dash -gt 0 -and $g.Substring(0, $dash) -match "^[0-9]+$") { $g = $g.Substring($dash + 1) }
        $paren = $g.IndexOf("（")
        if ($paren -gt 0) { $g = $g.Substring(0, $paren) }
    }
    if (-not $script:GroupItems.ContainsKey($g)) {
        [void]$script:Groups.Add($g)
        $script:GroupItems[$g] = New-Object System.Collections.ArrayList
    }
    [void]$script:GroupItems[$g].Add([pscustomobject]@{ Rel = $f.Rel; IsIndex = $false })
}

$pages = New-Object System.Collections.Generic.List[object]
$script:ExtraPageCount = 0

if ($hasRootReadme) {
    $script:CurDocDir = ""
    $script:CurSiteDir = ""
    $lines = @(Get-Content -LiteralPath $rootReadme -Encoding UTF8)
    $body = Convert-Markdown -Lines $lines
    $nav = New-SideNav -ActiveRel "../README.md" -RootPrefix ""
    $html = New-PageHtml -Title "首页" -Body $body -SideNav $nav -Pager "" -RootPrefix ""
    [System.IO.File]::WriteAllText((Join-Path $OutDir "index.html"), $html, $utf8)
    $pages.Add([pscustomobject]@{ OutRel = "index.html"; Title = "首页"; Depth = 0 })

    # 根目录的其他语言版本（README.en.md 等）与 SECURITY.md / CONTRIBUTING.md 一起渲染成根级页面。
    # 以前只渲染 README.md，导致根 README 里的 [English](README.en.md) 指向一个不存在的页面。
    $rootPages = @(Get-ChildItem -LiteralPath $root -File -Filter "*.md" |
        Where-Object { $_.Name -ne "README.md" } |
        Sort-Object Name)
    foreach ($rp in $rootPages) {
        $script:CurDocDir = ""
        $script:CurSiteDir = ""
        $rpOut = $rp.Name.Substring(0, $rp.Name.Length - 3) + ".html"
        $rpLines = @(Get-Content -LiteralPath $rp.FullName -Encoding UTF8)
        $rpBody = Convert-Markdown -Lines $rpLines
        $rpNav = New-SideNav -ActiveRel ("../" + $rp.Name) -RootPrefix ""
        $rpTitle = $rp.Name.Substring(0, $rp.Name.Length - 3)
        $rpHtml = New-PageHtml -Title $rpTitle -Body $rpBody -SideNav $rpNav -Pager "" -RootPrefix ""
        [System.IO.File]::WriteAllText((Join-Path $OutDir $rpOut), $rpHtml, $utf8)
        # 侧边栏与翻页只需要正文页，根级辅助文件（英文 README / 安全策略 / 贡献指南）不进 pages，
        # 避免“上一章/下一章”把它们串成阅读顺序。
        $script:ExtraPageCount++
    }
}

foreach ($f in $mdFiles) {
    $leafName = Split-Path -Leaf $f.Rel
    if ($leafName -eq "README.md" -and -not $f.Rel.Contains("/")) { continue }

    $outRel = $f.Rel
    if ($outRel.EndsWith(".md")) { $outRel = $outRel.Substring(0, $outRel.Length - 3) + ".html" }
    if ($leafName -eq "README.md") {
        $dirPart = $f.Rel.Substring(0, $f.Rel.Length - "README.md".Length)
        $outRel = $dirPart + "index.html"
    }

    $outPath = Join-Path $OutDir $outRel
    $parent = Split-Path -Parent $outPath
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    # 注意：$f.Rel 已统一为 / 分隔，Split-Path 只认平台分隔符，这里必须手工截取
    $siteDir = ""
    $slash = $outRel.LastIndexOf("/")
    if ($slash -gt 0) { $siteDir = $outRel.Substring(0, $slash) }

    $docSub = ""
    $slash2 = $f.Rel.LastIndexOf("/")
    if ($slash2 -gt 0) { $docSub = $f.Rel.Substring(0, $slash2) }
    if ($docSub) { $script:CurDocDir = "docs/" + $docSub }
    else { $script:CurDocDir = "docs" }
    $script:CurSiteDir = $siteDir

    $lines = @(Get-Content -LiteralPath $f.Abs -Encoding UTF8)
    $body = Convert-Markdown -Lines $lines

    $title = $leafName
    if ($title.EndsWith(".md")) { $title = $title.Substring(0, $title.Length - 3) }
    $dash = $title.IndexOf("-")
    if ($dash -gt 0 -and $title.Substring(0, $dash) -match "^[0-9]+$") { $title = $title.Substring($dash + 1) }

    $depth = @(Split-Path2 $siteDir).Count
    $rootPrefix = ""
    for ($z = 0; $z -lt $depth; $z++) { $rootPrefix += "../" }

    $nav = New-SideNav -ActiveRel $f.Rel -RootPrefix $rootPrefix
    $html = New-PageHtml -Title $title -Body $body -SideNav $nav -Pager "" -RootPrefix $rootPrefix
    [System.IO.File]::WriteAllText($outPath, $html, $utf8)

    $pages.Add([pscustomobject]@{ OutRel = $outRel; Title = $title; Depth = $depth })
}

for ($k = 0; $k -lt $pages.Count; $k++) {
    $cur = $pages[$k]
    $prefix = ""
    for ($z = 0; $z -lt $cur.Depth; $z++) { $prefix += "../" }

    $prevHtml = ""
    if ($k -gt 0) {
        $prevHtml = "<a class=" + $Q + "prev" + $Q + " href=" + $Q + $prefix + $pages[$k - 1].OutRel + $Q + ">← " + (ConvertTo-HtmlText $pages[$k - 1].Title) + "</a>"
    }
    $nextHtml = ""
    if ($k -lt ($pages.Count - 1)) {
        $nextHtml = "<a class=" + $Q + "next" + $Q + " href=" + $Q + $prefix + $pages[$k + 1].OutRel + $Q + ">" + (ConvertTo-HtmlText $pages[$k + 1].Title) + " →</a>"
    }
    if ($prevHtml -or $nextHtml) {
        $pager = "<div class=" + $Q + "pager" + $Q + ">" + $prevHtml + $nextHtml + "</div>"
        $path = Join-Path $OutDir $cur.OutRel
        $doc = [System.IO.File]::ReadAllText($path, $utf8)
        $doc = $doc.Replace("<footer>", $pager + $NL + "<footer>")
        [System.IO.File]::WriteAllText($path, $doc, $utf8)
    }
}

Write-Output ("站点已生成：" + ($pages.Count + $script:ExtraPageCount) + " 个页面 -> " + $OutDir)

