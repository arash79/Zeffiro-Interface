function s = zef_ui_num2str(v)
%ZEF_UI_NUM2STR  Convert a stored Zeffiro value to a widget string.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   App start scripts copy zef.* onto edit/dropdown Value. Those fields
%   are sometimes already char/string after another tool ran, and
%   num2str then errors. Numeric and logical values still go through
%   num2str; other types yield ''.
%
%   See also RAPMUSIC_start, CSM_app_start.

s = '';
if nargin < 1
    return
end
if isnumeric(v) || islogical(v)
    s = num2str(v);
elseif ischar(v)
    s = v;
elseif isstring(v)
    s = char(v);
end

end
