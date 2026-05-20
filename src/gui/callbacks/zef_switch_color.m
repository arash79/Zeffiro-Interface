%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [void] = zef_switch_color(tag_str_1,tag_str_2,variable_name)
% --- Zeffiro documentation header ---
% zef_switch_color — Zef switch color.
%
% Purpose:
%   Zef switch color.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   tag_str_1
%   tag_str_2
%   variable_name
%
% Outputs:
%   void
%
% Zef fields (observed):
%   zef.h_ (read)
%   zef.mlapp (read)
%
% Calls (project):
%   zef_switch_color
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[void] = zef_switch_color(tag_str_1, tag_str_2, variable_name)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
