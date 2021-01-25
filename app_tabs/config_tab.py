import PySimpleGUI as sg


def settings_tab():
    return sg.Tab("Settings", layout=layout())


def layout():
    from configuration import read_config

    settings = read_config()
    return [
        [
            sg.T("Slic3r:"),
            sg.I(default_text=settings.slic3r_exe, key="settings_slic3r_exe"),
            sg.FileBrowse(),
        ],
        [sg.Button("Save", key="settings_save_config")],
    ]
