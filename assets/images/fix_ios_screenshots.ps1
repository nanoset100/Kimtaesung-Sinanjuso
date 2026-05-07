Add-Type -AssemblyName System.Drawing

$dir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcs = @(
    'KakaoTalk_20260417_144402117.jpg',
    'KakaoTalk_20260417_144413219.jpg',
    'KakaoTalk_20260417_144425459.jpg',
    'KakaoTalk_20260417_144446691.jpg',
    'KakaoTalk_20260417_144501998.jpg'
)

$bgTop = [System.Drawing.Color]::FromArgb(255, 18, 40, 80)
$bgBot = [System.Drawing.Color]::FromArgb(255, 35, 72, 130)
$accC  = [System.Drawing.Color]::FromArgb(255, 232, 148, 26)
$black = [System.Drawing.Color]::FromArgb(255, 10, 10, 12)
$white = [System.Drawing.Color]::White

$jpgEnc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq 'image/jpeg' }
$jpgP = New-Object System.Drawing.Imaging.EncoderParameters(1)
$jpgP.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
    [System.Drawing.Imaging.Encoder]::Quality, [long]95
)

function Make-iOS-Screenshot {
    param($srcPath, $dstPath, $canvasW, $canvasH)

    $bytes   = [System.IO.File]::ReadAllBytes($srcPath)
    $ms      = New-Object System.IO.MemoryStream($bytes, $false)
    $orig    = [System.Drawing.Image]::FromStream($ms)

    # Crop Android status bar (top 4.5%) and nav bar (bottom 6.5%)
    $cropTop = [int]($orig.Height * 0.045)
    $cropBot = [int]($orig.Height * 0.065)
    $cropH   = $orig.Height - $cropTop - $cropBot
    $cRect   = New-Object System.Drawing.Rectangle(0, $cropTop, $orig.Width, $cropH)
    $cropped = $orig.Clone($cRect, $orig.PixelFormat)
    $orig.Dispose()
    $ms.Dispose()

    # Create 24bpp canvas (no alpha channel)
    $canvas = New-Object System.Drawing.Bitmap(
        $canvasW, $canvasH,
        [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    )
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # Gradient background
    $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0, 0),
        [System.Drawing.Point]::new(0, $canvasH),
        $bgTop, $bgBot
    )
    $g.FillRectangle($grad, 0, 0, $canvasW, $canvasH)
    $grad.Dispose()

    # Decorative circles
    $dcb = New-Object System.Drawing.SolidBrush(
        [System.Drawing.Color]::FromArgb(15, 255, 255, 255)
    )
    $g.FillEllipse($dcb, -150, -150, 600, 600)
    $g.FillEllipse($dcb, [int]($canvasW * 0.7), [int]($canvasH * 0.75), 500, 500)
    $dcb.Dispose()

    # Header text (Korean via Base64)
    $fH = New-Object System.Drawing.Font('Arial', [int]($canvasW * 0.028), [System.Drawing.FontStyle]::Bold)
    $fS = New-Object System.Drawing.Font('Arial', [int]($canvasW * 0.014))
    $wb = New-Object System.Drawing.SolidBrush($white)
    $gb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 255, 255, 255))

    $t1  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('6rmA7YOd7ISg6rhA7Iig7JeI7JWE'))
    $t2  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('7Iug7JOw6rO87IucIOyEsOyKpO9hoO9hgCDqtZzsiJg='))
    $sz1 = $g.MeasureString($t1, $fH)
    $g.DrawString($t1, $fH, $wb, ($canvasW - $sz1.Width) / 2, [int]($canvasH * 0.016))
    $sz2 = $g.MeasureString($t2, $fS)
    $g.DrawString($t2, $fS, $gb, ($canvasW - $sz2.Width) / 2, [int]($canvasH * 0.016) + $sz1.Height + 4)

    $pen   = New-Object System.Drawing.Pen($accC, 3)
    $lineY = [int]($canvasH * 0.016) + [int]($sz1.Height) + [int]($sz2.Height) + 18
    $g.DrawLine($pen, [int]($canvasW * 0.08), $lineY, [int]($canvasW * 0.92), $lineY)
    $pen.Dispose()

    # App image placement
    $availW    = [int]($canvasW * 0.78)
    $availH    = [int]($canvasH * 0.70)
    $scale     = [Math]::Min($availW / $cropped.Width, $availH / $cropped.Height)
    $dw        = [int]($cropped.Width  * $scale)
    $dh        = [int]($cropped.Height * $scale)
    $dx        = [int](($canvasW - $dw) / 2)
    $phoneTopH = [int]($dw * 0.060)
    $phoneBotH = [int]($dw * 0.048)
    $totalH    = $dh + $phoneTopH + $phoneBotH
    $dy        = $lineY + [int](($canvasH - $lineY - $totalH) / 2)

    # Shadow
    for ($s = 12; $s -ge 1; $s--) {
        $sa = [int](45 * $s / 12)
        $sb = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($sa, 0, 0, 0))
        $g.FillRectangle($sb, $dx + $s, $dy + $s, $dw + 16, $totalH + 16)
        $sb.Dispose()
    }

    # Phone bezel
    $bp = 8
    $bb = New-Object System.Drawing.SolidBrush($black)
    $g.FillRectangle($bb, $dx - $bp, $dy, $dw + $bp * 2, $totalH)
    $bb.Dispose()

    # iOS status bar (black)
    $stB = New-Object System.Drawing.SolidBrush($black)
    $g.FillRectangle($stB, $dx, $dy, $dw, $phoneTopH)
    $stB.Dispose()

    # Dynamic Island oval
    $diW = [int]($dw * 0.30)
    $diH = [int]($phoneTopH * 0.58)
    $diX = $dx + ($dw - $diW) / 2
    $diY = $dy + [int]($phoneTopH * 0.20)
    $diB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 18, 18, 20))
    $g.FillEllipse($diB, $diX, $diY, $diW, $diH)
    $diB.Dispose()

    # App content
    $cR = New-Object System.Drawing.Rectangle($dx, ($dy + $phoneTopH), $dw, $dh)
    $g.DrawImage($cropped, $cR)
    $cropped.Dispose()

    # iOS Home Indicator
    $homeY = $dy + $phoneTopH + $dh
    $homeB = New-Object System.Drawing.SolidBrush($black)
    $g.FillRectangle($homeB, $dx, $homeY, $dw, $phoneBotH)
    $homeB.Dispose()

    $barW = [int]($dw * 0.34)
    $barH = [int]($phoneBotH * 0.22)
    $barX = $dx + ($dw - $barW) / 2
    $barY = $homeY + [int]($phoneBotH * 0.44)
    $barB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 255, 255, 255))
    $g.FillRectangle($barB, $barX, $barY, $barW, $barH)
    $barB.Dispose()

    # Phone border
    $bdrP = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 255, 255, 255), 1.5)
    $g.DrawRectangle($bdrP, $dx - $bp, $dy, $dw + $bp * 2 - 1, $totalH - 1)
    $bdrP.Dispose()

    # Footer candidate name
    $fF  = New-Object System.Drawing.Font('Arial', [int]($canvasW * 0.013))
    $ft  = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('6rmA7YOd7ISgIOyLnOyEsOqzuOuvuOyXhCDslYTrs4Ttlbg='))
    $fsz = $g.MeasureString($ft, $fF)
    $fy  = $canvasH - [int]($canvasH * 0.038)
    $g.DrawString($ft, $fF, $gb, ($canvasW - $fsz.Width) / 2, $fy)

    $dd   = [int]($canvasW * 0.008)
    $dotB = New-Object System.Drawing.SolidBrush($accC)
    $g.FillEllipse($dotB, [int](($canvasW - $fsz.Width) / 2) - $dd * 2, $fy + $dd / 2, $dd, $dd)
    $g.FillEllipse($dotB, [int](($canvasW + $fsz.Width) / 2) + $dd,     $fy + $dd / 2, $dd, $dd)
    $dotB.Dispose()

    $fH.Dispose(); $fS.Dispose(); $fF.Dispose()
    $wb.Dispose(); $gb.Dispose()
    $g.Dispose()
    $canvas.Save($dstPath, $jpgEnc, $jpgP)
    $canvas.Dispose()
    [GC]::Collect()
}

Write-Host '=== iPhone 1242x2688 ==='
for ($i = 0; $i -lt 5; $i++) {
    $s = Join-Path $dir $srcs[$i]
    $d = Join-Path $dir "iphone_ss$($i+1)_1242x2688.jpg"
    Make-iOS-Screenshot $s $d 1242 2688
    Write-Host "  [$($i+1)/5] OK: $d"
}

Write-Host '=== iPad 2048x2732 ==='
for ($i = 0; $i -lt 5; $i++) {
    $s = Join-Path $dir $srcs[$i]
    $d = Join-Path $dir "ipad_ss$($i+1)_2048x2732.jpg"
    Make-iOS-Screenshot $s $d 2048 2732
    Write-Host "  [$($i+1)/5] OK: $d"
}

Write-Host 'ALL DONE'

