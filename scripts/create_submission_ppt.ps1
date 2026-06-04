$ErrorActionPreference = "Stop"

# 제출용 PPT 생성 스크립트
# MATLAB에서 만든 data/ppt_assets 이미지를 사용해서 PowerPoint 파일을 만든다.
# PowerPoint가 설치된 Windows 노트북에서 실행하면 deliverables 폴더에 PPTX가 생성된다.

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$AssetDir = Join-Path $ProjectRoot "data\ppt_assets"
$OutDir = Join-Path $ProjectRoot "deliverables"
if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$OutFile = Join-Path $OutDir "WiFi_CSI_patient_monitoring_capstone.pptx"
if (Test-Path $OutFile) {
    Remove-Item -LiteralPath $OutFile -Force
}

$ppt = New-Object -ComObject PowerPoint.Application
$ppt.Visible = [Microsoft.Office.Core.MsoTriState]::msoTrue
$presentation = $ppt.Presentations.Add()
$presentation.PageSetup.SlideWidth = 960
$presentation.PageSetup.SlideHeight = 540

$fontName = "Malgun Gothic"
$dark = 0x27231F
$muted = 0x63564B
$teal = 0x66450E
$orange = 0x1E46ED

function Add-TextBox {
    param(
        [object]$Slide,
        [string]$Text,
        [double]$X,
        [double]$Y,
        [double]$W,
        [double]$H,
        [int]$Size = 18,
        [int]$Color = 0x27231F,
        [bool]$Bold = $false
    )
    $shape = $Slide.Shapes.AddTextbox(1, $X, $Y, $W, $H)
    $shape.TextFrame.TextRange.Text = $Text
    $shape.TextFrame.TextRange.Font.Name = $fontName
    $shape.TextFrame.TextRange.Font.Size = $Size
    $shape.TextFrame.TextRange.Font.Color.RGB = $Color
    $shape.TextFrame.TextRange.Font.Bold = if ($Bold) { -1 } else { 0 }
    $shape.TextFrame.WordWrap = -1
    return $shape
}

function Add-Header {
    param([object]$Slide, [string]$Title, [string]$Note)
    Add-TextBox -Slide $Slide -Text $Title -X 42 -Y 24 -W 870 -H 42 -Size 25 -Color $dark -Bold $true | Out-Null
    Add-TextBox -Slide $Slide -Text $Note -X 44 -Y 70 -W 865 -H 34 -Size 12 -Color $muted | Out-Null
    $line = $Slide.Shapes.AddLine(44, 106, 912, 106)
    $line.Line.ForeColor.RGB = 0xB8AFA4
    $line.Line.Weight = 1.3
}

function Add-Picture {
    param([object]$Slide, [string]$Path, [double]$X, [double]$Y, [double]$W, [double]$H)
    $pic = $Slide.Shapes.AddPicture($Path, $false, $true, $X, $Y, $W, $H)
    return $pic
}

function Add-BlankSlide {
    $slide = $presentation.Slides.Add($presentation.Slides.Count + 1, 12)
    $slide.FollowMasterBackground = $false
    $slide.Background.Fill.ForeColor.RGB = 0xFFFFFF
    return $slide
}

function Add-BulletSlide {
    param([string]$Title, [string]$Note, [string[]]$Bullets)
    $slide = Add-BlankSlide
    Add-Header -Slide $slide -Title $Title -Note $Note
    $bulletText = ($Bullets | ForEach-Object { "• $_" }) -join "`r"
    Add-TextBox -Slide $slide -Text $bulletText -X 90 -Y 150 -W 780 -H 300 -Size 22 -Color $dark | Out-Null
}

function Add-ImageSlide {
    param([string]$Title, [string]$Note, [string]$ImageName)
    $slide = Add-BlankSlide
    Add-Header -Slide $slide -Title $Title -Note $Note
    Add-Picture -Slide $slide -Path (Join-Path $AssetDir $ImageName) -X 54 -Y 120 -W 852 -H 380 | Out-Null
}

function Add-TwoImageSlide {
    param([string]$Title, [string]$Note, [string]$LeftImage, [string]$RightImage)
    $slide = Add-BlankSlide
    Add-Header -Slide $slide -Title $Title -Note $Note
    Add-Picture -Slide $slide -Path (Join-Path $AssetDir $LeftImage) -X 40 -Y 130 -W 440 -H 360 | Out-Null
    Add-Picture -Slide $slide -Path (Join-Path $AssetDir $RightImage) -X 505 -Y 130 -W 415 -H 360 | Out-Null
}

# 1. title
$slide = Add-BlankSlide
Add-TextBox -Slide $slide -Text "Wi-Fi CSI 기반 비접촉 환자 이상 이벤트 감지 시스템" -X 58 -Y 120 -W 850 -H 80 -Size 31 -Color $dark -Bold $true | Out-Null
Add-TextBox -Slide $slide -Text "ESP32-S3 + MATLAB 기반 CSI-only 캡스톤 데모" -X 62 -Y 212 -W 780 -H 38 -Size 20 -Color $teal -Bold $true | Out-Null
Add-TextBox -Slide $slide -Text "카메라 없이 Wi-Fi 신호 변화로 사람 존재, 움직임, 낙상 의심 이벤트 후보를 감지한다." -X 64 -Y 285 -W 810 -H 56 -Size 18 -Color $muted | Out-Null

Add-BulletSlide -Title "문제 정의" -Note "환자 모니터링에서 프라이버시와 착용 부담을 줄이는 것이 목표" -Bullets @(
    "카메라는 실내/병실 환경에서 프라이버시 부담이 큼",
    "웨어러블 센서는 착용 불편, 배터리, 착용 누락 문제가 있음",
    "본 프로젝트는 저가 ESP32 Wi-Fi CSI로 비영상 기반 모니터링 가능성을 확인",
    "의료 진단이 아니라 캡스톤 수준의 이상 이벤트 후보 감지 데모로 범위를 설정"
)

Add-BulletSlide -Title "핵심 아이디어: Wi-Fi CSI" -Note "사람의 존재와 움직임이 Wi-Fi 다중경로 변화로 나타난다는 점을 이용" -Bullets @(
    "사람이 실내에 있거나 움직이면 Wi-Fi 반사/산란 경로가 달라짐",
    "CSI는 subcarrier별 신호 변화 정보를 포함",
    "MATLAB에서 amplitude, phase, temporal difference energy, PCA 특징을 추출",
    "정지/움직임/낙상 의심 이벤트는 영상이 아니라 CSI 패턴 변화로 판단"
)

Add-ImageSlide -Title "시스템 구성" -Note "ESP32-S3에서 CSI를 수집하고 MATLAB에서 전처리, 특징 추출, 상태 판단을 수행" -ImageName "01_system_architecture_ppt.png"
Add-ImageSlide -Title "MATLAB CSI 처리 파이프라인" -Note "raw CSI를 complex CSI로 변환한 뒤 amplitude/phase와 sliding window feature를 계산" -ImageName "06_phone_csi_dataset_comparison.png"
Add-ImageSlide -Title "실제 수집 데이터 결과" -Note "스마트폰 핫스팟 환경에서 empty, static person, moving person 조건의 CSI 로그를 수집" -ImageName "02_phone_csi_summary_ppt.png"
Add-TwoImageSlide -Title "활동 분류 및 실시간 모델" -Note "소규모 실제 수집 데이터로 activity 분류 흐름과 실시간 추론 모델을 검증" -LeftImage "03_phone_motion_feature_scatter_ppt.png" -RightImage "08_phone_realtime_model_confusion.png"
Add-TwoImageSlide -Title "환자 이상 이벤트 후보 감지" -Note "낙상은 진단이 아니라 급격한 CSI 변화 기반의 의심 이벤트 후보로 표시" -LeftImage "04_emergency_feature_scatter_ppt.png" -RightImage "09_mock_emergency_fall_ai_confusion.png"
Add-ImageSlide -Title "실시간 대시보드 데모" -Note "serial CSI가 들어오면 현재 상태와 feature 변화를 확인할 수 있음" -ImageName "05_realtime_dashboard_preview_ppt.png"

Add-BulletSlide -Title "결론 및 한계" -Note "구현 가능성 중심의 캡스톤 데모이며, 임상 검증으로 과장하지 않음" -Bullets @(
    "구현 완료: ESP32 CSI 수집, MATLAB 전처리, feature 추출, 분류, 대시보드",
    "차별점: 고가 장비/카메라 없이 저비용 CSI-only 구조로 구현",
    "주의점: 낙상 진단이나 의료기기 수준 판정이 아니라 의심 이벤트 후보 감지",
    "향후 과제: 실제 환자 시나리오 데이터 수집, 환경별 threshold 보정, 모델 일반화 검증"
)

$presentation.SaveAs($OutFile)
$presentation.Close()
$ppt.Quit()

Write-Output "Saved PPT: $OutFile"
