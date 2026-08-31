function [z,Var_loc,reconstruction_information] = RAP_MUSIC_iteration
%RAP_MUSIC_ITERATION  Recursively applied MUSIC dipole peel.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [z, Var_loc, reconstruction_information] = RAP_MUSIC_iteration
%
%   Called from RAPMUSIC StartButton (legacy_rap_music; not in any INI).
%   Reads base zef: L via zef_processLeadfields(zef), measurements via
%   zef_getFilteredData. Frames: zef.number_of_frames. SNR: zef.inv_snr
%   (dB) → 10^(-inv_snr/20). Peels RAPMUSIC_n_dipoles locations with
%   zef_rap_music_scan (RAP projector P=I-QQ', oriented topography
%   a=L(r)u, accumulated orientations). Location index is
%   zef_blocked_source_index(n_interp, mode) — n_interp nodes, not
%   length(unexpanded s_ind_1)/3. Amplitude is the ridge LS
%   (A'A+λI)\A'f (equivalent to A'(AA'+λI)^{-1}f). Then
%   zef_postProcessInverse / zef_normalizeInverseReconstruction.
%   Tag RAP-MUSIC. Var_loc is allocated only when number_of_frames > 1 and
%   is never filled.
%
%   See also zef_rap_music_scan, zef_blocked_source_index, zef_subspace_corr.

h = zef_waitbar(0,1,['RAP MUSIC.']);
cleanup_wb = onCleanup(@() close(h));
snr_val = evalin('base','zef.inv_snr');
std_lhood = 10^(-snr_val/20);
lambda_L = evalin('base','zef.RAPMUSIC_leadfield_lambda');
number_of_frames = evalin('base','zef.number_of_frames');
n_dipoles = evalin('base','zef.RAPMUSIC_n_dipoles');
source_direction_mode = evalin('base','zef.source_direction_mode');
source_directions = evalin('base','zef.source_directions');

pm_val = evalin('base','zef.inv_prior_over_measurement_db');
if evalin('base','isfield(zef,''inv_amplitude_db'')')
    amplitude_db = evalin('base','zef.inv_amplitude_db');
else
    amplitude_db = 20;
end
pm_val = pm_val - amplitude_db;

reconstruction_information.tag = 'RAP-MUSIC';
reconstruction_information.inv_time_1 = evalin('base','zef.inv_time_1');
reconstruction_information.inv_time_2 = evalin('base','zef.inv_time_2');
reconstruction_information.inv_time_3 = evalin('base','zef.inv_time_3');
reconstruction_information.sampling_frequency = evalin('base','zef.inv_sampling_frequency');
reconstruction_information.low_pass = evalin('base','zef.inv_high_cut_frequency');
reconstruction_information.high_pass = evalin('base','zef.inv_low_cut_frequency');
reconstruction_information.source_direction_mode = evalin('base','zef.source_direction_mode');
reconstruction_information.source_directions = evalin('base','zef.source_directions');
reconstruction_information.snr_val = evalin('base','zef.inv_snr');
reconstruction_information.number_of_frames = evalin('base','zef.number_of_frames');
reconstruction_information.leadfield_lambda = lambda_L;
reconstruction_information.n_dipoles = n_dipoles;

zef = evalin('base', 'zef');
[L, n_interp, procFile] = zef_processLeadfields(zef);

theta0 = 1;
if isfield(zef, 'inv_hyperprior') && zef.inv_hyperprior == 1
    [~, theta0] = zef_find_ig_hyperprior(snr_val-pm_val,evalin('base','zef.inv_hyperprior_tail_length_db'),[],size(L,2));
elseif isfield(zef, 'inv_hyperprior') && zef.inv_hyperprior == 2
    [~, theta0] = zef_find_g_hyperprior(snr_val-pm_val,evalin('base','zef.inv_hyperprior_tail_length_db'),[],size(L,2));
end

if number_of_frames > 1
    z = cell(number_of_frames,1);
    Var_loc = cell(number_of_frames,1);
else
    number_of_frames = 1;
    z = cell(1,1);
end

f_data = zef_getFilteredData;

L_ind = zef_blocked_source_index(n_interp, source_direction_mode);

tic;
for f_ind = 1 : number_of_frames
    time_val = toc;
    if f_ind > 1
        date_str = datestr(datevec(now+(number_of_frames/(f_ind-1) - 1)*time_val/86400));
        zef_waitbar(f_ind,number_of_frames,h,['Step ' int2str(f_ind) ' of ' int2str(number_of_frames) '. Ready: ' date_str '.' ]);
    else
        zef_waitbar(0,1,h,['RAP MUSIC. Time step ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    end

    f=zef_getTimeStep(f_data, f_ind);

    S_mat = max(f.^2,[],'all')*(std_lhood^2/theta0)*eye(size(L,1));
    if evalin('base','zef.use_gpu') == 1 && evalin('base','zef.gpu_count') > 0
        S_mat = gpuArray(S_mat);
        L_scan = gpuArray(L);
    else
        L_scan = L;
    end

    z_vec = zef_rap_music_scan(L_scan, L_ind, f, n_dipoles, S_mat);
    z{f_ind} = z_vec;
end
z = zef_postProcessInverse(z, procFile);
z = zef_normalizeInverseReconstruction(z);

end
