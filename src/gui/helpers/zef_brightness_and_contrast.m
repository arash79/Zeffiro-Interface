function colormap_vec = zef_brighness_and_contrast(colormap_vec, brightness_val, contrast_val)
% --- Zeffiro documentation header ---
% zef_brighness_and_contrast — Zef brighness and contrast.
%
% Purpose:
%   Zef brighness and contrast.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   colormap_vec
%   brightness_val
%   contrast_val
%
% Outputs:
%   colormap_vec
%
% Calls (project):
%   zef_brighness_and_contrast
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[colormap_vec] = zef_brighness_and_contrast(colormap_vec, brightness_val, contrast_val)` with project root and `src` on the path.
% --- End Zeffiro documentation header


colormap_vec = (((colormap_vec + brightness_val)/(1+brightness_val)).^(1+contrast_val));

end
