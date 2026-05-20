function zef = zef_set_figure_tool_sliders(zef, varargin)
% --- Zeffiro documentation header ---
% zef_set_figure_tool_sliders — Zef set figure tool sliders.
%
% Purpose:
%   Zef set figure tool sliders.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%   varargin
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.colorscale_max_slider (read, write)
%   zef.colorscale_min_slider (read, write)
%   zef.h_axes1 (read)
%   zef.h_colorscale_max_slider (read)
%   zef.h_colorscale_min_slider (read)
%   zef.h_update_ambience (read)
%   zef.h_update_brightness (read)
%   zef.h_update_colormap (read)
%   zef.h_update_colorscale (read)
%   zef.h_update_contrast (read)
%   zef.h_update_diffusion (read)
%   zef.h_update_lights (read)
%   zef.h_update_specular (read)
%   zef.h_update_transparency_additional (read)
%   zef.h_update_transparency_cones (read)
%   … (19 more)
%
% Calls (project):
%   zef_colormap
%   zef_set_figure_tool_sliders
%   zef_set_lights
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_set_figure_tool_sliders(zef, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


set_mode = 1;

if not(isempty(varargin))
    set_mode = varargin{1};
end

if eval('isfield(zef,''h_axes1'');')
    if isvalid(eval('zef.h_axes1'))

        if set_mode == 0

            eval('zef.h_update_colormap.Value = zef.inv_colormap;');
            eval('zef.h_update_colorscale.Value = 1;');
            eval('zef.h_update_zoom.Value = 7;');
            eval('zef.h_update_transparency_reconstruction.Value = 0;');
            eval('zef.h_update_transparency_surface.Value = 0;');
            eval('zef.h_update_transparency_sensor.Value = 0;');
            eval('zef.h_update_transparency_cones.Value = 0;');
            eval('zef.h_update_transparency_additional.Value = 0;');
            eval('zef.h_update_transparency_sensor.Value = 0;');
            eval('zef.h_update_transparency_cones.Value = 0;');
            eval('zef.h_update_transparency_additional.Value = 0;');
            eval('zef.h_update_brightness.Value = 0;');
            eval('zef.h_update_contrast.Value = 0;');
            eval('zef.h_update_ambience.Value = 0.8;');
            eval('zef.h_update_diffusion.Value = 0.8;');
            eval('zef.h_update_specular.Value = 0.1;');
            eval('zef.h_colorscale_min_slider.Value = 0;');
            eval('zef.h_colorscale_max_slider.Value = 0;');
            eval('zef.update_lights = 1; zef.h_update_lights.Value = 1;');
            
            h_axes = findobj(zef.h_update_colormap.Parent.Children,'Tag','axes1');
            axis(h_axes,'auto');
            axis(h_axes,'tight');
            axis(h_axes,'equal');
            
        else

            eval('zef.h_update_colormap.Value = zef.update_colormap;');
            eval('zef.h_update_colorscale.Value = zef.update_colorscale;');
            eval('zef.h_update_zoom.Value = zef.update_zoom;');
            eval('zef.h_update_transparency_reconstruction.Value = zef.update_transparency_reconstruction;');
            eval('zef.h_update_transparency_surface.Value = zef.update_transparency_surface;');
            eval('zef.h_update_transparency_sensor.Value = zef.update_transparency_sensor;');
            eval('zef.h_update_transparency_cones.Value = zef.update_transparency_cones;');
            eval('zef.h_update_transparency_additional.Value = zef.update_transparency_additional;');
            eval('zef.h_update_transparency_sensor.Value = zef.update_transparency_sensor;');
            eval('zef.h_update_transparency_cones.Value = zef.update_transparency_cones;');
            eval('zef.h_update_transparency_additional.Value = zef.update_transparency_additional;');
            eval('[zef.h_update_contrast.Value, zef.h_update_brightness.Value] = zef_update_contrast_and_brightness;');
            eval('zef.h_update_ambience.Value =  zef.update_ambience;');
            eval('zef.h_update_diffusion.Value = zef.update_diffusion;');
            eval('zef.h_update_specular.Value = zef.update_specular;');
            eval('zef.h_colorscale_min_slider.Value = zef.colorscale_min_slider;');
            eval('zef.h_colorscale_max_slider.Value = zef.colorscale_max_slider;');

        end

        eval('zef.update_colormap = zef.h_update_colormap.Value; zef.h_axes1.Colormap = zef_colormap(zef.h_update_colormap.Value);');
        eval('zef.update_colorscale = zef_update_colorscale;');
        eval('zef.update_ambience = zef_update_ambience;');
        eval('zef.update_diffusion = zef_update_diffusion;');
        eval('zef.update_specular = zef_update_specular;');
        eval('[zef.update_contrast, zef.update_brightness] = zef_update_contrast_and_brightness;');
        eval('zef.update_transparency_reconstruction = zef_update_transparency_reconstruction;');
        eval('zef.update_transparency_surface = zef_update_transparency_surface;');
        eval('zef.update_transparency_sensor = zef_update_transparency_sensor;');
        eval('zef.update_transparency_additional = zef_update_transparency_additional;');
        eval('zef.update_transparency_cones = zef_update_transparency_cones;');
        eval('zef.update_zoom = zef_update_zoom;');
        eval('zef.colorscale_min_slider = zef_update_colorscale_min;');
        eval('zef.colorscale_max_slider = zef_update_colorscale_max;');
        eval('zef_set_lights(zef.update_lights);');

    end
end
end
