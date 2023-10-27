<#

Summary: The following script runs pg_dump, gzips the dump, and then uploads to an s3 bucket.

Initially I used the > operator to pipe dump to file. This caused some issues with encoding. Therefore,

I used -f (file location) parameter instead.

https://dba.stackexchange.com/questions/44019/pg-dump-9-2-x-command-does-not-work-with-pg-dump-9-2-3

#>

#Password for svc_backup is in pgpass
$env:PGPASSFILE ='path\to\pgpass.conf'
$pguser = 'svc_backup'

# Setup alias for 7zip for easy gziping

$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"

Set-Alias Compress-7Zip $7ZipPath

# Find details here regarding 7zip alias work https://www.delftstack.com/howto/powershell/powershell-7zip/

# Change working directory to where pg_dump is located

cd "path\to\pgdump.exe"

#Array for Database Servers and Databases
$serverlist= @(
@{
hostname = ""
databases = @(
""
)

}

)

#The actual work is done here

foreach ($server in $serverlistQAfinal) {

foreach ($database in $server.databases){

#write logging, in case we automate this in some task scheduler

Start-Transcript "path\to\logs\$("qa"+$date+$server.hostname).log" -Append

Write-Host "Running backup for $database"

#Set dump location to X drive

$dumpfile = "path\to\dumps\$($database).dump"




#Check if file is already there, if so delete.

if(Test-Path $dumpfile){

Remove-Item $dumpfile

Write-Host "$dumpfile removed"

}else{

Write-Host "$dumpfile does not exist. Proceeding"

}

#Execute pg_dump with parameters

##.\pg_dump.exe -h $server.hostname -U $pguser -F c -f $dumpfile $database

.\pg_dumpall.exe -h $server.hostname -U $pguser -f $dumpfile --no-role-passwords --exclude-database="rdsadmin" --exclude-database="postgres" --database=$database

#Variables for 7zip

$Source = $dumpfile



#Check if file is already there, if so delete

$Destination = "path\to\gzips\$($database).gz"

if(Test-Path $Destination){

Remove-Item $Destination

Write-Host "$Destination removed"

}else{

Write-Host "$Destination does not exist. Proceeding"

}

#Compress to gzip at highest compression

Compress-7zip a -mx=5 $Destination $Source

Stop-Transcript

}

}

#Upload to s3 bucket
aws s3 cp path\to\gzips\ s3://yourbuckethere--recursive