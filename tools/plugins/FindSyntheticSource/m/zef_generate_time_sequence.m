function [time_serie,time_var] = zef_generate_time_sequence(zef)
% --- Zeffiro documentation header ---
% zef_generate_time_sequence — Zef generate time sequence.
%
% Purpose:
%   Zef generate time sequence.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   time_serie
%   time_var
%
% Zef fields (observed):
%   zef.inv_oscillation_frequency (read)
%   zef.inv_oscillation_phase (read)
%   zef.inv_pulse_amplitude (read)
%   zef.inv_pulse_length (read)
%   zef.inv_pulse_peak_time (read)
%   zef.inv_synth_sampling_frequency (read)
%
% Calls (project):
%   zef_generate_time_sequence
%   zef_waitbar
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[time_serie, time_var]] = zef_generate_time_sequence(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header

h = zef_waitbar(0,1,['Generate time sequence.']);
if nargin == 0
    zef = evalin('base','zef');
end
%Sample rate as the number of samples per second
sampling_freq = eval( 'max(cell2mat(zef.inv_synth_sampling_frequency))');
%The time when peak of pulse occurs
peak_time = eval( 'zef.inv_pulse_peak_time');
%Amplitude of the pulse between 0 and 1
pulse_amp = eval( 'zef.inv_pulse_amplitude');
%Length of the Gaussian envelope on seconds
pulse_length = eval( 'zef.inv_pulse_length');
%Oscillation frequency
oscillation_freq = eval( 'zef.inv_oscillation_frequency');
%Oscillation phase
oscillation_phase = eval( 'zef.inv_oscillation_phase');

signal_duration = 0;
for n = 1:length(peak_time)
    signal_duration = max([pulse_length{n}/2+peak_time{n},signal_duration]);
end
time_var = 0:(1/sampling_freq):signal_duration;

time_serie = zeros(length(peak_time),length(time_var));
for n = 1:length(peak_time)
    for j = 1:length(peak_time{n})
        %pulse_points = ceil(pulse_length{n}(j)*sampling_freq);
        start_ind = length(time_var(time_var<=peak_time{n}(j) - pulse_length{n}(j)/2));
        end_ind = length(time_var(time_var<=peak_time{n}(j) + pulse_length{n}(j)/2));
        if start_ind == 0
            start_ind = 1;
        end
        pulse_points=length(start_ind:end_ind);
        time_var_aux = time_var(start_ind:end_ind);
        time_var_aux = time_var_aux(:)';
        blackmanharris_aux = blackmanharris(pulse_points);
        blackmanharris_aux = blackmanharris_aux(:)';
        signal_pulse = pulse_amp{n}(j)*blackmanharris_aux.*cos(2*pi*oscillation_freq{n}(j)*time_var_aux+oscillation_phase{n}(j));
        time_serie(n,start_ind:end_ind) = time_serie(n,start_ind:end_ind) + signal_pulse;
    end
    zef_waitbar(n,size(peak_time,1),h,['Generating time sequence ',num2str(n),' of ',num2str(size(peak_time,1))])
end

close(h);

end
