function str = zef_string_from_source_model(input)
% --- Zeffiro documentation header ---
% zef_string_from_source_model — Zef string from source model.
%
% Purpose:
%   Zef string from source model.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   input
%
% Outputs:
%   str
%
% Calls (project):
%   zef_string_from_source_model
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[str] = zef_string_from_source_model(input)` with project root and `src` on the path.
% --- End Zeffiro documentation header

switch input
    case core.types.ZefSourceModel.Error
        str = 'Error';
    case core.types.ZefSourceModel.Whitney
        str = 'Whitney';
    case core.types.ZefSourceModel.Hdiv
        str = 'H(div)'
    otherwise
        warning("Did not receive a valid core.types.ZefSourceModel. Returning Error.")
        str = 'Error';
end
end
