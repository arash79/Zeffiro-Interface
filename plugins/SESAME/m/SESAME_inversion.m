function [z] = SESAME_inversion(void)
%SESAME_INVERSION  SESAME sequential Monte Carlo dipole sampler wrapper.
%
%   Copyright © 2018- Joonas Lahtinen, Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   z = SESAME_inversion(void)
%
%   Called from SESAME h_start (legacy_sesame; no inverse.*Inverter).
%   Argument void is unused. Needs zef.L, source_positions, measurements,
%   and inverse_SESAME. Frames: zef.number_of_frames; each frame may pass
%   a time window of columns. SNR: zef.SESAME_snr → cfg.noise_std =
%   10^(-SESAME_snr/20). Neighbours from SESAMEneighbours. Side effects:
%   writes zef.SESAME and zef.SESAME_time_serie{frame} in base; clears
%   SESAME_time_serie at the start of a run. Returns cell z.
%   As written, source_positions(s_ind_1,:) runs before s_ind_1 is
%   assigned (s_ind_1 is not set in this file).
%
%   See also inverse_SESAME, SESAMEneighbours, SESAME_App_run.

sampling_freq = evalin('base','zef.inv_sampling_frequency');
number_of_frames = evalin('base','zef.number_of_frames');
source_direction_mode = evalin('base','zef.source_direction_mode');
source_positions = evalin('base','zef.source_positions');

% s_ind_1 is not assigned in this file (would subset source_positions).
source_positions = source_positions(s_ind_1,:);

[L,n_interp, procFile] = zef_processLeadfields(source_direction_mode);
% Zeffiro stores xyz stacked (all x, then y, then z). SESAME wants
% per-source triplets, so permute columns; s_back_ind undoes this after.
s_reorder_ind = reshape((1:n_interp)+(0:n_interp:(2*n_interp))',[],1);
%indices to order cartesian direction-wise:
s_back_ind = reshape((1:3:(3*n_interp))'+(0:2),[],1);

L = L(:,s_reorder_ind);

if number_of_frames > 1
    z = cell(number_of_frames,1);
else
    z = cell(1,1);
    number_of_frames = 1;
end

f_org = zef_getFilteredData;

if evalin('base','isfield(zef,''SESAME_time_serie'')')
    evalin('base','zef=rmfield(zef,''SESAME_time_serie'');');
end

%============== CALCULATE NEGHBOURS BEFOREHAND  ==============
[cfg.neighbours,cfg.neighboursp] = SESAMEneighbours(source_positions);

tic;
for f_ind = 1 : number_of_frames
    time_val = toc;
    if f_ind > 1  && number_of_frames > 1
        date_str = datestr(datevec(now+(number_of_frames/(f_ind-1) - 1)*time_val/86400));
    end;

    if size(f_org,2) > 1
        if evalin('base','zef.inv_time_2') >=0 && evalin('base','zef.inv_time_1') >= 0 && 1 + sampling_freq*evalin('base','zef.inv_time_1') <= size(f_org,2);
            f = f_org(:, max(1, 1 + floor(sampling_freq*evalin('base','zef.inv_time_1')+sampling_freq*(f_ind - 1)*evalin('base','zef.inv_time_3'))) : min(size(f_org,2), 1 + floor(sampling_freq*(evalin('base','zef.inv_time_1') + evalin('base','zef.inv_time_2'))+sampling_freq*(f_ind - 1)*evalin('base','zef.inv_time_3'))));
        end
    else
        f = f_org;
    end

    if f_ind >= 1
        % MATLAB waitbar, not zef_waitbar. Handle h is never created here.
        waitbar(f_ind/number_of_frames,h,['SESAME iteration. Time step ' int2str(f_ind) ' of ' int2str(number_of_frames) '.']);
    end

    cfg.t_start = 1;
    cfg.t_stop = size(f,2);
    cfg.n_samples = evalin('base','zef.SESAME_n_sampler');
    cfg.noise_std = 10^(-evalin('base','zef.SESAME_snr')/20);
    p_data = inverse_SESAME(f,L,source_positions,cfg);
    z_vec = zeros(size(L,2),1);
    d_est = p_data.estimated_dipoles;
    p_data.dipole_positions = source_positions(d_est,:);
    assignin('base','zef_temp',p_data)
    assignin('base','zef_temp_ind',f_ind)
    evalin('base','zef.SESAME=zef_temp; zef.SESAME_time_serie{zef_temp_ind}=zef_temp; clear zef_temp; clear zef_temp_ind;')
    for d_ind = 1 : length(d_est)
        % Place the time-mean moment on the three node-wise columns of that source.
        qv_data = mean(p_data.QV_estimated(3*(d_ind-1)+1:3*d_ind,:),2);
        z_vec([-2 -1 0]'+3*d_est(d_ind)) = qv_data;
    end

    z{f_ind} = z_vec(s_back_ind);
end

z = zef_postProcessInverse(z, procFile);
close(h);
end
