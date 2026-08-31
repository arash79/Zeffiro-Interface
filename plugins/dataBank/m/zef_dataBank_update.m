function zef = zef_dataBank_update(zef)
%ZEF_DATABANK_UPDATE  Copy Combine-panel spinners onto zef.dataBank.var_*.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   ValueChangedFcn of StarttimeSpinner, EndtimeSpinner, and SfreqSpinner
%   in zef_open_dataBank. combineButton reads those var_* fields when it
%   calls combineLeadFields. Does not invert or touch the tree.
%
%   zef = zef_dataBank_update(zef)
%
%   Inputs
%     zef  - session with the three spinners. nargin==0 → base.
%
%   Output
%     zef  - var_starttime, var_endtime, var_sampling_frequency set.
%            nargout==0 → assignin base.
%
%   See also zef_dataBank_init, zef_dataBank_combineLeadFields.

if nargin == 0
    zef = evalin('base','zef')
end

zef.dataBank.var_starttime = zef.dataBank.app.StarttimeSpinner.Value;
zef.dataBank.var_endtime = zef.dataBank.app.EndtimeSpinner.Value;
zef.dataBank.var_sampling_frequency = zef.dataBank.app.SfreqSpinner.Value;

if nargout == 0
    assignin('base','zef',zef);
end

end
