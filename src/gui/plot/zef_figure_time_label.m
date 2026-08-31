function zef_figure_time_label(h_fig, str)
%ZEF_FIGURE_TIME_LABEL  Set the Figure-tool time caption without extra axes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Historical plotters created a dummy axes tagged image_details at a
%   figure-normalized y=0.95, which sat on top of the chrome. The caption
%   lives on the time_text control inside the figure card.
%
%   zef_figure_time_label(h_fig, str)
%
%   See also zef_figure_sync_plot, zef_figure_tool_layout.

if nargin < 1 || isempty(h_fig) || ~isgraphics(h_fig) || ~isvalid(h_fig)
    return
end
if nargin < 2
    str = '';
end
str = char(string(str));
old = findall(h_fig, 'Tag', 'image_details');
for i = 1:numel(old)
    try
        if isgraphics(old(i)) && isvalid(old(i)) ...
                && any(strcmpi(char(old(i).Type), {'axes', 'uiaxes'}))
            delete(old(i));
        end
    catch
    end
end
tt = findall(h_fig, 'Tag', 'time_text');
if isempty(tt) || ~isvalid(tt(1))
    return
end
try
    set(tt(1), 'String', str);
    if isempty(strtrim(str))
        set(tt(1), 'Visible', 'off');
    else
        set(tt(1), 'Visible', 'on');
    end
catch
end

end
