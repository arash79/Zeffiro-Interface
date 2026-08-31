function zef_GMM_subs_time_vars(char_var)
%ZEF_GMM_SUBS_TIME_VARS  Swap GMM time_variables with zef.inv_time_* ('in'/'out').
%
%   Copyright © 2018- Joonas Lahtinen, Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef_GMM_subs_time_vars(char_var)
%
%   'in': stash inv_time_1/2/3 and inv_sampling_frequency, copy from
%   zef.GMM.time_variables. 'out': restore the stash. Uses evalin base.
%   Called around GMM fit/plot when the model carries its own time axis.
%
%   See also zef_GMModeling_K.

if evalin('base','isfield(zef.GMM,''time_variables'')')
    if evalin('base','~isempty(zef.GMM.time_variables)')
        if strcmp(char_var,'in')
            if evalin('base','isfield(zef.GMM.time_variables,''time_1'')')
                evalin('base','zef_temp_time_1 = zef.inv_time_1;');
                evalin('base','zef.inv_time_1 = zef.GMM.time_variables.time_1;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''time_2'')')
                evalin('base','zef_temp_time_2 = zef.inv_time_2;');
                evalin('base','zef.inv_time_2 = zef.GMM.time_variables.time_2;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''time_3'')')
                evalin('base','zef_temp_time_3 = zef.inv_time_3;');
                evalin('base','zef.inv_time_3 = zef.GMM.time_variables.time_3;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''sampling_frequency'')')
                evalin('base','zef_temp_sampling_frequency = zef.inv_sampling_frequency;');
                evalin('base','zef.inv_sampling_frequency = zef.GMM.time_variables.sampling_frequency;');
            end
        elseif strcmp(char_var,'out')
            if evalin('base','isfield(zef.GMM.time_variables,''time_1'')')
                evalin('base','zef.inv_time_1 = zef_temp_time_1; clear zef_temp_time_1;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''time_2'')')
                evalin('base','zef.inv_time_2 = zef_temp_time_2; clear zef_temp_time_2;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''time_3'')')
                evalin('base','zef.inv_time_3 = zef_temp_time_3; clear zef_temp_time_2;');
            end
            if evalin('base','isfield(zef.GMM.time_variables,''sampling_frequency'')')
                evalin('base','zef.inv_sampling_frequency = zef_temp_sampling_frequency; clear zef_temp_sampling_frequency;');
            end
        end
    end
end

end
