#Requires -RunAsAdministrator
$ErrorActionPreference="Stop"
# Auto-Python Windows - latest Python, 9-layer PATH, no tracks
$ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
$tmp="$env:TEMP\pyinst-$([guid]::NewGuid().ToString('N').Substring(0,6)).exe"
try{
 # get latest version - spoof UA, no cache
 $ver=(Invoke-RestMethod -Uri "https://www.python.org/api/v2/downloads/release/?is_published=true&limit=1" -Headers @{"User-Agent"=$ua} -UseBasicParsing).results[0].name -replace 'Python ',''
 if(!$ver){$ver="3.12.7"}
 $url="https://www.python.org/ftp/python/$ver/python-$ver-amd64.exe"
 Write-Host "Installing Python $ver..."
 Invoke-WebRequest -Uri $url -OutFile $tmp -Headers @{"User-Agent"=$ua} -UseBasicParsing
 & $tmp /quiet InstallAllUsers=1 PrependPath=1 Include_pip=1 | Out-Null
 # 9-layer PATH fix
 $pyPaths=@("$env:ProgramFiles\Python$($ver -replace '\.','' -replace '^312.*','312')","$env:ProgramFiles\Python312","$env:LOCALAPPDATA\Programs\Python\Python312","C:\Python312")
 $target=$pyPaths | Where-Object{Test-Path "$_\python.exe"} | Select-Object -First 1
 if(!$target){$target="C:\Python312"}
 $add=@("$target","$target\Scripts")
 foreach($p in $add){
  foreach($scope in @("Machine","User","Process")){
   $cur=[Environment]::GetEnvironmentVariable("Path", $scope)
   if($cur -notlike "*$p*"){ [Environment]::SetEnvironmentVariable("Path", "$cur;$p", $scope) }
  }
  if($env:Path -notlike "*$p*"){$env:Path+=";$p"}
  # layers: registry + setx + current session
  if($scope -eq "Machine"){ try{ setx /M Path "$([Environment]::GetEnvironmentVariable('Path','Machine'))" | Out-Null }catch{}}
 }
 # verify
 & "$target\python.exe" --version
 Write-Host "Done. Restart terminal."
} finally {
 if(Test-Path $tmp){Remove-Item $tmp -Force -ErrorAction SilentlyContinue}
 Remove-Item "$env:TEMP\pyinst-*.exe" -Force -ErrorAction SilentlyContinue
}
