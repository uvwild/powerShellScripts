#UVCONFIG.hcl

user_preferences = {
  concise_responses          = true
  no_unnecessary_explanations = true
  direct_communication       = "tacheles"
  verbose_logging_by_default = true
  editor_preferences = {
    primary   = "Notepad++"
    alternative = "VS Code"
  }
  prefer_open_source         = true
  minimal_repetition         = true
  avoid_macOS_suggestions    = true
  software_suggestions_on_request_only = true
}

setup = {
  hardware = [
    {
      name  = "laptop_1"
      model = "ASUS ZenBook UX8406MA"
      OS    = "Windows 11"
    },
    {
      name  = "laptop_2"
      model = "ASUS ZenBook Duo"
      OS    = "Windows 11"
    },
    {
      name  = "mini_pc"
      model = "Geekom AX8 Pro"
      OS    = "Windows 11"
    },
    {
      name     = "phone"
      software = "scrcpy+ 2.2.1"
    },
    {
      name = "peripherals",
      details = {
        headphones    = "Audio-Technica ATH-M50xBT2"
        audio_device  = "Casiotone CT-S200"
        monitor_stand = "Fujitsu (base plate missing)"
      }
    },
    {
      name       = "accessories",
      memory_stick = "Verbatim Store 'n' Go 16GB"
    }
  ]

  software = {
    OS             = "Windows 11 24H2"
    browser        = "Firefox"
    email_client   = "Thunderbird (Nebula 128.4.2esr)"
    audio_tools    = ["Ableton Live 10 Suite", "Cubase Pro 13"]
    installed_tools = [
      "Sysinternals (winget)",
      "Beyond Compare",
      "IrfanView with plugins (winget)"
    ]
  }

  network = {
    location         = "Germany"
    mobile_hotspot = {
      provider = "Telekom 4G"
      duration = "temporary (3 weeks)"
    }
    Wi-Fi_preference = {
      ask_before_detailing = true
    }
  }

  customizations = {
    keyboard = {
      caps_lock_disabled        = true
      prefer_disable_german_layout = true
    }
    touchpad = {
      auto_disable_when_mouse_connected = true
    }
    onedrive = {
      exclude_git_folders = true
    }
  }

  automation = {
    environment_variables = {
      alias_show_env         = "env"
      alias_grep_functionality = "custom"
    }
    scripts = {
      registry  = "enabled"
      PowerShell = "preferred"
    }
    sync = {
      primary_tool = "Beyond Compare"
      scenario     = "portable_system_sync"
    }
  }
}

notes = {
  open_source_favored         = true
  minimal_bla                 = true
  focus_on_user_defined_context = true
}
