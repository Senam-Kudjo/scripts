## A WINDOWS POWERSHELL SCRIPT TO MOVE APPLICATION LOGS ON WINDOWS TO AN S3 BUCKET IN AWS THEN DELETE THE LOG FILES THAT WERE DELETED
## First a folder called the value of $BasePrefix is created within the applications-backup-logs bucket  
## then in the folder another folder is created called the value of $CurrentYearMonth (this is the year and month in which the script is executed)  so we have this now as the path
## omce the  $CurrentYearMonth is created the log files are all uploaded to that directory
## once the upload has been done, the $MaxOldFilesToDelete kicks in to delete the specified number of oldest available files in the logs.
## thats it


# ============================
# === AWS Credentials
# ============================
$env:AWS_ACCESS_KEY_ID = ""    # insert access key ID here
$env:AWS_SECRET_ACCESS_KEY = ""   # insert secret access key here
$env:AWS_DEFAULT_REGION = ""   # change to your region, e.g. eu-west-1

# ============================
# === Configuration Variables
# ============================
$LogDirectory         = "C:\CouponService\logs"        # change to path of folder containing log files
$S3BucketName         = "applications-backup-logs"
$FileExtension        = "*.log"
$MaxOldFilesToDelete  = 1           ### the number of log files to delete starting with the oldest file available in the $LogDirectory directory

# === Build the prefix dynamically ===
$CurrentYearMonth = (Get-Date -Format "yyyy-MM")     # e.g., "2025-10"
$BasePrefix = "fundgate"                             # Existing prefix
$S3BucketPrefix = "$BasePrefix/$CurrentYearMonth"     # Final S3 path prefix

$Timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")

Write-Host "[$(Get-Date)] Starting log upload and cleanup..."
Write-Host "S3 Prefix for this run: $S3BucketPrefix"

# ============================
# === Check Log Directory
# ============================
if (-Not (Test-Path -Path $LogDirectory)) {
    Write-Error "Log directory does not exist: $LogDirectory"
    exit 1
}

$LogFiles = Get-ChildItem -Path $LogDirectory -Filter $FileExtension -File
if ($LogFiles.Count -eq 0) {
    Write-Host "No log files found in $LogDirectory"
    exit 0
}

# ============================
# === Upload to S3
# ============================
foreach ($File in $LogFiles) {
    $S3Key = "$S3BucketPrefix/$($File.Name)"
    aws s3 cp "$($File.FullName)" "s3://$S3BucketName/$S3Key"

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to upload $($File.Name) to S3."
        exit 1
    } else {
        Write-Host "Uploaded: $($File.Name) -> s3://$S3BucketName/$S3Key"
    }
}

# ============================
# === Delete Oldest 20 Files
# ============================
$OldestFiles = $LogFiles | Sort-Object LastWriteTime | Select-Object -First $MaxOldFilesToDelete

if ($OldestFiles.Count -gt 0) {
    Write-Host "Deleting $($OldestFiles.Count) oldest file(s)..."
    foreach ($OldFile in $OldestFiles) {
        Remove-Item -Path $OldFile.FullName -Force
        Write-Host "Deleted: $($OldFile.Name)"
    }
} else {
    Write-Host "No old files to delete."
}

Write-Host "[$(Get-Date)] Script completed successfully."
