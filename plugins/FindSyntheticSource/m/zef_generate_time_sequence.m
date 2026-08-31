function [time_serie,time_var] = zef_generate_time_sequence(zef)
%ZEF_GENERATE_TIME_SEQUENCE  Blackman–Harris pulses × cosine for each synthetic source.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [time_serie, time_var] = zef_generate_time_sequence(zef)
%
%   Generate-time-sequence button (after zef_update_fss). Reads
%   inv_synth_sampling_frequency (max across sources),
%   inv_pulse_peak_time/amplitude/length, inv_oscillation_frequency/phase.
%   Each pulse is pulse_amp * blackmanharris(N) .* cos(2*pi*f*t+phi)
%   on [peak-length/2, peak+length/2]. nargin 0 → base zef. Does not
%   write measurements (caller stores time_sequence / time_variable).
%
%   See also zef_find_source, zef_update_fss.

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
%Length of the pulse envelope in seconds (Blackman–Harris window)
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
