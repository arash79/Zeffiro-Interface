%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isfield(zef,'inv_synth_source')); — If not(isfield(zef,'inv synth source'));.
%
% Purpose:
%   If not(isfield(zef,'inv synth source'));.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_inv_synth_source_1 (read)
%   zef.h_inv_synth_source_10 (read)
%   zef.h_inv_synth_source_2 (read)
%   zef.h_inv_synth_source_3 (read)
%   zef.h_inv_synth_source_4 (read)
%   zef.h_inv_synth_source_5 (read)
%   zef.h_inv_synth_source_6 (read)
%   zef.h_inv_synth_source_7 (read)
%   zef.h_inv_synth_source_8 (read)
%   zef.h_inv_synth_source_9 (read)
%   zef.h_inv_synth_source_VEP_config (read)
%   zef.h_inv_synth_source_fix_amp (read)
%   zef.h_inv_synth_source_norm_ori (read)
%   zef.h_inv_synth_source_plot_cones (read)
%   zef.h_inv_synth_source_radius (read)
%   … (2 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isfield(zef,'inv_synth_source'));` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



if not(isfield(zef,'inv_synth_source'));
    zef.inv_synth_source = [0 0 0 1 0 0 10 0 3 1 1 1 0 0 0 0];
elseif size(zef.inv_synth_source,2)<16
     zef.inv_synth_source = [0 0 0 1 0 0 10 0 3 1 1 1 0 0 0 0];
end


set(zef.h_inv_synth_source_1 ,'string',num2str(zef.inv_synth_source(:,1)'));
set(zef.h_inv_synth_source_2 ,'string',num2str(zef.inv_synth_source(:,2)'));
set(zef.h_inv_synth_source_3 ,'string',num2str(zef.inv_synth_source(:,3)'));
set(zef.h_inv_synth_source_4 ,'string',num2str(zef.inv_synth_source(:,4)'));
set(zef.h_inv_synth_source_5 ,'string',num2str(zef.inv_synth_source(:,5)'));
set(zef.h_inv_synth_source_6 ,'string',num2str(zef.inv_synth_source(:,6)'));
set(zef.h_inv_synth_source_7 ,'string',num2str(zef.inv_synth_source(:,7)'));
set(zef.h_inv_synth_source_8 ,'string',num2str(zef.inv_synth_source(1,8)));
set(zef.h_inv_synth_source_9 ,'string',num2str(zef.inv_synth_source(1,9)));
set(zef.h_inv_synth_source_10 ,'value',zef.inv_synth_source(1,10));
set(zef.h_inv_synth_source_use_volume, 'value', zef.inv_synth_source(1,11));
set(zef.h_inv_synth_source_radius, 'string',num2str(zef.inv_synth_source(1,12)));
set(zef.h_inv_synth_source_norm_ori, 'value',zef.inv_synth_source(1,13));
set(zef.h_inv_synth_source_plot_cones, 'value',zef.inv_synth_source(1,14));
set(zef.h_inv_synth_source_fix_amp, 'value',zef.inv_synth_source(1,15));
set(zef.h_inv_synth_source_VEP_config, 'value', zef.inv_synth_source(1,16));
