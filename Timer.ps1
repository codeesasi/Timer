# ============================================================
#  Timer.ps1 - Focus Timer with Logout / Shutdown / Hypermode
#  Warm stopwatch-style UI with circular ring & tick marks
# ============================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ---- XAML ----
$xamlString = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Focus Timer" Height="700" Width="460"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanMinimize"
        Background="#0F0E13" Foreground="#F0F0F0" FontFamily="Segoe UI">

    <Window.Resources>
        <SolidColorBrush x:Key="AccentBrush" Color="#FF6B35"/>
        <SolidColorBrush x:Key="DangerBrush" Color="#FF1744"/>
        <SolidColorBrush x:Key="WarningBrush" Color="#FFAB00"/>
        <SolidColorBrush x:Key="SurfaceBrush" Color="#18171E"/>
        <SolidColorBrush x:Key="SurfaceLightBrush" Color="#201F28"/>
        <SolidColorBrush x:Key="TextBrush" Color="#F0F0F0"/>
        <SolidColorBrush x:Key="TextDimBrush" Color="#606068"/>
        <SolidColorBrush x:Key="RingTrackBrush" Color="#252330"/>
        <SolidColorBrush x:Key="BorderSubtle" Color="#2A2935"/>

        <!-- Pill Button -->
        <Style x:Key="PillBtn" TargetType="Button">
            <Setter Property="Background" Value="{StaticResource SurfaceBrush}"/>
            <Setter Property="Foreground" Value="{StaticResource TextBrush}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderSubtle}"/>
            <Setter Property="Padding" Value="20,12"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="22" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#222130"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#2E2D3C"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.3"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="AccentBtn" TargetType="Button" BasedOn="{StaticResource PillBtn}">
            <Setter Property="Background" Value="{StaticResource AccentBrush}"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="{StaticResource AccentBrush}"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="FontWeight" Value="Bold"/>
        </Style>

        <Style x:Key="DangerBtn" TargetType="Button" BasedOn="{StaticResource PillBtn}">
            <Setter Property="Background" Value="{StaticResource DangerBrush}"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="{StaticResource DangerBrush}"/>
        </Style>

        <Style x:Key="PresetBtn" TargetType="Button" BasedOn="{StaticResource PillBtn}">
            <Setter Property="MinWidth" Value="60"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="Padding" Value="16,8"/>
        </Style>

        <Style x:Key="ActionRadio" TargetType="RadioButton">
            <Setter Property="Foreground" Value="{StaticResource TextBrush}"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="Medium"/>
            <Setter Property="Margin" Value="0,0,20,0"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

        <Style x:Key="TimeBox" TargetType="TextBox">
            <Setter Property="Background" Value="#12111A"/>
            <Setter Property="Foreground" Value="{StaticResource AccentBrush}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderSubtle}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="26"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="TextAlignment" Value="Center"/>
            <Setter Property="Width" Value="64"/>
            <Setter Property="Height" Value="46"/>
            <Setter Property="MaxLength" Value="2"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="CaretBrush" Value="{StaticResource AccentBrush}"/>
        </Style>

        <!-- Flip Clock Styles -->
        <Style x:Key="FlipCard" TargetType="Border">
            <Setter Property="Background">
                <Setter.Value>
                    <LinearGradientBrush StartPoint="0.5,0" EndPoint="0.5,1">
                        <GradientStop Color="#2A2935" Offset="0"/>
                        <GradientStop Color="#18171E" Offset="1"/>
                    </LinearGradientBrush>
                </Setter.Value>
            </Setter>
            <Setter Property="BorderBrush" Value="#353440"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CornerRadius" Value="4"/>
            <Setter Property="Width" Value="32"/>
            <Setter Property="Height" Value="46"/>
            <Setter Property="Margin" Value="1"/>
            <Setter Property="Effect">
                <Setter.Value>
                    <DropShadowEffect Color="Black" BlurRadius="2" ShadowDepth="1" Opacity="0.5"/>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="FlipText" TargetType="TextBlock">
            <Setter Property="Foreground" Value="#F0F0F0"/>
            <Setter Property="FontSize" Value="28"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="HorizontalAlignment" Value="Center"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
            <Setter Property="FontFamily" Value="Consolas, Courier New, Monospace"/>
        </Style>

        <Style x:Key="FlipSep" TargetType="TextBlock">
            <Setter Property="Foreground" Value="#606068"/>
            <Setter Property="FontSize" Value="24"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="VerticalAlignment" Value="Center"/>
            <Setter Property="Margin" Value="2,0"/>
            <Setter Property="Text" Value=":"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Border Background="#0F0E13" Padding="28,14">
            <StackPanel>
                <!-- Title -->
                <TextBlock Text="FOCUS TIMER" FontSize="18" FontWeight="Bold"
                           Foreground="{StaticResource AccentBrush}"
                           HorizontalAlignment="Center" Margin="0,0,0,2"/>
                <TextBlock Text="Set your timer. Choose your action. Stay focused."
                           FontSize="10" Foreground="{StaticResource TextDimBrush}"
                           HorizontalAlignment="Center" Margin="0,0,0,12"/>

                <!-- Circular Ring Section -->
                <Grid Width="260" Height="260" HorizontalAlignment="Center" Margin="0,0,0,14">
                    <!-- Tick marks (generated in code) -->
                    <Canvas x:Name="tickCanvas" Width="260" Height="260"/>
                    <!-- Ring Track (background circle) -->
                    <Ellipse Width="220" Height="220" Stroke="#252330"
                             StrokeThickness="10" Fill="Transparent"/>
                    <!-- Ring Progress (orange-red gradient arc) -->
                    <Ellipse x:Name="progressRing" Width="220" Height="220"
                             StrokeThickness="10" Fill="Transparent"
                             StrokeDashCap="Round"
                             RenderTransformOrigin="0.5,0.5">
                        <Ellipse.Stroke>
                            <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                                <GradientStop Color="#FFB347" Offset="0"/>
                                <GradientStop Color="#FF4500" Offset="1"/>
                            </LinearGradientBrush>
                        </Ellipse.Stroke>
                        <Ellipse.RenderTransform>
                            <RotateTransform Angle="-90"/>
                        </Ellipse.RenderTransform>
                        <Ellipse.Effect>
                            <DropShadowEffect Color="#FF6B35" BlurRadius="18" ShadowDepth="0" Opacity="0.4"/>
                        </Ellipse.Effect>
                    </Ellipse>

                    <!-- Countdown + Status centered inside ring -->
                    <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                    <!-- Flip Clock Display -->
                    <Viewbox MaxWidth="190" Stretch="Uniform">
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center" HorizontalAlignment="Center">
                            <!-- Hours -->
                            <Border x:Name="cardH1" Style="{StaticResource FlipCard}" RenderTransformOrigin="0.5,0.5">
                                <Border.RenderTransform><ScaleTransform ScaleY="1"/></Border.RenderTransform>
                                <TextBlock x:Name="txtH1" Text="0" Style="{StaticResource FlipText}"/>
                            </Border>
                            <Border x:Name="cardH2" Style="{StaticResource FlipCard}" RenderTransformOrigin="0.5,0.5">
                                <Border.RenderTransform><ScaleTransform ScaleY="1"/></Border.RenderTransform>
                                <TextBlock x:Name="txtH2" Text="0" Style="{StaticResource FlipText}"/>
                            </Border>
                            
                            <TextBlock Style="{StaticResource FlipSep}"/>
                            
                            <!-- Minutes -->
                            <Border x:Name="cardM1" Style="{StaticResource FlipCard}" RenderTransformOrigin="0.5,0.5">
                                <Border.RenderTransform><ScaleTransform ScaleY="1"/></Border.RenderTransform>
                                <TextBlock x:Name="txtM1" Text="0" Style="{StaticResource FlipText}"/>
                            </Border>
                            <Border x:Name="cardM2" Style="{StaticResource FlipCard}" RenderTransformOrigin="0.5,0.5">
                                <Border.RenderTransform><ScaleTransform ScaleY="1"/></Border.RenderTransform>
                                <TextBlock x:Name="txtM2" Text="0" Style="{StaticResource FlipText}"/>
                            </Border>
                            
                            <TextBlock Style="{StaticResource FlipSep}"/>
                            
                            <!-- Seconds -->
                            <Border x:Name="cardS1" Style="{StaticResource FlipCard}" RenderTransformOrigin="0.5,0.5">
                                <Border.RenderTransform><ScaleTransform ScaleY="1"/></Border.RenderTransform>
                                <TextBlock x:Name="txtS1" Text="0" Style="{StaticResource FlipText}"/>
                            </Border>
                            <Border x:Name="cardS2" Style="{StaticResource FlipCard}" RenderTransformOrigin="0.5,0.5">
                                <Border.RenderTransform><ScaleTransform ScaleY="1"/></Border.RenderTransform>
                                <TextBlock x:Name="txtS2" Text="0" Style="{StaticResource FlipText}"/>
                            </Border>
                        </StackPanel>
                    </Viewbox>
                        <TextBlock x:Name="txtStatus" Text="Ready" FontSize="11"
                                   Foreground="{StaticResource TextDimBrush}"
                                   HorizontalAlignment="Center" Margin="0,4,0,0"/>
                    </StackPanel>
                </Grid>

                <!-- Set Time -->
                <TextBlock Text="SET TIME" FontSize="10" FontWeight="SemiBold"
                           Foreground="{StaticResource TextDimBrush}"
                           Margin="0,0,0,8" HorizontalAlignment="Center"/>

                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,6">
                    <StackPanel>
                        <TextBox x:Name="txtHours" Text="00" Style="{StaticResource TimeBox}"/>
                        <TextBlock Text="HRS" FontSize="8" Foreground="{StaticResource TextDimBrush}"
                                   HorizontalAlignment="Center" Margin="0,3,0,0"/>
                    </StackPanel>
                    <TextBlock Text=":" FontSize="26" FontWeight="Bold"
                               Foreground="{StaticResource TextDimBrush}"
                               VerticalAlignment="Top" Margin="8,8,8,0"/>
                    <StackPanel>
                        <TextBox x:Name="txtMinutes" Text="25" Style="{StaticResource TimeBox}"/>
                        <TextBlock Text="MIN" FontSize="8" Foreground="{StaticResource TextDimBrush}"
                                   HorizontalAlignment="Center" Margin="0,3,0,0"/>
                    </StackPanel>
                    <TextBlock Text=":" FontSize="26" FontWeight="Bold"
                               Foreground="{StaticResource TextDimBrush}"
                               VerticalAlignment="Top" Margin="8,8,8,0"/>
                    <StackPanel>
                        <TextBox x:Name="txtSeconds" Text="00" Style="{StaticResource TimeBox}"/>
                        <TextBlock Text="SEC" FontSize="8" Foreground="{StaticResource TextDimBrush}"
                                   HorizontalAlignment="Center" Margin="0,3,0,0"/>
                    </StackPanel>
                </StackPanel>

                <!-- Presets -->
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,8,0,14">
                    <Button x:Name="btnPreset15"  Content="15 min" Style="{StaticResource PresetBtn}" Margin="0,0,8,0"/>
                    <Button x:Name="btnPreset30"  Content="30 min" Style="{StaticResource PresetBtn}" Margin="0,0,8,0"/>
                    <Button x:Name="btnPreset60"  Content="1 hr"   Style="{StaticResource PresetBtn}" Margin="0,0,8,0"/>
                    <Button x:Name="btnPreset120" Content="2 hr"   Style="{StaticResource PresetBtn}"/>
                </StackPanel>

                <Border Height="1" Background="{StaticResource BorderSubtle}" Margin="0,0,0,12"/>

                <!-- Action Selection -->
                <TextBlock Text="ACTION ON COMPLETE" FontSize="10" FontWeight="SemiBold"
                           Foreground="{StaticResource TextDimBrush}"
                           Margin="0,0,0,10" HorizontalAlignment="Center"/>

                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,16">
                    <RadioButton x:Name="rbLogout"    Content="Logout"    Style="{StaticResource ActionRadio}" GroupName="Act"/>
                    <RadioButton x:Name="rbShutdown"  Content="Shutdown"  Style="{StaticResource ActionRadio}" GroupName="Act"/>
                    <RadioButton x:Name="rbHypermode" Content="Hypermode" Style="{StaticResource ActionRadio}" GroupName="Act" IsChecked="True"/>
                </StackPanel>

                <!-- Control Buttons -->
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                    <Button x:Name="btnStart" Content="START"  Style="{StaticResource AccentBtn}" Width="140" Margin="0,0,10,0"/>
                    <Button x:Name="btnPause" Content="PAUSE"  Style="{StaticResource PillBtn}"   Width="110" Margin="0,0,10,0" IsEnabled="False"/>
                    <Button x:Name="btnReset" Content="RESET"  Style="{StaticResource DangerBtn}" Width="110" IsEnabled="False"/>
                </StackPanel>
            </StackPanel>
        </Border>

        <!-- Hypermode Overlay -->
        <Border x:Name="hypermodeOverlay" Visibility="Collapsed" Background="#F0080812" Panel.ZIndex="100">
            <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                <TextBlock Text="H Y P E R M O D E" FontSize="36" FontWeight="ExtraBold"
                           Foreground="{StaticResource AccentBrush}" HorizontalAlignment="Center">
                    <TextBlock.Effect>
                        <DropShadowEffect Color="#FF6B35" BlurRadius="30" ShadowDepth="0" Opacity="0.6"/>
                    </TextBlock.Effect>
                </TextBlock>
                <TextBlock Text="FOCUS LOCK ACTIVE" FontSize="13"
                           Foreground="{StaticResource WarningBrush}"
                           HorizontalAlignment="Center" Margin="0,8,0,30"/>
                <TextBlock x:Name="txtHyperCountdown" Text="00 : 00 : 00"
                           FontSize="68" FontWeight="Bold" Foreground="White"
                           HorizontalAlignment="Center" FontFamily="Segoe UI">
                    <TextBlock.Effect>
                        <DropShadowEffect Color="#FF6B35" BlurRadius="25" ShadowDepth="0" Opacity="0.5"/>
                    </TextBlock.Effect>
                </TextBlock>
                <TextBlock x:Name="txtMotivation"
                           Text="Discipline is the bridge between goals and accomplishment."
                           FontSize="14" FontStyle="Italic"
                           Foreground="{StaticResource TextDimBrush}"
                           HorizontalAlignment="Center" Margin="0,30,0,0"
                           TextWrapping="Wrap" TextAlignment="Center" MaxWidth="400"/>
                <Button x:Name="btnExitHyper" Content="EXIT HYPERMODE"
                        Style="{StaticResource DangerBtn}"
                        Margin="0,40,0,0" HorizontalAlignment="Center"
                        FontSize="12" Visibility="Collapsed"/>
            </StackPanel>
        </Border>

        <!-- Warning Overlay -->
        <Border x:Name="warningOverlay" Visibility="Collapsed" Background="#F0080812" Panel.ZIndex="200">
            <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                <TextBlock x:Name="txtWarningTitle" Text="TIMER COMPLETE!"
                           FontSize="28" FontWeight="Bold"
                           Foreground="{StaticResource WarningBrush}" HorizontalAlignment="Center"/>
                <TextBlock x:Name="txtWarningAction" Text="Logging out in..."
                           FontSize="16" Foreground="{StaticResource TextBrush}"
                           HorizontalAlignment="Center" Margin="0,10,0,20"/>
                <TextBlock x:Name="txtWarningCountdown" Text="5"
                           FontSize="80" FontWeight="ExtraBold"
                           Foreground="{StaticResource DangerBrush}" HorizontalAlignment="Center"/>
                <Button x:Name="btnCancelAction" Content="CANCEL"
                        Style="{StaticResource DangerBtn}"
                        Margin="0,30,0,0" HorizontalAlignment="Center"
                        FontSize="14" Width="160"/>
            </StackPanel>
        </Border>
    </Grid>
</Window>
"@

# ---- Load Window ----
try {
    [xml]$xaml = $xamlString
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    [System.Windows.MessageBox]::Show("Failed to load UI: $($_.Exception.Message)`n`n$($_.Exception.InnerException.Message)", "Error")
    exit 1
}

if ($null -eq $window) {
    [System.Windows.MessageBox]::Show("Window failed to load (null).", "Error")
    exit 1
}

# ---- Set Window Icon ----
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = [System.AppDomain]::CurrentDomain.BaseDirectory
}
$iconPath = Join-Path $scriptDir "icon.ico"

if (Test-Path $iconPath) {
    try {
        $window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create([Uri]::new($iconPath))
    } catch {
        # Fail silently or log if needed
    }
}

# ---- Find Controls ----
$script:cardH1            = $window.FindName("cardH1")
$script:cardH2            = $window.FindName("cardH2")
$script:cardM1            = $window.FindName("cardM1")
$script:cardM2            = $window.FindName("cardM2")
$script:cardS1            = $window.FindName("cardS1")
$script:cardS2            = $window.FindName("cardS2")

$script:txtH1             = $window.FindName("txtH1")
$script:txtH2             = $window.FindName("txtH2")
$script:txtM1             = $window.FindName("txtM1")
$script:txtM2             = $window.FindName("txtM2")
$script:txtS1             = $window.FindName("txtS1")
$script:txtS2             = $window.FindName("txtS2")
$script:txtStatus           = $window.FindName("txtStatus")
$script:progressRing        = $window.FindName("progressRing")
$script:tickCanvas          = $window.FindName("tickCanvas")
$script:txtHours            = $window.FindName("txtHours")
$script:txtMinutes          = $window.FindName("txtMinutes")
$script:txtSeconds          = $window.FindName("txtSeconds")
$script:btnPreset15         = $window.FindName("btnPreset15")
$script:btnPreset30         = $window.FindName("btnPreset30")
$script:btnPreset60         = $window.FindName("btnPreset60")
$script:btnPreset120        = $window.FindName("btnPreset120")
$script:rbLogout            = $window.FindName("rbLogout")
$script:rbShutdown          = $window.FindName("rbShutdown")
$script:rbHypermode         = $window.FindName("rbHypermode")
$script:btnStart            = $window.FindName("btnStart")
$script:btnPause            = $window.FindName("btnPause")
$script:btnReset            = $window.FindName("btnReset")
$script:hypermodeOverlay    = $window.FindName("hypermodeOverlay")
$script:txtHyperCountdown   = $window.FindName("txtHyperCountdown")
$script:txtMotivation       = $window.FindName("txtMotivation")
$script:btnExitHyper        = $window.FindName("btnExitHyper")
$script:warningOverlay      = $window.FindName("warningOverlay")
$script:txtWarningTitle     = $window.FindName("txtWarningTitle")
$script:txtWarningAction    = $window.FindName("txtWarningAction")
$script:txtWarningCountdown = $window.FindName("txtWarningCountdown")
$script:btnCancelAction     = $window.FindName("btnCancelAction")

# ---- State ----
$script:totalSeconds      = 0
$script:remainingSeconds  = 0
$script:isRunning         = $false
$script:isPaused          = $false
$script:warningCount      = 5
$script:isWarningActive   = $false
$script:isHypermodeActive = $false

# ---- Ring Constants ----
# Ellipse is 220x220 with StrokeThickness 10 inside a 260x260 Grid
# Stroke center radius = (220 - 10) / 2 = 105
# Grid center = 130
$script:gridCenter          = 130.0
$script:ringStrokeCenterR   = 105.0
$script:ringStroke          = 10.0
$script:ringCircumference   = 2.0 * [math]::PI * $script:ringStrokeCenterR
$script:ringDashTotal       = $script:ringCircumference / $script:ringStroke

$motivationalQuotes = @(
    'Discipline is the bridge between goals and accomplishment. - Jim Rohn',
    'The only way to do great work is to love what you do. - Steve Jobs',
    'It does not matter how slowly you go as long as you do not stop. - Confucius',
    'Your future is created by what you do today, not tomorrow. - Robert Kiyosaki',
    'Success is not final, failure is not fatal: courage to continue counts. - Churchill',
    'The pain you feel today will be the strength you feel tomorrow.',
    'Fall seven times, stand up eight. - Japanese Proverb',
    'Be stronger than your strongest excuse.',
    'You do not have to be extreme, just consistent.',
    'One day or day one. You decide.'
)

# ---- Generate Tick Marks ----
$tickCenter  = 130.0
$tickOuterR  = 126.0
$tickInnerMajor = 114.0
$tickInnerMinor = 120.0

# Store tick references for color animation
$script:tickLines = @()
$script:tickDimColors = @()
$script:tickLitBrush = New-Object System.Windows.Media.SolidColorBrush (
    [System.Windows.Media.Color]::FromRgb(255, 107, 53))  # #FF6B35 orange

for ($i = 0; $i -lt 60; $i++) {
    [double]$angleDeg = $i * 6.0
    [double]$angleRad = $angleDeg * [math]::PI / 180.0
    $isMajor = ($i % 5 -eq 0)
    $innerR  = if ($isMajor) { $tickInnerMajor } else { $tickInnerMinor }

    $x1 = $tickCenter + $tickOuterR * [math]::Sin($angleRad)
    $y1 = $tickCenter - $tickOuterR * [math]::Cos($angleRad)
    $x2 = $tickCenter + $innerR    * [math]::Sin($angleRad)
    $y2 = $tickCenter - $innerR    * [math]::Cos($angleRad)

    $line = New-Object System.Windows.Shapes.Line
    $line.X1 = $x1; $line.Y1 = $y1
    $line.X2 = $x2; $line.Y2 = $y2
    $line.StrokeThickness = if ($isMajor) { 3.0 } else { 2.0 }

    if ($isMajor) {
        $dimBrush = New-Object System.Windows.Media.SolidColorBrush (
            [System.Windows.Media.Color]::FromRgb(120, 118, 130))
    } else {
        $dimBrush = New-Object System.Windows.Media.SolidColorBrush (
            [System.Windows.Media.Color]::FromRgb(60, 58, 70))
    }
    $line.Stroke = $dimBrush

    $script:tickCanvas.Children.Add($line) | Out-Null
    $script:tickLines += $line
    $script:tickDimColors += $dimBrush
}

# ---- Helpers ----
function Format-Time([int]$secs) {
    [int]$h = [math]::Floor($secs / 3600)
    [int]$m = [math]::Floor(($secs % 3600) / 60)
    [int]$s = $secs % 60
    return "{0:D2} : {1:D2} : {2:D2}" -f $h, $m, $s
}

function Set-TimerInputs([int]$h, [int]$m, [int]$s) {
    $script:txtHours.Text   = "{0:D2}" -f $h
    $script:txtMinutes.Text = "{0:D2}" -f $m
    $script:txtSeconds.Text = "{0:D2}" -f $s
}

function Get-TotalSecondsFromInputs {
    $h = 0; $m = 0; $s = 0
    [int]::TryParse($script:txtHours.Text,   [ref]$h) | Out-Null
    [int]::TryParse($script:txtMinutes.Text, [ref]$m) | Out-Null
    [int]::TryParse($script:txtSeconds.Text, [ref]$s) | Out-Null
    return ($h * 3600) + ($m * 60) + $s
}

function Update-Ring {
    if ($script:totalSeconds -gt 0) {
        [double]$pct  = $script:remainingSeconds / $script:totalSeconds
        [double]$fill = $pct * $script:ringDashTotal
        if ($fill -lt 0) { $fill = 0 }
        $dc = New-Object System.Windows.Media.DoubleCollection
        $dc.Add($fill)
        $dc.Add($script:ringDashTotal)
        $script:progressRing.StrokeDashArray = $dc

        # Light up ticks past the arc endpoint
        [double]$arcEndDeg = $pct * 360.0
        for ($i = 0; $i -lt 60; $i++) {
            [double]$tickAngle = $i * 6.0
            if ($tickAngle -gt $arcEndDeg) {
                $script:tickLines[$i].Stroke = $script:tickLitBrush
            } else {
                $script:tickLines[$i].Stroke = $script:tickDimColors[$i]
            }
        }
    }
}

function Reset-Ring {
    $script:progressRing.StrokeDashArray = New-Object System.Windows.Media.DoubleCollection
    # Reset all ticks to dim
    for ($i = 0; $i -lt 60; $i++) {
        $script:tickLines[$i].Stroke = $script:tickDimColors[$i]
    }
}


function Invoke-Flip($border, $textBlock, $newVal) {
    if ($textBlock.Text -eq $newVal) { return }
    
    # Create animation ScaleY 1 -> 0
    $daShrink = New-Object System.Windows.Media.Animation.DoubleAnimation
    $daShrink.From = 1.0; $daShrink.To = 0.0
    $daShrink.Duration = [TimeSpan]::FromMilliseconds(150)
    
    # Create animation ScaleY 0 -> 1
    $daGrow = New-Object System.Windows.Media.Animation.DoubleAnimation
    $daGrow.From = 0.0; $daGrow.To = 1.0
    $daGrow.Duration = [TimeSpan]::FromMilliseconds(150)
    
    # Chain them
    $daShrink.Add_Completed({
        $textBlock.Text = $newVal
        $border.RenderTransform.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleYProperty, $daGrow)
    }.GetNewClosure())
    
    $border.RenderTransform.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleYProperty, $daShrink)
}

function Update-Display {
    # Calculate digits
    [int]$h = [math]::Floor($script:remainingSeconds / 3600)
    [int]$m = [math]::Floor(($script:remainingSeconds % 3600) / 60)
    [int]$s = $script:remainingSeconds % 60

    $hStr = "{0:D2}" -f $h
    $mStr = "{0:D2}" -f $m
    $sStr = "{0:D2}" -f $s

    # Animate changes
    Invoke-Flip $script:cardH1 $script:txtH1 $hStr[0]
    Invoke-Flip $script:cardH2 $script:txtH2 $hStr[1]
    Invoke-Flip $script:cardM1 $script:txtM1 $mStr[0]
    Invoke-Flip $script:cardM2 $script:txtM2 $mStr[1]
    Invoke-Flip $script:cardS1 $script:txtS1 $sStr[0]
    Invoke-Flip $script:cardS2 $script:txtS2 $sStr[1]

    Update-Ring
    if ($script:isHypermodeActive) {
        $script:txtHyperCountdown.Text = Format-Time $script:remainingSeconds
    }
}

function Set-UIState([string]$state) {
    switch ($state) {
        "ready" {
            $script:btnStart.IsEnabled   = $true
            $script:btnPause.IsEnabled   = $false
            $script:btnReset.IsEnabled   = $false
            $script:btnStart.Content     = "START"
            $script:txtStatus.Text       = "Ready"
            $script:txtHours.IsEnabled   = $true
            $script:txtMinutes.IsEnabled = $true
            $script:txtSeconds.IsEnabled = $true
        }
        "running" {
            $script:btnStart.IsEnabled   = $false
            $script:btnPause.IsEnabled   = $true
            $script:btnReset.IsEnabled   = $true
            $script:txtStatus.Text       = "Running..."
            $script:txtHours.IsEnabled   = $false
            $script:txtMinutes.IsEnabled = $false
            $script:txtSeconds.IsEnabled = $false
        }
        "paused" {
            $script:btnStart.IsEnabled   = $false
            $script:btnPause.IsEnabled   = $true
            $script:btnReset.IsEnabled   = $true
            $script:btnPause.Content     = "RESUME"
            $script:txtStatus.Text       = "Paused"
        }
    }
}

function Enter-Hypermode {
    $script:isHypermodeActive = $true
    $window.WindowStyle = [System.Windows.WindowStyle]::None
    $window.WindowState = [System.Windows.WindowState]::Maximized
    $window.Topmost     = $true
    $script:hypermodeOverlay.Visibility = [System.Windows.Visibility]::Visible
    $script:txtHyperCountdown.Text = Format-Time $script:remainingSeconds
    $script:txtMotivation.Text = $motivationalQuotes | Get-Random
}

function Exit-Hypermode {
    $script:isHypermodeActive = $false
    $window.WindowStyle = [System.Windows.WindowStyle]::SingleBorderWindow
    $window.WindowState = [System.Windows.WindowState]::Normal
    $window.Topmost     = $false
    $script:hypermodeOverlay.Visibility = [System.Windows.Visibility]::Collapsed
}

function Start-WarningCountdown {
    $script:isWarningActive = $true
    $script:warningCount = 5
    if ($script:rbLogout.IsChecked)   { $script:txtWarningAction.Text = "Logging out in..." }
    if ($script:rbShutdown.IsChecked) { $script:txtWarningAction.Text = "Shutting down in..." }
    $script:txtWarningCountdown.Text = "5"
    $script:warningOverlay.Visibility = [System.Windows.Visibility]::Visible
    [System.Console]::Beep(800, 300)
}

function Execute-FinalAction {
    if ($script:rbLogout.IsChecked) {
        Start-Process "shutdown.exe" -ArgumentList "/l", "/f" -NoNewWindow
    }
    elseif ($script:rbShutdown.IsChecked) {
        Start-Process "shutdown.exe" -ArgumentList "/s", "/f", "/t", "0" -NoNewWindow
    }
}

function Reset-Timer {
    $script:isRunning        = $false
    $script:isPaused         = $false
    $script:remainingSeconds = 0
    $script:totalSeconds     = 0
    $script:isWarningActive  = $false
    $script:mainTimer.Stop()
    $script:warningTimer.Stop()
    $script:warningOverlay.Visibility = [System.Windows.Visibility]::Collapsed
    if ($script:isHypermodeActive) { Exit-Hypermode }
    $script:txtH1.Text = "0"; $script:txtH2.Text = "0"
    $script:txtM1.Text = "0"; $script:txtM2.Text = "0"
    $script:txtS1.Text = "0"; $script:txtS2.Text = "0"
    Reset-Ring
    $script:btnPause.Content   = "PAUSE"
    Set-UIState "ready"
}

# ---- Timers ----
$script:mainTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:mainTimer.Interval = [TimeSpan]::FromSeconds(1)
$script:mainTimer.Add_Tick({
    if ($script:isRunning -and -not $script:isPaused) {
        $script:remainingSeconds--
        Update-Display

        if ($script:isHypermodeActive -and ($script:remainingSeconds % 30 -eq 0) -and $script:remainingSeconds -gt 0) {
            $script:txtMotivation.Text = $motivationalQuotes | Get-Random
        }

        if ($script:remainingSeconds -le 0) {
            $script:mainTimer.Stop()
            $script:isRunning = $false
            [System.Console]::Beep(1000, 200)
            [System.Console]::Beep(1200, 200)
            [System.Console]::Beep(1400, 400)

            if ($script:isHypermodeActive) {
                Exit-Hypermode
                $script:txtStatus.Text = "Hypermode session complete!"
                Set-UIState "ready"
            } else {
                Start-WarningCountdown
            }
        }
    }
})

$script:warningTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:warningTimer.Interval = [TimeSpan]::FromSeconds(1)
$script:warningTimer.Add_Tick({
    if ($script:isWarningActive) {
        $script:warningCount--
        $script:txtWarningCountdown.Text = $script:warningCount.ToString()
        [System.Console]::Beep(600 + (100 * (5 - $script:warningCount)), 150)
        if ($script:warningCount -le 0) {
            $script:warningTimer.Stop()
            $script:isWarningActive = $false
            $script:warningOverlay.Visibility = [System.Windows.Visibility]::Collapsed
            Execute-FinalAction
        }
    }
})

# ---- Events ----
$script:btnPreset15.Add_Click({  Set-TimerInputs 0 15 0 })
$script:btnPreset30.Add_Click({  Set-TimerInputs 0 30 0 })
$script:btnPreset60.Add_Click({  Set-TimerInputs 1  0 0 })
$script:btnPreset120.Add_Click({ Set-TimerInputs 2  0 0 })

$script:btnStart.Add_Click({
    $total = Get-TotalSecondsFromInputs
    if ($total -le 0) {
        [System.Windows.MessageBox]::Show("Please set a time greater than 0.", "Invalid Time",
            [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
        return
    }
    $script:totalSeconds     = $total
    $script:remainingSeconds = $total
    $script:isRunning        = $true
    $script:isPaused         = $false
    Update-Display
    Set-UIState "running"
    if ($script:rbHypermode.IsChecked) { Enter-Hypermode }
    $script:mainTimer.Start()
})

$script:btnPause.Add_Click({
    if ($script:isPaused) {
        $script:isPaused  = $false
        $script:btnPause.Content = "PAUSE"
        $script:txtStatus.Text   = "Running..."
        $script:mainTimer.Start()
    } else {
        $script:isPaused  = $true
        $script:btnPause.Content = "RESUME"
        $script:txtStatus.Text   = "Paused"
        $script:mainTimer.Stop()
    }
})

$script:btnReset.Add_Click({ Reset-Timer })

$script:btnCancelAction.Add_Click({
    $script:warningTimer.Stop()
    $script:isWarningActive = $false
    $script:warningOverlay.Visibility = [System.Windows.Visibility]::Collapsed
    $script:txtStatus.Text = "Action cancelled"
    Set-UIState "ready"
})

$script:btnExitHyper.Add_Click({
    Exit-Hypermode
    Reset-Timer
})

$window.Add_Closing({
    param($s, $e)
    if ($script:isHypermodeActive) {
        $r = [System.Windows.MessageBox]::Show(
            "Hypermode is active! Are you sure you want to exit?",
            "Hypermode Active",
            [System.Windows.MessageBoxButton]::YesNo,
            [System.Windows.MessageBoxImage]::Warning)
        if ($r -ne [System.Windows.MessageBoxResult]::Yes) { $e.Cancel = $true }
    }
    elseif ($script:isRunning) {
        $r = [System.Windows.MessageBox]::Show(
            "Timer is still running. Are you sure you want to exit?",
            "Timer Active",
            [System.Windows.MessageBoxButton]::YesNo,
            [System.Windows.MessageBoxImage]::Question)
        if ($r -ne [System.Windows.MessageBoxResult]::Yes) { $e.Cancel = $true }
    }
})

$script:warningOverlay.Add_IsVisibleChanged({
    if ($script:warningOverlay.Visibility -eq [System.Windows.Visibility]::Visible) {
        $script:warningTimer.Start()
    }
})

$numericFilter = {
    param($sender, $e)
    if (-not ($e.Text -match '^\d$')) { $e.Handled = $true }
}
$script:txtHours.Add_PreviewTextInput($numericFilter)
$script:txtMinutes.Add_PreviewTextInput($numericFilter)
$script:txtSeconds.Add_PreviewTextInput($numericFilter)

# ---- Launch ----
$window.ShowDialog() | Out-Null
