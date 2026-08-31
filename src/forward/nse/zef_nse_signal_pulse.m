function y = zef_nse_signal_pulse(t,nse_field)
%ZEF_NSE_SIGNAL_PULSE  Blackman–Harris P/T/D pulse waveform at times t (Pa).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Sums three windowed harmonics (p_wave_*, t_wave_*, d_wave_* weight/length/start
%   on nse_field, plus cycle_length). Normalizes to max-abs 1, then scales by
%   pulse_amplitude * 101325/760 (mmHg → Pa).
%
%   y = zef_nse_signal_pulse(t, nse_field)
%
%   See also zef_nse_poisson.

hgmm_conversion = 101325/760;

    function bh_val = bh_fun(t, cycle_length)
        bh_val = 0.35875 - 0.48829*cos(2*pi*t/cycle_length) + 0.14128*cos(4*pi*t/cycle_length) - 0.01168*cos(6*pi*t/cycle_length);
        bh_val(t <= 0) = 0;
        bh_val(t > cycle_length) = 0;
    end

    function w_val = wave_fun(t, w, l, s, cycle_length)
        t_aux = mod(t, cycle_length) - s*cycle_length;
        w_val = w * bh_fun(t_aux, l*cycle_length);
    end

y = wave_fun(t, nse_field.p_wave_weight, nse_field.p_wave_length, nse_field.p_wave_start, nse_field.cycle_length) + wave_fun(t, nse_field.t_wave_weight, nse_field.t_wave_length, nse_field.t_wave_start, nse_field.cycle_length)+wave_fun(t, nse_field.d_wave_weight, nse_field.d_wave_length, nse_field.d_wave_start, nse_field.cycle_length);
y = y/max(abs(y));
y = hgmm_conversion*nse_field.pulse_amplitude*y;

end
