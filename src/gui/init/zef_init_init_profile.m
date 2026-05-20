% --- Zeffiro documentation header ---
% for zef_i = 1 : size(zef — For zef i = 1 : size(zef.
%
% Purpose:
%   For zef i = 1 : size(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.init_profile (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `for zef_i = 1 : size(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

for zef_i = 1 : size(zef.init_profile,1)

    if not(isstring(zef.init_profile{zef_i,2}))
        zef.init_profile{zef_i,2} = num2str(zef.init_profile{zef_i,2});
    end

    if isequal(zef.init_profile{zef_i,4},'string')
        eval(['zef.' zef.init_profile{zef_i,3} '= ''' zef.init_profile{zef_i,2}  ''';']);
    elseif isequal(zef.init_profile{zef_i,4},'number')
        eval(['zef.' zef.init_profile{zef_i,3} '= ' zef.init_profile{zef_i,2}  ';']);
    elseif isequal(zef.init_profile{zef_i,4},'evaluate')
        eval(zef.init_profile{zef_i,2});
    end

end

clear zef_i;
