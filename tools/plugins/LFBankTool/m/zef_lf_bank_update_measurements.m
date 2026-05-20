%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.lf_item_selected = get(zef — Zef.lf item selected = get(zef.
%
% Purpose:
%   Zef.lf item selected = get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.lf_bank_storage (read)
%   zef.lf_item_selected (read)
%   zef.measurements (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.lf_item_selected = get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




zef.lf_item_selected = get(zef.h_lf_item_list,'value');

for zef_i = 1:length(zef.lf_bank_storage)

    if ismember(zef_i,zef.lf_item_selected)

        zef.lf_bank_storage{zef_i}.measurements = zef.measurements;

    end

end

clear zef_i;

zef_update_lf_bank_tool;
