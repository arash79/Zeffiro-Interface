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
%   zef.h_lf_item_list (read)
%   zef.lf_bank_storage (read, write)
%   zef.lf_item_list (read, write)
%   zef.lf_item_selected (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.lf_item_selected = get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




zef.lf_item_selected = get(zef.h_lf_item_list,'value');

zef_j = 0;
for zef_i = 1 : length(zef.lf_bank_storage)
    if not(ismember(zef_i,zef.lf_item_selected))
        zef_j = zef_j + 1;
        zef.lf_bank_storage{zef_j} =  zef.lf_bank_storage{zef_i};
        zef.lf_item_list{zef_j} = zef.lf_item_list{zef_i};
    end
end

zef.lf_item_list = zef.lf_item_list(1:zef_j);
zef.lf_bank_storage = zef.lf_bank_storage(1:zef_j);
zef.lf_item_selected = [];

clear zef_i zef_j;

zef_update_lf_bank_tool;
zef_update;

zef.lf_item_selected = get(zef.h_lf_item_list,'value');
