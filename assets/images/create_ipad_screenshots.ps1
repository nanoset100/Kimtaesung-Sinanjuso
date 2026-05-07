# iPad Screenshot Generator (2048x2732)
# iPhone 소스: ios_final_X_1242x2688.png
# iPad 출력: ipad_final_X_2048x2732.png

Add-Type -AssemblyName System.Drawing

$imgDir = $PSScriptRoot
$iPadW  = 2048
$iPadH  = 2732

# 앱 브랜드 색상
$bgColor     = [System.Drawing.Color]::FromArgb(255, 27, 58, 107)    # #1B3A6B 진파랑
$frameColor  = [System.Drawing.Color]::FromArgb(255, 20, 20, 28)     # 아이패드 베젤 어두운 색
$screenBg    = [System.Drawing.Color]::FromArgb(255, 245, 247, 250)  # 화면 배경
$accentColor = [System.Drawing.Color]::FromArgb(255, 232, 148, 26)   # #E8941A 오렌지

# 화면 레이블 (각 스크린샷 설명)
$labels = @(
    "핵심 정책 6가지",
    "최신 뉴스 피드",
    "직통 연락 · 소통",
    "설문 · 유권자 투표",
    "팩트체크 · 알림"
)

for ($i = 1; $i -le 5; $i++) {
    $srcPath = Join-Path $imgDir "ios_final_${i}_1242x2688.png"
    $dstPath = Join-Path $imgDir "ipad_final_${i}_2048x2732.png"

    if (-not (Test-Path $srcPath)) {
        Write-Host "소스 없음: $srcPath" -ForegroundColor Red
        continue
    }

    Write-Host "처리중: ios_final_${i} → ipad_final_${i} ..." -ForegroundColor Cyan

    # 캔버스 생성
    $canvas = New-Object System.Drawing.Bitmap($iPadW, $iPadH)
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

    # ─── 1. 배경 그라디언트 (위→아래: 진파랑→약간 밝은 파랑) ───
    $gradBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.Point]::new(0, 0),
        [System.Drawing.Point]::new(0, $iPadH),
        [System.Drawing.Color]::FromArgb(255, 18, 40, 80),
        [System.Drawing.Color]::FromArgb(255, 35, 72, 130)
    )
    $g.FillRectangle($gradBrush, 0, 0, $iPadW, $iPadH)
    $gradBrush.Dispose()

    # ─── 2. 장식용 원형 요소 ───
    $circleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(20, 255, 255, 255))
    $g.FillEllipse($circleBrush, -200, -200, 700, 700)
    $g.FillEllipse($circleBrush, 1600, 2200, 600, 600)
    $circleBrush.Dispose()

    # ─── 3. 상단 헤더 영역 ───
    $headerH = 280
    # 로고/앱이름 텍스트
    $titleFont  = New-Object System.Drawing.Font("Arial", 62, [System.Drawing.FontStyle]::Bold)
    $subFont    = New-Object System.Drawing.Font("Arial", 32, [System.Drawing.FontStyle]::Regular)
    $labelFont  = New-Object System.Drawing.Font("Arial", 38, [System.Drawing.FontStyle]::Bold)
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $accentBrush= New-Object System.Drawing.SolidBrush($accentColor)
    $grayBrush  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 255, 255, 255))

    # 앱 이름
    $appTitle = "김태성과 신안"
    $titleSize = $g.MeasureString($appTitle, $titleFont)
    $titleX = ($iPadW - $titleSize.Width) / 2
    $g.DrawString($appTitle, $titleFont, $whiteBrush, $titleX, 55)

    # 부제목
    $subTitle = "신안군수 예비후보 공식 앱"
    $subSize = $g.MeasureString($subTitle, $subFont)
    $subX = ($iPadW - $subSize.Width) / 2
    $g.DrawString($subTitle, $subFont, $grayBrush, $subX, 155)

    # 오렌지 구분선
    $linePen = New-Object System.Drawing.Pen($accentColor, 4)
    $lineY = 220
    $g.DrawLine($linePen, 180, $lineY, $iPadW - 180, $lineY)
    $linePen.Dispose()

    # ─── 4. iPhone 스크린샷을 iPad 중앙에 배치 ───
    $srcImg = [System.Drawing.Image]::FromFile($srcPath)
    $srcW = $srcImg.Width   # 1242
    $srcH = $srcImg.Height  # 2688

    # 아이폰 프레임 영역 계산
    # 아이패드 중앙에 아이폰 크기 비율 유지하며 배치
    $availW = [int]($iPadW * 0.62)   # 1270px
    $availH = [int]($iPadH * 0.70)   # 1912px
    $scale  = [Math]::Min($availW / $srcW, $availH / $srcH)
    $dstW   = [int]($srcW * $scale)
    $dstH   = [int]($srcH * $scale)
    $dstX   = ($iPadW - $dstW) / 2
    $dstY   = $headerH + 40

    # 폰 그림자
    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 0, 0, 0))
    $g.FillRoundedRectangle = $null  # PowerShell에서 확장 불가, 직접 그리기
    for ($s = 20; $s -ge 1; $s--) {
        $alpha = [int](60 * ($s / 20))
        $sBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($alpha, 0, 0, 0))
        $g.FillRectangle($sBrush, ($dstX + $s), ($dstY + $s), $dstW, $dstH)
        $sBrush.Dispose()
    }
    $shadowBrush.Dispose()

    # 폰 베젤 (어두운 테두리)
    $bezelPad = 12
    $bezelBrush = New-Object System.Drawing.SolidBrush($frameColor)
    $g.FillRectangle($bezelBrush, ($dstX - $bezelPad), ($dstY - $bezelPad), ($dstW + $bezelPad*2), ($dstH + $bezelPad*2))
    $bezelBrush.Dispose()

    # 실제 스크린샷 그리기
    $destRect = New-Object System.Drawing.Rectangle($dstX, $dstY, $dstW, $dstH)
    $g.DrawImage($srcImg, $destRect)
    $srcImg.Dispose()

    # 폰 테두리 선
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 255, 255, 255), 2)
    $g.DrawRectangle($borderPen, ($dstX - $bezelPad), ($dstY - $bezelPad), ($dstW + $bezelPad*2), ($dstH + $bezelPad*2))
    $borderPen.Dispose()

    # ─── 5. 하단 기능 설명 텍스트 ───
    $bottomY = $dstY + $dstH + $bezelPad + 60
    $label   = $labels[$i - 1]
    $labelSize = $g.MeasureString($label, $labelFont)
    $labelX  = ($iPadW - $labelSize.Width) / 2

    # 텍스트 배경 캡슐
    $capsuleW = [int]($labelSize.Width + 80)
    $capsuleH = 70
    $capsuleX = [int](($iPadW - $capsuleW) / 2)
    $capsuleBrush = New-Object System.Drawing.SolidBrush($accentColor)
    $g.FillRectangle($capsuleBrush, $capsuleX, $bottomY - 8, $capsuleW, $capsuleH)
    $capsuleBrush.Dispose()

    $g.DrawString($label, $labelFont, $whiteBrush, $labelX, $bottomY)

    # ─── 6. 하단 후보명 ───
    $footerFont = New-Object System.Drawing.Font("Arial", 28, [System.Drawing.FontStyle]::Regular)
    $footerText = "김태성 신안군수 예비후보"
    $footerSize = $g.MeasureString($footerText, $footerFont)
    $footerX = ($iPadW - $footerSize.Width) / 2
    $footerY = $iPadH - 100
    $g.DrawString($footerText, $footerFont, $grayBrush, $footerX, $footerY)

    # 오렌지 도트 장식
    $dotBrush = New-Object System.Drawing.SolidBrush($accentColor)
    $g.FillEllipse($dotBrush, ($footerX - 35), ($footerY + 10), 20, 20)
    $g.FillEllipse($dotBrush, ($footerX + $footerSize.Width + 15), ($footerY + 10), 20, 20)
    $dotBrush.Dispose()

    # ─── 정리 및 저장 ───
    $titleFont.Dispose(); $subFont.Dispose(); $labelFont.Dispose(); $footerFont.Dispose()
    $whiteBrush.Dispose(); $accentBrush.Dispose(); $grayBrush.Dispose()
    $g.Dispose()

    $canvas.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Dispose()

    Write-Host "  저장: $dstPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== iPad 스크린샷 5장 생성 완료 ===" -ForegroundColor Yellow
Write-Host "파일: ipad_final_1~5_2048x2732.png" -ForegroundColor Yellow
