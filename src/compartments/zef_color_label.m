function [void] = zef_color_label(tag_str)
%ZEF_COLOR_LABEL  Toggle compartment name label visibility in the figure tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Reads zef.<tag_str>_on and _visible from the base workspace and sets
%   zef.h_<tag_str>_label visibility and string when zef.h_zeffiro is valid.
%
%   zef_color_label(tag_str)
%
%   Input
%     tag_str - compartment tag without prefix (e.g. 'c1').
%
%   See also zef_update_fig_details.

void = [];

switch_val_1 = evalin('base',['zef.' tag_str '_on']);
switch_val_2 = evalin('base',['zef.' tag_str '_visible']);

if isvalid(evalin('base','zef.h_zeffiro'))
    if switch_val_1 & switch_val_2
        set(evalin('base',['zef.h_' tag_str '_label']),'visible','on');
        set(evalin('base',['zef.h_' tag_str '_label']),'string',evalin('base',['zef.' tag_str '_name']));
    else
        set(evalin('base',['zef.h_' tag_str '_label']),'visible','off');
        set(evalin('base',['zef.h_' tag_str '_label']),'string',evalin('base',['zef.' tag_str '_name']));
    end
end
