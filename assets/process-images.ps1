# Asset pipeline for Salvation Security Agency homepage
# Requires: Windows PowerShell 5.1 with .NET System.Drawing
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

$root = "D:\Workspace\Project\Security agency\assets\img"

function Resize-Save {
    param([string]$src, [string]$dst, [int]$w, [int]$h, [string]$format = 'jpeg', [long]$quality = 80)
    $img = [System.Drawing.Image]::FromFile($src)
    try {
        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        try {
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            if ($format -eq 'jpeg') {
                $bg = [System.Drawing.Color]::White
                $g.Clear($bg)
            }
            $g.DrawImage($img, 0, 0, $w, $h)
        } finally { $g.Dispose() }

        if ($format -eq 'jpeg') {
            $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
            $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $quality)
            $bmp.Save($dst, $codec, $ep)
        } else {
            $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        $bmp.Dispose()
    } finally { $img.Dispose() }
}

function Crop-Resize-Save {
    param([string]$src, [string]$dst, [int]$cx, [int]$cy, [int]$cw, [int]$ch, [int]$w, [int]$h, [string]$format = 'png', [long]$quality = 90)
    $img = [System.Drawing.Image]::FromFile($src)
    try {
        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        try {
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $dstRect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
            $srcRect = New-Object System.Drawing.Rectangle($cx, $cy, $cw, $ch)
            $g.DrawImage($img, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        } finally { $g.Dispose() }
        if ($format -eq 'jpeg') {
            $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
            $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $quality)
            $bmp.Save($dst, $codec, $ep)
        } else {
            $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        $bmp.Dispose()
    } finally { $img.Dispose() }
}

$logo = Join-Path $root 'salvation-logo.png'

# 1. Logo: full logo resized to 960px wide, transparency preserved
Resize-Save -src $logo -dst (Join-Path $root 'logo.png') -w 960 -h 273 -format png

# 2. Badge crop for light backgrounds + favicon source (badge occupies left square of the strip)
Crop-Resize-Save -src $logo -dst (Join-Path $root 'logo-badge.png') -cx 0 -cy 0 -cw 729 -ch 729 -w 256 -h 256 -format png
Crop-Resize-Save -src $logo -dst (Join-Path $root 'favicon-32.png') -cx 0 -cy 0 -cw 729 -ch 729 -w 32 -h 32 -format png
Crop-Resize-Save -src $logo -dst (Join-Path $root 'favicon-16.png') -cx 0 -cy 0 -cw 729 -ch 729 -w 16 -h 16 -format png

# 3. OG image: navy card with badge + wordmark text
$ogW = 1200; $ogH = 630
$og = New-Object System.Drawing.Bitmap($ogW, $ogH)
$g = [System.Drawing.Graphics]::FromImage($og)
try {
    $navy = [System.Drawing.Color]::FromArgb(255, 16, 36, 59)
    $gold = [System.Drawing.Color]::FromArgb(255, 216, 183, 108)
    $white = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
    $g.Clear($navy)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # gold accent line
    $pen = New-Object System.Drawing.Pen($gold, 6)
    $g.DrawLine($pen, 0, 624, $ogW, 624)

    # badge
    $badge = [System.Drawing.Image]::FromFile((Join-Path $root 'logo-badge.png'))
    $g.DrawImage($badge, 90, 165, 300, 300)
    $badge.Dispose()

    # text
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    $fontBig = New-Object System.Drawing.Font('Georgia', 44, [System.Drawing.FontStyle]::Bold)
    $fontSmall = New-Object System.Drawing.Font('Arial', 22, [System.Drawing.FontStyle]::Regular)
    $brushW = New-Object System.Drawing.SolidBrush($white)
    $brushG = New-Object System.Drawing.SolidBrush($gold)
    $g.DrawString('Salvation Security', $fontBig, $brushW, 430, 210)
    $g.DrawString('Agency Inc.', $fontBig, $brushW, 430, 280)
    $g.DrawString('Protecting What Matters Most.', $fontSmall, $brushG, 434, 380)
    $fontBig.Dispose(); $fontSmall.Dispose(); $brushW.Dispose(); $brushG.Dispose(); $pen.Dispose()
} finally { $g.Dispose() }

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 90L)
$og.Save((Join-Path $root 'og-image.jpg'), $codec, $ep)
$og.Dispose()

# 4. Photos -> optimized JPEGs
Resize-Save -src (Join-Path $root 'hero-security-guard_1794193558403_29128379.png')   -dst (Join-Path $root 'hero.jpg')                 -w 840 -h 1260 -format jpeg -quality 82
Resize-Save -src (Join-Path $root 'about-security-team_1794193604842_95a469e0.png')   -dst (Join-Path $root 'about.jpg')                -w 760 -h 760  -format jpeg -quality 80
Resize-Save -src (Join-Path $root 'industry-commercial_1794193631043_07f271e5.png')   -dst (Join-Path $root 'industry-commercial.jpg')  -w 640 -h 640  -format jpeg -quality 78
Resize-Save -src (Join-Path $root 'industry-residential_1794193680977_2d75b027.png')  -dst (Join-Path $root 'industry-residential.jpg') -w 640 -h 640  -format jpeg -quality 78
Resize-Save -src (Join-Path $root 'industry-corporate_1794193707334_38f1db68.png')    -dst (Join-Path $root 'industry-corporate.jpg')   -w 640 -h 640  -format jpeg -quality 78
Resize-Save -src (Join-Path $root 'industry-events_1794193736695_29812b29.png')       -dst (Join-Path $root 'industry-events.jpg')      -w 640 -h 640  -format jpeg -quality 78

# 5. Remove originals now that derivatives exist
Get-ChildItem -Path $root -Filter '*_1794*.png' | Remove-Item -Force
Remove-Item $logo -Force

Get-ChildItem $root | Select-Object Name, Length | Format-Table -AutoSize
Write-Host 'DONE'
