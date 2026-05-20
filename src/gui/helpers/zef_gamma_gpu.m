%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [p_val] = zef_gamma_gpu(x, shape,scale)
% --- Zeffiro documentation header ---
% zef_gamma_gpu — Zef gamma gpu.
%
% Purpose:
%   Zef gamma gpu.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   x
%   shape
%   scale
%
% Outputs:
%   p_val
%
% Calls (project):
%   zef_gamma_gpu
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[p_val] = zef_gamma_gpu(x, shape, scale)` with project root and `src` on the path.
% --- End Zeffiro documentation header


p_val = (1./(scale.^shape.*gamma(shape))).*x.^(shape-1).*exp(-x./scale);

end
