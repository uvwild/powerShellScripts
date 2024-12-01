$volume = 0.1

Import-Module -Name AudioManagerModule.psm1

[AudioManager]::SetSystemVolume($volume)
