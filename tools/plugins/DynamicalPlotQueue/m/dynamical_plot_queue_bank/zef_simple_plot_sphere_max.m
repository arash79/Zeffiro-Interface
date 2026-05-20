function zef_simple_plot_sphere_max(varargin)
% --- Zeffiro documentation header ---
% zef_simple_plot_sphere_max — Zef simple plot sphere max.
%
% Purpose:
%   Zef simple plot sphere max.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   varargin
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.reconstruction (read)
%   zef.source_positions (read)
%
% Calls (project):
%   zef_simple_plot_sphere_max
%
% Side effects:
%   - base/caller workspace
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_simple_plot_sphere_max(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if not(isempty(varargin))
    radius_val = varargin{1};
    if length(varargin) > 1
        color_val = varargin{2};
    else
        color_val = [1 0 0];
    end
else
    radius_val = 10;
    color_val = [1 0 0];
end

[X,Y,Z] = sphere(100);
h_axes = evalin('caller','h_axes_image');

%axes(h_axes);

f_ind = evalin('caller','f_ind');
delete(findobj(h_axes,'Tag','additional: max sphere'));
r = evalin('base','zef.reconstruction');
p = evalin('base','zef.source_positions');
if iscell(r)
    [~,r_ind] = max(sum(reshape(r{f_ind},3,length(r{f_ind}(:))/3).^2));
else
    [~,r_ind] = max(sum(reshape(r,3,length(r(:))/3).^2));
end
h_surf = surf(h_axes,radius_val*X+p(r_ind,1),radius_val*Y+p(r_ind,2),radius_val*Z+p(r_ind,3));
set(h_surf,'edgecolor','none','facecolor',color_val);
set(h_surf,'Tag','additional: max sphere');

end
