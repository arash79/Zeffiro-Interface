function zef = zef_set_position(zef)
% --- Zeffiro documentation header ---
% zef_set_position — Zef set position.
%
% Purpose:
%   Zef set position.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.h_segmentation_tool_toggle (read)
%   zef.h_zeffiro_window_main (read)
%   zef.ini_cell (read, write)
%   zef.program_path (read)
%   zef.segmentation_tool_default_position (read, write)
%
% Calls (project):
%   zef_set_position
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_set_position(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

position_vec = zef.h_zeffiro_window_main.Position;
if zef.h_segmentation_tool_toggle.UserData == 1
    position_vec(3) = 0.505*position_vec(3);
end

zef.ini_cell = readcell([zef.program_path '/profile/zeffiro_interface.ini'],'FileType','text');
for zef_i =  1 : size(zef.ini_cell,1)

    if isequal(zef.ini_cell{zef_i,3},'segmentation_tool_default_position')
        zef.ini_cell{zef_i,2} = ['[' num2str(position_vec) ']'];
    end

end

writecell(zef.ini_cell,[zef.program_path '/profile/zeffiro_interface.ini'],'FileType','text');

zef.segmentation_tool_default_position = position_vec;

if nargout==0
    assignin('base','zef',zef);
end

end
