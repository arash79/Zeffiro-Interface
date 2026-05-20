% --- Zeffiro documentation header ---
% function zef_plot_SESAME_dipoles — Function zef plot SESAME dipoles.
%
% Purpose:
%   Function zef plot SESAME dipoles.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.SESAME_App (read)
%   zef.SESAME_time_serie (read)
%   zef.inv_rec_source (read, write)
%
% Calls (project):
%   zef_plot_SESAME_dipoles
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_plot_SESAME_dipoles` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_plot_SESAME_dipoles

zef = evalin('base','zef');
h_axes_image = evalin('caller','h_axes_image');
f_ind = evalin('caller','f_ind');

rec_vec_init = [0 0 0 0 0 0 0 str2num(zef.SESAME_App.h_inv_rec_source_8.Value) str2num(zef.SESAME_App.h_inv_rec_source_9.Value)];

d_est = zef.SESAME_time_serie{f_ind}.estimated_dipoles;

    zef.inv_rec_source = repmat(rec_vec_init,length(d_est),1);
    zef.inv_rec_source(:,1:3) = zef.SESAME_time_serie{f_ind}.dipole_positions;

    for d_ind = 1 : length(d_est)
        zef.inv_rec_source(d_ind,4:6) = zef.SESAME_time_serie{f_ind}.QV_estimated(1+3*(d_ind-1):3*d_ind)/zef.SESAME_time_serie{f_ind}.Q_estimated(d_ind);
    end

    zef.inv_rec_source(:,7)=zef.SESAME_time_serie{f_ind}.Q_estimated;
    zef_plot_3D_stem_reconstructed_source;
    clear d_est d_ind
     
end
