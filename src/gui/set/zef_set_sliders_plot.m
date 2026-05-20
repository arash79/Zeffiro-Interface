function zef_set_sliders_plot(mode)
% --- Zeffiro documentation header ---
% zef_set_sliders_plot — Zef set sliders plot.
%
% Purpose:
%   Zef set sliders plot.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   mode
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.brain_transparency (read)
%   zef.cam_va (read)
%   zef.colorscale_max_slider (read)
%   zef.colorscale_min_slider (read)
%   zef.h_axes1 (read)
%   zef.h_update_colormap (read)
%   zef.h_zeffiro (read)
%   zef.update_brightness (read)
%   zef.update_contrast (read)
%   zef.update_lights (read)
%   zef.update_transparency_additional (read)
%   zef.update_transparency_cones (read)
%   zef.update_transparency_reconstruction (read)
%   zef.update_transparency_sensor (read)
%   zef.update_transparency_surface (read)
%   … (2 more)
%
% Calls (project):
%   zef_colormap
%   zef_set_lights
%   zef_set_sliders_plot
%   zef_update_colorscale_max
%   zef_update_colorscale_min
%   zef_update_transparency_additional
%   zef_update_transparency_cones
%   zef_update_transparency_reconstruction
%   zef_update_transparency_sensor
%   zef_update_transparency_surface
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_set_sliders_plot(mode)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
