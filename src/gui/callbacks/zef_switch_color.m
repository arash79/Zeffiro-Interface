function [void] = zef_switch_color(tag_str_1,tag_str_2,variable_name)
%ZEF_SWITCH_COLOR  Red/black a linked control from a checkbox and a zef field.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Unused from menus. Only caller is zef_pushbutton_switch (legacy GUIDE
%   compartment pushbuttons), which itself has no first-party callers.
%   The mlapp Segmentation tool does not use these h_pushbutton* widgets.
%
%   [void] = zef_switch_color(tag_str_1, tag_str_2, variable_name)
%
%   Inputs
%     tag_str_1      - suffix of zef.h_<tag_str_1> (checkbox Value).
%     tag_str_2      - suffix of zef.h_<tag_str_2> (color target).
%     variable_name  - zef field name; empty while the switch is on → red.
%
%   Output
%     void  - always [].
%
%   Uses fontcolor when zef.mlapp==1, else foregroundcolor. evalin base.
%
%   See also zef_switch_onoff, zef_pushbutton_switch.

void = [];

mlapp_flag = evalin('base','zef.mlapp');
if mlapp_flag == 1
    color_str = 'fontcolor';
else
    color_str = 'foregroundcolor';
end

switch_val = get(evalin('base',['zef.h_' tag_str_1]),'value');
h=evalin('base',['zef.h_' tag_str_2]);
if switch_val
    if  isempty(evalin('base',['zef.' variable_name]));
        set(h,color_str,[1 0 0]);
    else
        set(h,color_str,[0 0 0]);
    end;
else
    set(h,color_str,[0 0 0]);
end
