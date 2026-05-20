% --- Zeffiro documentation header ---
% set(gcbo,'Tag',''); — Set(gcbo,'Tag','');.
%
% Purpose:
%   Set(gcbo,'Tag','');.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_zeffiro (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `set(gcbo,'Tag','');` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

set(gcbo,'Tag','');
if isequal(exist('zef'),1)
    if isfield(zef,'h_zeffiro')
        if zef.h_zeffiro == gcbo;
            zef_figure_tool;
        end
    end
end
