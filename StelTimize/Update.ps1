# Пути, с которыми нам предстоит работать
$mojang = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"

$globalRP = "$mojang\development_resource_packs"
$packName = 'StealTimize'

# Старого пакета может и не быть
try {
  Remove-Item -Path "$globalRP\$packName" -Recurse -Force
} catch {}

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/leaftail1880/updates/main/StelTimize/packet.zip" -OutFile "$globalRP\$packName.zip"
Expand-Archive -Path "$globalRP\$packName.zip" -DestinationPath "$globalRP"
Rename-Item "$globalRP/temp" -NewName $packName
Remove-Item -Path "$globalRP\$packName.zip" -Force

$manifest = Get-Content "$globalRP\$packName\manifest.json" | ConvertFrom-Json
$version = $manifest.header.version
$packID = $manifest.header.uuid

# Путь до файла с настройками глобальных пакетов ресурсов. Раз мы скачали новую версию, надо и там обновить.
$globalRpFile = "$mojang\minecraftpe\global_resource_packs.json"

Write-Host "Updating file on '$globalRpFile'..."


# Чтение файла
$json = Get-Content $globalRpFile | ConvertFrom-Json

# Поиск объекта по pack_id и замена значения version или добавление нового объекта
$found = $false
foreach ($obj in $json) {
  if ($obj.pack_id -eq $packID) {
    $obj.version = $version # Новое значение version
    $found = $true
    break # Прерываем цикл после замены первого найденного объекта
  }
}

# Если объект не найден, то добавляем новый
if (!$found) {
  $newObj = @{
    pack_id = $packID
    subpack = "default"
    version = $version
  }
  $json += $newObj
}

# Форматируем JSON в строку
$raw_json = ConvertTo-Json $json -Depth 100

# Запись изменений в файл
$raw_json | Set-Content $globalRpFile

Write-Host "Done. Full JSON content:"
Write-Host " "
Write-Host $raw_json
Write-Host " "

Read-Host -Prompt "Press Enter to exit"