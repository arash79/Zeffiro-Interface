function ES_active_electrodes = zef_ES_fix_active_electrodes(zef)
%ZEF_ES_FIX_ACTIVE_ELECTRODES  Active-electrode mask from score-dose / y_ES when the checkbox is on.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ValueChangedFcn of h_ES_fixed_active_electrodes and the constructor.
%   If the box is off, returns []. If on, takes y_ES{sr,sc} from
%   zef_ES_objective_function and the ES_score_dose largest-|y| indices.
%
%   ES_active_electrodes = zef_ES_fix_active_electrodes(zef)
%
%   See also zef_ES_objective_function, zef_ES_find_currents_recursive.
%

if not(zef.h_ES_fixed_active_electrodes.Value)
    ES_active_electrodes = [];
else
    try
        [sr, sc] = zef_ES_objective_function(zef);
    catch
        ES_active_electrodes = [];
        return
    end
    
    if isempty(sr)
        ES_active_electrodes = [];
    else
        y_ES_interval = zef.y_ES_interval;
                
        [~,I] = maxk(abs(y_ES_interval.y_ES{sr,sc}), zef.ES_score_dose);
        ES_active_electrodes = sort(I);
    end
end
