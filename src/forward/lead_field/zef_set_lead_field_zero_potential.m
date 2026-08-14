function out_L = zef_set_lead_field_zero_potential( ...
    in_L, ...
    in_electrodes ...
    )

%ZEF_SET_LEAD_FIELD_ZERO_POTENTIAL  Mean-zero electrode constraint R*L, R = I - 11'/n.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   EEG FEM currently subtracts mean(L,1) in place rather than calling this.
%   n_electrodes is size(in_electrodes,1), so pass the electrode table (or
%   any array whose first dimension is the sensor count).
%
%   out_L = zef_set_lead_field_zero_potential(in_L, in_electrodes)
%
%   See also zef_lead_field_eeg_fem.


arguments
    in_L double
    in_electrodes double
end

n_of_electrodes = size(in_electrodes, 1);

zero_potential_setter = ...
    eye(n_of_electrodes,n_of_electrodes) ...
    - ...
    (1/n_of_electrodes) ...
    * ...
    ones(n_of_electrodes,n_of_electrodes) ...
    ;

out_L = zero_potential_setter * in_L;

end
