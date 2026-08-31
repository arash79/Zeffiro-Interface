function zef = zef_assign_data(zef, zef_data)
%ZEF_ASSIGN_DATA  Copy every field of an App-export struct onto zef.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Used by zef_mesh_tool after zef_mesh_tool_app_exported.
%   No-arg mode: evalin base zef_data (and zef if present); nargout==0
%   assignin('base','zef',zef) and clear zef_data in base.
%
%   zef = zef_assign_data(zef, zef_data)
if nargin == 0
    zef_data = evalin('base','zef_data');
    if not(isempty(evalin('base','whos(''zef'')')))
        zef = evalin('base','zef');
    else
        evalin('base','zef = struct;');
    end
end

fieldnames_aux = eval('fieldnames(zef_data)');
for zef_i = 1 : length(fieldnames_aux)
    zef.(fieldnames_aux{zef_i}) = zef_data.(fieldnames_aux{zef_i});
end

if nargout == 0
    assignin('base','zef',zef);
    evalin('base','clear zef_data;');
end

end
