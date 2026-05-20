function zef = zef_beamformer_start(zef)
% --- Zeffiro documentation header ---
% zef_beamformer_start — Zef beamformer start.
%
% Purpose:
%   Zef beamformer start.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_beamformer_start
%   zef_tool_start
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_beamformer_start(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef = zef_tool_start(zef,'zef_beamformer_window',1/4,1);

if nargout == 0
    assignin('base','zef',zef)
end

end
