function zef = zef_mne_tool_start(zef)
%ZEF_MNE_TOOL_START  Open the MNE window (Start is bound in the window dump).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = zef_mne_tool_start
%   zef = zef_mne_tool_start(zef)
%
%   nargin 0 → base zef. zef_mne_tool_window, font size, zef_init_mne.
%   Does not invert and does not rebind Start (Start is in
%   zef_mne_tool_window: update + zef_find_mne_reconstruction(zef)).
%   Menu: zef_minimum_norm_estimation.
%
%   See also zef_init_mne, zef_find_mne_reconstruction, zef_mne_tool_window.

if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_mne_tool_window(zef);
set(zef.h_zef_mne_tool,'Name','ZEFFIRO Interface: Minimum norm estimate tool');
set(findobj(zef.h_zef_mne_tool.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_zef_mne_tool.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef_init_mne;

set(zef.h_mne_type,'Callback','zef.mne_type= get(gcbo,''Value'');');

uistack(flipud([zef.h_mne_type ; zef.h_mne_prior;
    zef.h_mne_sampling_frequency ; zef.h_mne_low_cut_frequency ;
    zef.h_mne_high_cut_frequency ; zef.h_mne_time_1 ; zef.h_mne_time_2; zef.h_mne_number_of_frames; zef.h_mne_time_3 ; zef.h_mne_cancel ;
    zef.h_mne_apply; zef.h_mne_start  ]),'top');

if nargout == 0
    assignin('base','zef',zef);
end

end
