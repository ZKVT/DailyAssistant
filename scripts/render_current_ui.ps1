Add-Type -AssemblyName System.Drawing

$scale = 1
$w = 390
$h = 844
$bmp = New-Object System.Drawing.Bitmap ($w * $scale), ($h * $scale)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.ScaleTransform($scale, $scale)

function Color([int]$r, [int]$g, [int]$b, [int]$a = 255) {
    [System.Drawing.Color]::FromArgb($a, $r, $g, $b)
}

function Brush([System.Drawing.Color]$color) {
    New-Object System.Drawing.SolidBrush $color
}

function Pen([System.Drawing.Color]$color, [float]$width = 1) {
    New-Object System.Drawing.Pen $color, $width
}

function FontOf([float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
    [System.Drawing.Font]::new("Segoe UI", $size, $style, [System.Drawing.GraphicsUnit]::Point)
}

function RoundedPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $path
}

function FillRoundRect([float]$x, [float]$y, [float]$w, [float]$h, [float]$r, [System.Drawing.Color]$color) {
    if ($r -le 0) {
        $rect = New-Object System.Drawing.RectangleF $x, $y, $w, $h
        $g.FillRectangle((Brush $color), $rect)
        return
    }
    $path = RoundedPath $x $y $w $h $r
    $g.FillPath((Brush $color), $path)
    $path.Dispose()
}

function DrawText([string]$text, [float]$x, [float]$y, [float]$w, [float]$h, [System.Drawing.Font]$font, [System.Drawing.Color]$color, [string]$align = "Near") {
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::$align
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $rect = New-Object System.Drawing.RectangleF $x, $y, $w, $h
    $g.DrawString($text, $font, (Brush $color), $rect, $format)
    $format.Dispose()
}

function DrawCircleIcon([string]$glyph, [float]$x, [float]$y, [System.Drawing.Color]$tint) {
    FillRoundRect $x $y 26 26 13 (Color $tint.R $tint.G $tint.B 36)
    DrawText $glyph ($x + 1) ($y + 3) 24 20 (FontOf 10 ([System.Drawing.FontStyle]::Bold)) $tint "Center"
}

function DrawSquareIcon([string]$glyph, [float]$x, [float]$y, [System.Drawing.Color]$tint) {
    FillRoundRect $x $y 34 34 10 (Color $tint.R $tint.G $tint.B 33)
    DrawText $glyph ($x + 2) ($y + 7) 30 20 (FontOf 10 ([System.Drawing.FontStyle]::Bold)) $tint "Center"
}

function DrawSectionTitle([string]$title, [string]$glyph, [float]$x, [float]$y, [System.Drawing.Color]$tint) {
    DrawCircleIcon $glyph $x $y $tint
    DrawText $title ($x + 36) ($y + 2) 240 26 (FontOf 11.5 ([System.Drawing.FontStyle]::Bold)) (Color 28 28 30)
}

function DrawPill([string]$text, [float]$x, [float]$y, [float]$w) {
    FillRoundRect $x $y $w 30 15 (Color 242 242 247)
    DrawText $text ($x + 10) ($y + 7) ($w - 20) 18 (FontOf 9.5 ([System.Drawing.FontStyle]::Bold)) (Color 99 99 102)
}

function DrawRow([string]$title, [string]$subtitle, [string]$meta, [string]$glyph, [float]$x, [float]$y, [System.Drawing.Color]$tint) {
    DrawSquareIcon $glyph $x $y $tint
    DrawText $title ($x + 46) ($y - 1) 185 34 (FontOf 10.2 ([System.Drawing.FontStyle]::Bold)) (Color 28 28 30)
    DrawText $subtitle ($x + 46) ($y + 25) 170 18 (FontOf 9.2) (Color 99 99 102)
    DrawText $meta ($x + 238) ($y + 1) 64 35 (FontOf 8.6 ([System.Drawing.FontStyle]::Bold)) (Color 99 99 102) "Far"
}

$bg = Color 242 242 247
$card = Color 255 255 255
$primary = Color 28 28 30
$secondary = Color 99 99 102
$blue = Color 0 122 255
$purple = Color 175 82 222
$orange = Color 255 149 0
$teal = Color 48 176 199
$green = Color 52 199 89

$g.Clear($bg)

# Status and navigation bars.
DrawText "9:41" 28 14 70 22 (FontOf 10.5 ([System.Drawing.FontStyle]::Bold)) $primary
FillRoundRect 303 18 21 10 5 $primary
FillRoundRect 329 18 17 10 3 $primary
FillRoundRect 351 17 24 12 3 $primary
DrawText "Today" 0 50 390 28 (FontOf 12.5 ([System.Drawing.FontStyle]::Bold)) $primary "Center"

$contentX = 20
$y = 94

DrawText "Good Afternoon" $contentX $y 350 44 (FontOf 24 ([System.Drawing.FontStyle]::Bold)) $primary
$y += 43
DrawText "Richmond, BC     Saturday, June 13, 2026" $contentX $y 350 24 (FontOf 10.5 ([System.Drawing.FontStyle]::Bold)) $secondary
$y += 42

# Weather.
FillRoundRect $contentX $y 350 178 24 $card
DrawSectionTitle "Weather" "RAIN" ($contentX + 18) ($y + 18) $blue
DrawText "16" ($contentX + 260) ($y + 13) 52 44 (FontOf 25 ([System.Drawing.FontStyle]::Bold)) $primary "Far"
DrawText "C" ($contentX + 314) ($y + 22) 18 20 (FontOf 10 ([System.Drawing.FontStyle]::Bold)) $primary
DrawText "Light Rain" ($contentX + 18) ($y + 65) 250 28 (FontOf 15 ([System.Drawing.FontStyle]::Bold)) $primary
DrawText "Bring an umbrella and choose a cozy indoor stop." ($contentX + 18) ($y + 98) 300 38 (FontOf 10.5) $secondary
DrawPill "DROP  68% rain chance" ($contentX + 18) ($y + 130) 150
$y += 196

# Recommendation.
FillRoundRect $contentX $y 350 150 24 $card
DrawSectionTitle "Today's Recommendation" "SPK" ($contentX + 18) ($y + 18) $purple
DrawText "Today is a good day for indoor activities, warm food, and a short evening walk if the rain eases." ($contentX + 18) ($y + 61) 304 48 (FontOf 9.8 ([System.Drawing.FontStyle]::Bold)) $primary
DrawPill "TARGET  Cozy and practical" ($contentX + 18) ($y + 111) 172
$y += 168

# Food.
FillRoundRect $contentX $y 350 212 24 $card
DrawSectionTitle "Food Suggestions" "FOOD" ($contentX + 18) ($y + 18) $orange
DrawRow "Steveston Seafood Bowl" "Seafood" "3.2 km`nStar 4.6" "F" ($contentX + 18) ($y + 62) $orange
DrawRow "Alexandra Road Noodles" "Noodles" "1.8 km`nStar 4.5" "F" ($contentX + 18) ($y + 112) $orange
DrawRow "Local Bakery Cafe" "Cafe" "0.9 km`nStar 4.4" "F" ($contentX + 18) ($y + 162) $orange

# Tab bar.
FillRoundRect 0 762 390 82 0 (Color 255 255 255 242)
$g.DrawLine((Pen (Color 210 210 215)), 0, 762, 390, 762)
DrawText "SUN" 95 777 36 20 (FontOf 8.5 ([System.Drawing.FontStyle]::Bold)) $blue "Center"
DrawText "Today" 83 799 60 20 (FontOf 8.5 ([System.Drawing.FontStyle]::Bold)) $blue "Center"
DrawText "GEAR" 257 777 36 20 (FontOf 8.5 ([System.Drawing.FontStyle]::Bold)) $secondary "Center"
DrawText "Settings" 241 799 68 20 (FontOf 8.5) $secondary "Center"

$outDir = Join-Path (Get-Location) "renders"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$out = Join-Path $outDir "daily_local_assistant_home.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output $out
