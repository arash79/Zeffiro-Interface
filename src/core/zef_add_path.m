function [folder_list] = zef_add_path(import_path,varargin)
% --- Zeffiro documentation header ---
% zef_add_path — Zef add path.
%
% Purpose:
%   Zef add path.
%   Folder: Application lifecycle: `zef_start`, `zef_init`, `zef_update`, `zef_close_all`, logging, waitbars, window layout—not the `+core` package.
%
% Inputs:
%   import_path
%   varargin
%
% Outputs:
%   folder_list
%
% Calls (project):
%   zef_add_path
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[folder_list] = zef_add_path(import_path, varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header


folder_list_aux = [];
subfolder_status = 0;
d = dir(import_path);
folder_list = cell(0);
if not(isempty(varargin))
    if isequal(varargin{1},1) || isequal(varargin{1},'recursive')
        subfolder_status = 1;
    end

    if length(varargin) > 1
        folder_list_aux = varargin{2};
        folder_list = folder_list_aux;
    end
end

for i = 1 : length(d)

    [a, b, c] = fileparts(d(i).name);
    if not(isempty(b))
        if not(isequal(b,'external')) && not(isequal(b(1),'+')) && not(isequal(b(1),'@'))
            if isequal(b,'.')
                b = '';
            end
            if length(dir([import_path filesep b])) > 1
                folder_list = [folder_list ; {[import_path filesep b]}];
            end
            if subfolder_status
                folder_list = [folder_list ; zef_add_path([import_path filesep b])];
            end
        end
    end

end


folder_list = unique(folder_list);


folder_list_aux = setdiff(folder_list,folder_list_aux);
for i = 1 : length(folder_list_aux)
    addpath(folder_list_aux{i});
end

end
