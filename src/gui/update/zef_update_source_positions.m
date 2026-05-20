%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [source_positions] = zef_update_source_positions(void)
% --- Zeffiro documentation header ---
% zef_update_source_positions — Syncs GUI control values into `zef` for source_positions.
%
% Purpose:
%   Syncs GUI control values into `zef` for source_positions.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   void
%
% Outputs:
%   source_positions
%
% Zef fields (observed):
%   zef.location_unit (read)
%   zef.location_unit_current (read)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_update_source_positions
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[source_positions] = zef_update_source_positions(void)` with project root and `src` on the path.
% --- End Zeffiro documentation header


location_unit_current = evalin('base','zef.location_unit_current');
location_unit = evalin('base','zef.location_unit');
source_positions = evalin('base','zef.source_positions');

switch location_unit_current
    case 1
        b = 1000;
    case 2
        b = 100;
    case 3
        b = 1;
end
switch location_unit
    case 1
        a = 1000;
    case 2
        a = 100;
    case 3
        a = 1;
end

if not(isempty(source_positions))
    source_positions = (a/b)*source_positions;
end
