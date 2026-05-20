
%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface


function zef = zef_minimum_norm_estimation(zef)
% --- Zeffiro documentation header ---
% zef_minimum_norm_estimation — Zef minimum norm estimation.
%
% Purpose:
%   Zef minimum norm estimation.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_minimum_norm_estimation
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_minimum_norm_estimation(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_mne_tool_start',1/4,0);

if nargout == 0
    assignin('base','zef',zef)
end

end
