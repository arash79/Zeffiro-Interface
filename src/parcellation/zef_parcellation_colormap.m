function [colormap_vec] = zef_parcellation_colormap(varargin)
% --- Zeffiro documentation header ---
% zef_parcellation_colormap — Zef parcellation colormap.
%
% Purpose:
%   Zef parcellation colormap.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   varargin
%
% Outputs:
%   colormap_vec
%
% Zef fields (observed):
%   zef.parcellation_colormap (read)
%
% Calls (project):
%   zef_parcellation_colormap
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[colormap_vec] = zef_parcellation_colormap(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


colormap_vec = evalin('base','zef.parcellation_colormap');

end
