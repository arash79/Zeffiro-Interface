function tf = zef_sensor_set_is_electrodes(zef, tag)
%ZEF_SENSOR_SET_IS_ELECTRODES  True for an EEG, EIT, or TES sensor set.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Electrode sets share one presentation. MEG and other vector-field sets
%   do not: their stored channel names are the labels.
%
%   tf = zef_sensor_set_is_electrodes(zef, tag)

tf = false;
if nargin < 2 || ~isstruct(zef) || isempty(tag)
    return
end
name = '';
field = [tag '_imaging_method_name'];
if isfield(zef, field) && ~isempty(zef.(field))
    name = char(string(zef.(field)));
end
tf = any(strcmpi(name, {'EEG', 'EIT', 'TES', 'tES', 'Scalar field'}));

end
