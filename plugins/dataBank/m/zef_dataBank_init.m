function zef = zef_dataBank_init(zef)
%ZEF_DATABANK_INIT  Default Combine-panel times, sampling frequency, and workingHashes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_open_dataBank after zef_dataBank_app is created. Ensures
%   zef.dataBank.var_starttime, var_endtime, var_sampling_frequency, and
%   workingHashes exist, then copies those scalars onto StarttimeSpinner,
%   EndtimeSpinner, and SfreqSpinner. Sampling frequency defaults to
%   zef.inv_sampling_frequency. Does not invert or touch the tree.
%
%   zef = zef_dataBank_init(zef)
%
%   Inputs
%     zef  - session with zef.dataBank.app already set. nargin==0 → base.
%
%   Output
%     zef  - var_* and spinner Values filled. nargout==0 → assignin base.
%
%   See also zef_open_dataBank, zef_dataBank_update.

if nargin == 0
    zef = evalin('base','zef')
end

if not(isfield(zef.dataBank,'var_starttime'))
    zef.dataBank.var_starttime = 0;
end

if not(isfield(zef.dataBank,'var_endtime'))
    zef.dataBank.var_endtime = 0;
end

if not(isfield(zef.dataBank,'workingHashes'))
    zef.dataBank.workingHashes =cell(0);
end


if not(isfield(zef.dataBank,'var_sampling_frequency'))
    zef.dataBank.var_sampling_frequency = zef.inv_sampling_frequency;
end

zef.dataBank.app.StarttimeSpinner.Value = zef.dataBank.var_starttime;
zef.dataBank.app.EndtimeSpinner.Value = zef.dataBank.var_endtime;
zef.dataBank.app.SfreqSpinner.Value = zef.dataBank.var_sampling_frequency;

if nargout == 0
    assignin('base','zef',zef);
end

end
