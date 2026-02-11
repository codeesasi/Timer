Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$xamlString = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Focus Timer" Height="640" Width="460"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanMinimize"
        Background="#0D0D0D" Foreground="#E0E0E0" FontFamily="Segoe UI">
    <Window.Resources>
        <SolidColorBrush x:Key="AccentBrush" Color="#00E5FF"/>
        <SolidColorBrush x:Key="DangerBrush" Color="#FF1744"/>
        <SolidColorBrush x:Key="WarningBrush" Color="#FFAB00"/>
        <SolidColorBrush x:Key="SurfaceBrush" Color="#1A1A2E"/>
        <SolidColorBrush x:Key="SurfaceLightBrush" Color="#16213E"/>
        <SolidColorBrush x:Key="TextBrush" Color="#E0E0E0"/>
        <SolidColorBrush x:Key="TextDimBrush" Color="#757575"/>
    </Window.Resources>
    <Grid>
        <TextBlock Text="HELLO WORLD" FontSize="32" Foreground="{StaticResource AccentBrush}"
                   HorizontalAlignment="Center" VerticalAlignment="Center"/>
    </Grid>
</Window>
"@

try {
    [xml]$xaml = $xamlString
    Write-Host "XML parsed OK"
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)
    Write-Host ("Window loaded: " + ($null -ne $window))
    if ($window) {
        $window.ShowDialog() | Out-Null
    }
} catch {
    Write-Host ("ERROR: " + $_.Exception.Message)
    Write-Host ("INNER: " + $_.Exception.InnerException.Message)
}
