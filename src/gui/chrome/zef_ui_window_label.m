function label = zef_ui_window_label(name)
%ZEF_UI_WINDOW_LABEL  Short window title for menus and the shell flyout.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Strips the shared "ZEFFIRO Interface:" prefix and a trailing singleton
%   index (" 1") that MATLAB / zef_fig_num used to append to every tool.

label = '';
if nargin < 1 || isempty(name)
    return
end
label = strtrim(char(string(name)));
label = regexprep(label, '^ZEFFIRO Interface:\s*', '');
label = regexprep(label, '\s+1$', '');
label = strtrim(label);

end
