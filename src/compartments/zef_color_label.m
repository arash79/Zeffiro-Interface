%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function [void] = zef_color_label(tag_str)
% --- Zeffiro documentation header ---
% zef_color_label — Zef color label.
%
% Purpose:
%   Zef color label.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   tag_str
%
% Outputs:
%   void
%
% Zef fields (observed):
%   zef.h_ (read)
%   zef.h_zeffiro (read)
%
% Calls (project):
%   zef_color_label
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[void] = zef_color_label(tag_str)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
