# VendorFlow Start Script
$PROJECT_ROOT = $PSScriptRoot
$TOMCAT_HOME = "C:\Users\Tanmay Mahajan\vendorFlow\apache-tomcat-9.0.117"

$SOURCES_FILE = "$PROJECT_ROOT\sources.txt"
$CLASSES_PATH = "$PROJECT_ROOT\WebContent\WEB-INF\classes"
$LIB_PATH     = "$PROJECT_ROOT\WebContent\WEB-INF\lib"
$TOMCAT_LIB   = "$TOMCAT_HOME\lib"
$DEPLOY_PATH  = "$TOMCAT_HOME\webapps\VendorFlow"

# Ensure classes directory exists
if (!(Test-Path $CLASSES_PATH)) { New-Item -ItemType Directory -Path $CLASSES_PATH }

Write-Host "Syncing web content to Tomcat..." -ForegroundColor Gray
if (!(Test-Path $DEPLOY_PATH)) { New-Item -ItemType Directory -Path $DEPLOY_PATH | Out-Null }
Copy-Item -Path "$PROJECT_ROOT\WebContent\*" -Destination $DEPLOY_PATH -Recurse -Force
Copy-Item -Path "$PROJECT_ROOT\WebContent\WEB-INF\classes\*" -Destination "$DEPLOY_PATH\WEB-INF\classes" -Recurse -Force -ErrorAction SilentlyContinue

# Collect Java source files
Write-Host "Syncing source file list..." -ForegroundColor Gray
$SOURCE_FILES = Get-ChildItem -Path "$PROJECT_ROOT\src" -Filter *.java -Recurse | ForEach-Object { $_.FullName }

Write-Host "Compiling VendorFlow..." -ForegroundColor Cyan

# Define classpath
$CP = "$TOMCAT_LIB\*;$LIB_PATH\*"
$ARG_LIST = @("-d", $CLASSES_PATH, "-cp", $CP) + $SOURCE_FILES

# Run javac
& javac @ARG_LIST

if ($LASTEXITCODE -eq 0) {
    Write-Host "Updating deployed classes..." -ForegroundColor Gray
    if (!(Test-Path "$DEPLOY_PATH\WEB-INF\classes")) { New-Item -ItemType Directory -Path "$DEPLOY_PATH\WEB-INF\classes" -Force | Out-Null }
    Copy-Item -Path "$CLASSES_PATH\*" -Destination "$DEPLOY_PATH\WEB-INF\classes" -Recurse -Force
    Write-Host "Compilation successful!" -ForegroundColor Green
    Write-Host "Starting Tomcat..." -ForegroundColor Cyan
    $env:CATALINA_HOME = $TOMCAT_HOME
    $env:JAVA_HOME = "C:\Program Files\Java\jdk-23"
    & "$TOMCAT_HOME\bin\startup.bat"
    Write-Host "Application available at http://localhost:8080/VendorFlow" -ForegroundColor Yellow
} else {
    Write-Host "Compilation failed. Check errors above." -ForegroundColor Red
}
