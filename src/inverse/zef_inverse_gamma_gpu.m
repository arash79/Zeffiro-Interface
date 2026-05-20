%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [p_val] = zef_inverse_gamma_gpu(x, shape,scale)
% --- Zeffiro documentation header ---
% zef_inverse_gamma_gpu — Zef inverse gamma gpu.
%
% Purpose:
%   Zef inverse gamma gpu.
%   Folder: Inverse orchestration: filtered measurements, lead-field processing, `zef_inverse_run`, bundle extraction, and post-processing into `zef.reconstruction`.
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
%   zef_inverse_gamma_gpu
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[p_val] = zef_inverse_gamma_gpu(x, shape, scale)` with project root and `src` on the path.
% --- End Zeffiro documentation header


p_val = zef_gamma_gpu(1./x,shape,1./scale)./(x.^2);

end
