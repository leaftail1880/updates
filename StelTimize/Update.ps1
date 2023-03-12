# Пути, с которыми нам предстоит работать
$currentUser = [Environment]::UserName
$mojang = "C:\Users\$currentUser\AppData\Local\Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\games\com.mojang"

$globalRP = "$mojang\develompent_resource_packs"

Remove-Item -Path "$globalRP\StealTimize" -Recurse -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/leaftail1880/update/main/StelTimize/packet.zip" -OutFile "$globalRP\StealTimize.zip"
Expand-Archive -Path "$globalRP\StealTimize.zip" -DestinationPath "$globalRP/StealTimize"
Remove-Item -Path "$globalRP\StealTimize.zip" -Force

$manifest = Get-Content "$globalRP\StealTimize\manifest.json" | ConvertFrom-Json
$version = $manifest.header.version

# Путь до файла с настройками глобальных пакетов ресурсов. Раз мы скачали новую версию, надо и там обновить.
$globalRpFile = "$mojang\minecraftpe\global_resource_packs.json"
$packID = "12232017-1101-0000-a004-a1b2c3d4e5f6"

Write-Host "Updateing file on '$globalRpFile'..."


# Чтение файла
$json = Get-Content $globalRpFile | ConvertFrom-Json

# Поиск объекта по pack_id и замена значения version или добавление нового объекта
$found = $false
foreach ($obj in $json) {
  if ($obj.pack_id -eq $packID) {
    $obj.version = @(6, 0, 0) # Новое значение version
    $found = $true
    break # Прерываем цикл после замены первого найденного объекта
  }
}

# Если объект не найден, то добавляем новый
if (!$found) {
  $newObj = @{
    pack_id = $packID
    subpack = "default"
    version = @(5, 2, 1)
  }
  $json += $newObj
}

# Форматируем JSON в строку
$raw_json = ConvertTo-Json $json -Depth 100 -Indentation 4

# Запись изменений в файл
$raw_json | Set-Content $globalRpFile

Write-Host "Updating done. Full JSON content:"
Write-Host " "
Write-Host $raw_json


Read-Host -Prompt "Press Enter to exit"