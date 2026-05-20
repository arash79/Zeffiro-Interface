%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [c_1] = zef_import_asc(c_0,varargin)
% --- Zeffiro documentation header ---
% zef_import_asc — Loads external data or a saved Zeffiro project into `zef`.
%
% Purpose:
%   Loads external data or a saved Zeffiro project into `zef`.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Inputs:
%   c_0
%   varargin
%
% Outputs:
%   c_1
%
% Calls (project):
%   zef_import_asc
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[c_1] = zef_import_asc(c_0, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


c_1 = str2num(c_0);

n_varargin = length(varargin);
if n_varargin == 2
    n_1 = varargin{1};
    n_2 = varargin{2};
    c_1 = c_1(:,n_1:n_2);
else
    c_1 = c_1(:,1:3);
end

end
