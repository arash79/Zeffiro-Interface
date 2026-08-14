function zef_set_sliders_plot(mode)
%ZEF_SET_SLIDERS_PLOT  Re-apply Figure-tool sliders after a redraw of h_axes1.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. Called from zef_plot_volume / zef_plot_meshes after patches
%   are created (new objects would otherwise ignore slider state).
%   Mode 1: colormap, ColorScale, ambience/diffusion/specular,
%   contrast/brightness if nonzero, each transparency_* if nonzero,
%   zoom if ≠ cam_va, colorscale min/max if nonzero, then zef_set_lights.
%   Mode 2: reconstruction transparency only, and only if
%   brain_transparency<1 or use_parcellation. All calls evalin base.
%
%   See also zef_set_sliders_print, zef_plot_volume.
if mode == 1

    evalin('base','zef.h_axes1.Colormap = zef_colormap(zef.h_update_colormap.Value);');
    evalin('base','zef_update_colorscale;');
    evalin('base','zef_update_ambience;');
    evalin('base','zef_update_diffusion;');
    evalin('base','zef_update_specular;');
    evalin('base','if zef.update_brightness || zef.update_contrast; zef_update_contrast_and_brightness; end;');
    evalin('base','if zef.update_transparency_reconstruction; zef_update_transparency_reconstruction(zef.h_zeffiro); end;');
    evalin('base','if zef.update_transparency_surface; zef_update_transparency_surface(zef.h_zeffiro); end;');
    evalin('base','if zef.update_transparency_sensor; zef_update_transparency_sensor(zef.h_zeffiro); end;');
    evalin('base','if zef.update_transparency_additional; zef_update_transparency_additional(zef.h_zeffiro); end');
    evalin('base','if zef.update_transparency_cones; zef_update_transparency_cones(zef.h_zeffiro); end');
    evalin('base','if not(isequal(zef.update_zoom,zef.cam_va)); zef_update_zoom; end');
    evalin('base','if abs(zef.colorscale_min_slider); zef_update_colorscale_min(zef.h_zeffiro); end;');
    evalin('base','if abs(zef.colorscale_max_slider); zef_update_colorscale_max(zef.h_zeffiro); end;');
    evalin('base','zef_set_lights(zef.update_lights);');

elseif mode == 2

    if evalin('base','zef.brain_transparency') < 1 || evalin('base','zef.use_parcellation')
        evalin('base','if zef.update_transparency_reconstruction; zef_update_transparency_reconstruction(zef.h_zeffiro); end;');
    end

end
end
