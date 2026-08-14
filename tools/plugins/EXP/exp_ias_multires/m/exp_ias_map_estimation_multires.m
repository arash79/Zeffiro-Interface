%EXP_IAS_MAP_ESTIMATION_MULTIRES  Open GUIDE window: IAS MAP RAMUS for EP (asteroid INI).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Asteroid / _legacy / _nse INI callback (Inverse tools →
%   EXP IAS RAMUS). Opens exp_ias_map_estimation_multires.fig (title
%   ZEFFIRO Interface: IAS MAP multiresolution (RAMUS) for EP),
%   zef_init_exp_ias_multires. Start in the fig runs
%   exp_ias_iteration_multires([]). Needs zef.L, measurements, and
%   exp_multires_dec. Not the default-profile Lasso app
%   (zef_exp_app_launch).
%
%   See also zef_init_exp_ias_multires, exp_ias_iteration_multires.

if  ismac
    zef.h_exp_ias_map_estimation_multires = open('exp_ias_map_estimation_multires.fig');
elseif ispc
    zef.h_exp_ias_map_estimation_multires = open('exp_ias_map_estimation_multires.fig');
else
    zef.h_exp_ias_map_estimation_multires = open('exp_ias_map_estimation_multires.fig');
end
set(zef.h_exp_ias_map_estimation_multires,'Name','ZEFFIRO Interface: IAS MAP multiresolution (RAMUS)
 for EP');
set(findobj(zef.h_exp_ias_map_estimation_multires.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_exp_ias_map_estimation_multires.Children,'-property','FontSize'),'FontSize',zef.font_size);

zef_init_exp_ias_multires;
if isfield(zef,'measurements')
    if iscell(zef.measurements)
        set(zef.h_exp_ias_multires_data_segment,'enable','on');
    end
    if not(iscell(zef.measurements))
        set(zef.h_exp_ias_multires_data_segment,'enable','off');
    end
end
uistack(flipud([zef.h_exp_ias_multires_n_levels; zef.h_exp_ias_multires_sparsity; zef.h_exp_ias_multires_q ; zef.h_exp_ias_multires_beta ; zef.h_exp_ias_multires_theta0;
    zef.h_exp_ias_multires_snr ; zef.h_exp_ias_multires_n_iter ; zef.h_exp_ias_multires_n_L1_iterations ;
    zef.h_exp_ias_multires_sampling_frequency ; zef.h_exp_ias_multires_low_cut_frequency ;
    zef.h_exp_ias_multires_high_cut_frequency ; zef.h_exp_ias_multires_time_1 ; zef.h_exp_ias_multires_time_2; zef.h_exp_ias_multires_number_of_frames; zef.h_exp_ias_multires_time_3; zef.h_exp_ias_multires_data_segment ; zef.h_exp_ias_multires_cancel ;
    zef.h_exp_ias_multires_apply; zef.h_exp_ias_multires_start  ]),'top');
