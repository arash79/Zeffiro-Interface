function zef = zef_mne_tool_start(zef)
% --- Zeffiro documentation header ---
% zef_mne_tool_start — Zef mne tool start.
%
% Purpose:
%   Zef mne tool start.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.font_size (read)
%   zef.h_mne_apply (read)
%   zef.h_mne_cancel (read)
%   zef.h_mne_high_cut_frequency (read)
%   zef.h_mne_low_cut_frequency (read)
%   zef.h_mne_number_of_frames (read)
%   zef.h_mne_prior (read)
%   zef.h_mne_sampling_frequency (read)
%   zef.h_mne_start (read)
%   zef.h_mne_time_1 (read)
%   zef.h_mne_time_2 (read)
%   zef.h_mne_time_3 (read)
%   zef.h_mne_type (read)
%   zef.h_zef_mne_tool (read)
%   zef.mne_type (read, write)
%
% Calls (project):
%   zef_mne_tool_start
%   zef_mne_tool_window
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_mne_tool_start(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
