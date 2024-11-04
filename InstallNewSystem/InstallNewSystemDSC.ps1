# this does not seem to be working
Configuration InstallNewSystemDSC {
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node 'localhost' {

        # Define an array of package resources for each application
        Package PowerShell {
            Name = "PowerShell"
            Path = "C:\\path\\to\\PowerShellInstaller.exe"  # Replace with actual installer path
            ProductId = "Your-PowerShell-Product-ID"       # Optional
            Arguments = "/quiet /norestart"                # Silent install args
            Ensure = "Present"
        }

        Package PowerToys {
            Name = "PowerToys"
            Path = "C:\\path\\to\\PowerToysInstaller.exe"
            ProductId = "Your-PowerToys-Product-ID"
            Arguments = "/quiet /norestart"
            Ensure = "Present"
        }

        Package Sysinternals {
            Name = "Sysinternals"
            Path = "C:\\path\\to\\SysinternalsInstaller.exe"
            ProductId = "Your-Sysinternals-Product-ID"
            Arguments = "/quiet /norestart"
            Ensure = "Present"
        }

        # Continue with other packages as needed
        # Development tools
        Package Git {
            Name = "Git"
            Path = "C:\\path\\to\\GitInstaller.exe"
            ProductId = "Your-Git-Product-ID"
            Arguments = "/silent"
            Ensure = "Present"
        }

        Package VSCode {
            Name = "Visual Studio Code"
            Path = "C:\\path\\to\\VSCodeInstaller.exe"
            ProductId = "Your-VSCode-Product-ID"
            Arguments = "/silent"
            Ensure = "Present"
        }

        # System utilities
        Package TeraCopy {
            Name = "TeraCopy"
            Path = "C:\\path\\to\\TeraCopyInstaller.exe"
            ProductId = "Your-TeraCopy-Product-ID"
            Arguments = "/silent"
            Ensure = "Present"
        }

        Package HWiNFO {
            Name = "HWiNFO"
            Path = "C:\\path\\to\\HWiNFOInstaller.exe"
            ProductId = "Your-HWiNFO-Product-ID"
            Arguments = "/quiet /norestart"
            Ensure = "Present"
        }

        # Cloud storage
        Package OneDrive {
            Name = "Microsoft OneDrive"
            Path = "C:\\path\\to\\OneDriveInstaller.exe"
            ProductId = "Your-OneDrive-Product-ID"
            Arguments = "/quiet /norestart"
            Ensure = "Present"
        }

        Package GoogleDrive {
            Name = "Google Drive"
            Path = "C:\\path\\to\\GoogleDriveInstaller.exe"
            ProductId = "Your-GoogleDrive-Product-ID"
            Arguments = "/silent"
            Ensure = "Present"
        }

        # Media applications
        Package VLC {
            Name = "VLC Media Player"
            Path = "C:\\path\\to\\VLCInstaller.exe"
            ProductId = "Your-VLC-Product-ID"
            Arguments = "/silent"
            Ensure = "Present"
        }

        # Additional utilities
        Package NotepadPlusPlus {
            Name = "Notepad++"
            Path = "C:\\path\\to\\NotepadPlusPlusInstaller.exe"
            ProductId = "Your-NotepadPlusPlus-Product-ID"
            Arguments = "/silent"
            Ensure = "Present"
        }

        Package IrfanView {
            Name = "IrfanView"
            Path = "C:\\path\\to\\IrfanViewInstaller.exe"
            ProductId = "Your-IrfanView-Product-ID"
            Arguments = "/silent"
            Ensure = "Present"
        }

        # Placeholder for other utilities as needed
    }
}

# Generate the MOF file
InstallNewSystemDSC -OutputPath "C:\\DSCConfigurations"
