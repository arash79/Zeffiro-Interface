# gui

The **+gui** package contains GUI-related callbacks and helpers used by the Zeffiro Interface menu and tool system. These routines are invoked when the user selects menu items or triggers actions from the main application; they operate on the central Zeffiro struct **zef** and may call core import or other core modules.

Callbacks are reached via the `core.gui` namespace (e.g. from menu registration or internal dispatch), not typically by direct user script calls.

## Package layout

| Path | Description |
|------|-------------|
| **+menu_tool/** | Callbacks for the *Menu tool* submenu (e.g. Import electrodes). |

Additional subpackages may be added for other menus or tool groups (e.g. visualization, segmentation) as the interface grows.

## Integration

- Menu entries in the Zeffiro UI are wired to specific callback functions under **+gui** (e.g. *Menu tool > Import > Import electrodes* → **core.gui.menu_tool.import_electrodes_callback**).
- Callbacks receive **zef** as input and return an updated **zef**; they may open file dialogs, show error or warning dialogs, and call **zef_update** to refresh the application state.
- File-based imports delegate to **core.import** (e.g. **electrodes_from_dat**, **electrodes_from_csv**) for parsing; **+gui** handles user interaction and struct updates.

## See also

- [+menu_tool/README.md](+menu_tool/README.md) — Menu tool callbacks.
- [core/README.md](../README.md) — Core package overview.
- [core.import](../+import/README.md) — Import functions used by menu callbacks.
