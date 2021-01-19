import PySimpleGUI as sg


def log_tab():
    return sg.Tab("Logs", [[sg.Multiline(size=(120, 20), key="-LOG-")]])
