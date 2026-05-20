function zef = zef_ES_clear_plot_data(zef)
% --- Zeffiro documentation header ---
% zef_ES_clear_plot_data — Zef ES clear plot data.
%
% Purpose:
%   Zef ES clear plot data.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.ES_plot_type (read)
%   zef.h_barplot_ES (read)
%   zef.h_colorbar_ES (read)
%   zef.h_current_ES (read)
%
% Calls (project):
%   zef_ES_clear_plot_data
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_ES_clear_plot_data(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0 
zef = eval('zef');
end

switch eval('zef.ES_plot_type');
    case 1
        if isfield(eval('zef'),'h_current_ES')
            delete(zef.h_current_ES)
            zef = rmfield(zef,'h_current_ES');
        end
    case 2
        if isfield(eval('zef'),'h_barplot_ES')
            delete(zef.h_barplot_ES)
            zef = rmfield(zef,'h_barplot_ES');
            close(gcf);
        end
    case 3
        if isfield(eval('zef'),'h_colorbar_ES')
            delete(zef.h_colorbar_ES)
            zef = rmfield(zef,'h_colorbar_ES');
            close(gcf);
        end
end

if nargout == 0
    assignin('base','zef',zef);
end

end
