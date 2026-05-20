function zef = zef_ES_update_reconstruction(zef, varargin)
% --- Zeffiro documentation header ---
% zef_ES_update_reconstruction — Zef ES update reconstruction.
%
% Purpose:
%   Zef ES update reconstruction.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%   varargin
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.h_zeffiro (read)
%   zef.reconstruction (read, write)
%   zef.y_ES_interval (read)
%
% Calls (project):
%   zef_ES_objective_function
%   zef_ES_update_reconstruction
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_ES_update_reconstruction(zef, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

switch nargin
    case 0
        zef = evalin('base','zef');
        [sr, sc] = zef_ES_objective_function(zef);
        zef.reconstruction = zef.y_ES_interval.volumetric_current_density{sr,sc};
    case 3
        zef.reconstruction = zef.y_ES_interval.volumetric_current_density{varargin{1}, varargin{2}};
    otherwise
        error('Invalid length of input arguments.')
end
try %#ok<*TRYNC>
    delete(findobj(zef.h_zeffiro.Children,'-class','matlab.graphics.illustration.ColorBar', '-and', 'tag', 'ES_colorbar'));
end

if nargout == 0
    assignin('base','zef',zef);
end

end
