function zef = zef_set_position(zef)
%ZEF_SET_POSITION  Segmentation-tool **Set position**: write default window rect to INI.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Reads h_zeffiro_window_main.Position; if the Segmentation
%   **Toggle controls** UserData==1, halves width (expanded layout).
%   Writes that vector into profile/zeffiro_interface.ini field
%   segmentation_tool_default_position via writecell, and into
%   zef.segmentation_tool_default_position. nargout==0 → assignin base.
%
%   See also zef_segmentation_tool.
if nargin == 0
    zef = evalin('base','zef');
end

position_vec = zef.h_zeffiro_window_main.Position;
if zef.h_segmentation_tool_toggle.UserData == 1
    position_vec(3) = 0.505*position_vec(3);
end

zef.ini_cell = zef_read_profile_cell([zef.program_path '/profile/zeffiro_interface.ini']);
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
