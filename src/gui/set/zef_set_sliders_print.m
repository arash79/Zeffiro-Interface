function zef_set_sliders_print(mode,h_axes_image)
% --- Zeffiro documentation header ---
% zef_set_sliders_print — Zef set sliders print.
%
% Purpose:
%   Zef set sliders print.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   mode
%   h_axes_image
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.brain_transparency (read)
%   zef.cam_va (read)
%   zef.colorscale_max_slider (read)
%   zef.colorscale_min_slider (read)
%   zef.h_update_colormap (read)
%   zef.update_brightness (read)
%   zef.update_contrast (read)
%   zef.update_lights (read)
%   zef.update_transparency_additional (read)
%   zef.update_transparency_cones (read)
%   zef.update_transparency_reconstruction (read)
%   zef.update_transparency_sensor (read)
%   zef.update_transparency_surface (read)
%   zef.update_zoom (read)
%   zef.use_parcellation (read)
%
% Calls (project):
%   zef_colormap
%   zef_set_lights
%   zef_set_sliders_print
%   zef_update_ambience
%   zef_update_colorscale
%   zef_update_colorscale_max
%   zef_update_colorscale_min
%   zef_update_contrast_and_brightness
%   zef_update_diffusion
%   zef_update_specular
%   zef_update_transparency_additional
%   zef_update_transparency_cones
%   … (4 more)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_set_sliders_print(mode, h_axes_image)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
