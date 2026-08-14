function [L, measurements] = zef_lead_field_scaling(lf_bank_index)
%ZEF_LEAD_FIELD_SCALING  Multiply L and measurements by the item scaling_factor.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [L, measurements] = zef_lead_field_scaling(lf_bank_index)
%
%   Reads lf_bank_storage{index}.scaling_factor from base (set when
%   adding an item). Does not assignin.
%   Description: Scaling.

L = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.L']);
measurements = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.measurements']);
scaling_factor = evalin('base',['zef.lf_bank_storage{' num2str(lf_bank_index) '}.scaling_factor']);

L = scaling_factor*L;
measurements = scaling_factor*measurements;

end
