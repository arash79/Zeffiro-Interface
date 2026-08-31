function zef = zef_topography(zef)
%ZEF_TOPOGRAPHY  Open Forward tools → Topography tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Menu callback (label "Topography tool", parent forward_tools).
%   Builds the window (zef_topography_app), inits from zef.inv_* times/band.
%   Start button: zef.top_reconstruction = zef_evaluate_topography(zef).
%
%   zef = zef_topography(zef)
%
%   See also zef_evaluate_topography, zef_update_topography.
%

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
try
    zef_ui_ready(zef.h_topography);
catch
end

if nargout == 0
assignin('base','zef',zef);
end

end
