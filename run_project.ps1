# VendorFlow Start Script
$PROJECT_ROOT = $PSScriptRoot
$TOMCAT_HOME = "C:\Users\Tanmay Mahajan\vendorFlow\apache-tomcat-9.0.117"

$SOURCES_FILE = "$PROJECT_ROOT\sources.txt"
$CLASSES_PATH = "$PROJECT_ROOT\WebContent\WEB-INF\classes"
$LIB_PATH     = "$PROJECT_ROOT\WebContent\WEB-INF\lib"
$TOMCAT_LIB   = "$TOMCAT_HOME\lib"

# Ensure classes directory exists
if (!(Test-Path $CLASSES_PATH)) { New-Item -ItemType Directory -Path $CLASSES_PATH }

# Dynamically generate sources.txt (Internal to project)
Write-Host "Syncing source file list..." -ForegroundColor Gray
Get-ChildItem -Path "$PROJECT_ROOT\src" -Filter *.java -Recurse | ForEach-Object { "`"$($_.FullName)`"" } | Out-File -FilePath $SOURCES_FILE -Encoding utf8

Write-Host "Compiling VendorFlow..." -ForegroundColor Cyan

# Define classpath
$CP = "`"$TOMCAT_LIB\*`";`"$LIB_PATH\*`""
$ARG_LIST = @("-d", "`"$CLASSES_PATH`"", "-cp", $CP, "`"@$SOURCES_FILE`"")

# Run javac
& javac @ARG_LIST

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation successful!" -ForegroundColor Green
    Write-Host "Starting Tomcat..." -ForegroundColor Cyan
    $env:CATALINA_HOME = $TOMCAT_HOME
    $env:JAVA_HOME = "C:\Program Files\Java\jdk-23"
    & "$TOMCAT_HOME\bin\startup.bat"
    Write-Host "Application available at http://localhost:8080/VendorFlow" -ForegroundColor Yellow
} else {
    Write-Host "Compilation failed. Check errors above." -ForegroundColor Red
}
