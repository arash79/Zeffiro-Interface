%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_topography(zef)
% --- Zeffiro documentation header ---
% zef_topography — Zef topography.
%
% Purpose:
%   Zef topography.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.h_top_apply (read)
%   zef.h_top_cancel (read)
%   zef.h_top_data_segment (read)
%   zef.h_top_high_cut_frequency (read)
%   zef.h_top_low_cut_frequency (read)
%   zef.h_top_normalize_data (read)
%   zef.h_top_number_of_frames (read)
%   zef.h_top_regularization_parameter (read)
%   zef.h_top_sampling_frequency (read)
%   zef.h_top_start (read)
%   zef.h_top_time_1 (read)
%   zef.h_top_time_2 (read)
%   zef.h_top_time_3 (read)
%   zef.h_topography (read)
%   zef.measurements (read)
%
% Calls (project):
%   zef_topography
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_topography(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
zef = evalin('base','zef');
end

zef_topography_app;

set(zef.h_topography,'Name','ZEFFIRO Interface: Topography tool');
set(findobj(zef.h_topography.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_topography.Children,'-property','FontSize'),'FontSize',9);
zef_init_topography;
if isfield(zef,'measurements')
    if iscell(zef.measurements)
        set(zef.h_top_data_segment,'enable','on');
    end
    if not(iscell(zef.measurements))
        set(zef.h_top_data_segment,'enable','off');
    end
end
uistack(flipud([zef.h_top_regularization_parameter ; zef.h_top_sampling_frequency ; zef.h_top_low_cut_frequency ;
    zef.h_top_high_cut_frequency ; zef.h_top_time_1 ; zef.h_top_time_2; zef.h_top_number_of_frames; zef.h_top_time_3; zef.h_top_data_segment ; zef.h_top_cancel ; zef.h_top_normalize_data;
    zef.h_top_apply; zef.h_top_start  ]),'top');

if nargout == 0
assignin('base','zef',zef);
end

end
