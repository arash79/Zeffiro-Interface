function zef_set_sliders_print(mode,h_axes_image)
%ZEF_SET_SLIDERS_PRINT  Re-apply Figure-tool sliders on a print/export figure.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Same chain as zef_set_sliders_plot but passes
%   h_axes_image.Parent so popped-out / print figures (from
%   zef_print_meshes) get transparency, ColorScale, lights, etc. Mode 2
%   is the reconstruction-transparency-only path. Sensor transparency
%   is called with extra unused arguments (historical).
%
%   See also zef_set_sliders_plot, zef_print_meshes.
h_figure = h_axes_image.Parent;

if mode == 1

    h_axes_image.Colormap = zef_colormap(evalin('base','zef.h_update_colormap.Value'));
    zef_update_ambience(h_figure);
    zef_update_diffusion(h_figure);
    zef_update_specular(h_figure);

    zef_update_colorscale(h_figure);

    if evalin('base','zef.update_brightness') || evalin('base','zef.update_contrast')
        zef_update_contrast_and_brightness(h_figure);
    end;
    if evalin('base','zef.update_transparency_reconstruction');
        zef_update_transparency_reconstruction(h_figure);
    end;
    if evalin('base','zef.update_transparency_surface');
        zef_update_transparency_surface(h_figure);
    end;
    if evalin('base','zef.update_transparency_sensor');
        zef_update_transparency_sensor(h_figure,0,evalin('base','zef.update_transparency_sensor'));
    end;
    if evalin('base','zef.update_transparency_additional');
        zef_update_transparency_additional(h_figure);
    end;
    if evalin('base','zef.update_transparency_cones');
        zef_update_transparency_cones(h_figure);
    end
    if not(isequal(evalin('base','zef.update_zoom'),evalin('base','zef.cam_va')));
        zef_update_zoom(h_figure);
    end;
    if abs(evalin('base','zef.colorscale_min_slider'));
        zef_update_colorscale_min(h_figure);
    end;
    if abs(evalin('base','zef.colorscale_max_slider'));
        zef_update_colorscale_max(h_figure);
    end;
    zef_set_lights(evalin('base','zef.update_lights'),h_axes_image);

elseif mode == 2

    if evalin('base','zef.brain_transparency') < 1 || evalin('base','zef.use_parcellation')
        if evalin('base','zef.update_transparency_reconstruction');
            zef_update_transparency_reconstruction(h_figure);
        end;
    end

end
end
