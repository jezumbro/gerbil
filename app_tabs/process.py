import PySimpleGUI as sg


def process_tab():
    return sg.Tab("Process", layout())


def layout():
    return [
        [
            sg.T("Input File:"),
            sg.I(key="design_file"),
            sg.FileBrowse(),
            sg.T("Process:"),
            sg.G(
                canvas_size=(45, 45), graph_bottom_left=(0, 0), graph_top_right=(45, 45)
            ),
        ],
        [sg.Button("Export", key="process_file")],
    ]
