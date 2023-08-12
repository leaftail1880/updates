$packName = 'StealTimize'

$mojang = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"
$mojangBeta = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.MinecraftWindowsBeta_8wekyb3d8bbwe\LocalState\games\com.mojang"

$devRP = "development_resource_packs"
$packs = "$mojang\$devRP"
$packsBeta = "$mojangBeta\$devRP"



function EnsureDirs($mojang, $packs) {
  New-Item -ItemType Directory -Path $packs -Force
  New-Item -ItemType Directory -Path "$mojang\minecraftpe" -Force

  Remove-Item -Path "$mojang\minecraftpe\invalid_known_packs.json" -Force -ErrorAction SilentlyContinue
  Remove-Item -Path "$mojang\minecraftpe\valid_known_packs.json" -Force -ErrorAction SilentlyContinue
  
  # Remove old pack
  Remove-Item -Path "$packs\$packName" -Recurse -Force -ErrorAction SilentlyContinue
}

EnsureDirs $mojang $packs
EnsureDirs $mojangBeta $packsBeta

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/leaftail1880/updates/main/StealTimize/Packet.zip" -OutFile "$packs\$packName.zip"
Expand-Archive -Path "$packs\$packName.zip" -DestinationPath "$packs"
Rename-Item "$packs\temp" -NewName $packName
Remove-Item -Path "$packs\$packName.zip" -Force
Copy-Item -Path "$packs\$packName" -Destination $packsBeta -Force -Recurse

$manifest = Get-Content "$packs\$packName\manifest.json" | ConvertFrom-Json
$version = $manifest.header.version
$packID = $manifest.header.uuid

function UpdateStealtimize($mojang) {
  $globalRpFile = "$mojang\minecraftpe\global_resource_packs.json"
  Write-Host "Updating file '$globalRpFile'..."
  
  try {
    $json = Get-Content -Raw $globalRpFile -ErrorAction SilentlyContinue 
    $json = ConvertFrom-Json "{""array"":$json}"
    $json = $json.array
  }
  catch {}
  
  if (!$json) {
    $json = "{""array"":[]}" | ConvertFrom-Json
    $json = $json.array
  }
  
  $found = $false
  $found_dev = $false
  foreach ($obj in $json) {
    if ($obj.pack_id -eq $packID) {
      $obj.version = $version
      $found = $true
    }
    if ($obj.pack_id -eq "12232017-1101-0000-a004-a1b2c3d4e5f7") {
      $found_dev = $true
    }
  }

  if (!$found_dev) {
    if (!$found) {
      $json += @{
        pack_id = $packID
        subpack = "default"
        version = $version
      }
    }
  }

  ConvertTo-Json $json | Set-Content $globalRpFile -Force

  Write-Host "Done. New file content:"
  Write-Host " "
  Get-Content $globalRpFile | Write-Host
  Write-Host " "
}

UpdateStealtimize $mojang
UpdateStealtimize $mojangBeta

# Read-Host -Prompt "Press Enter to exit"