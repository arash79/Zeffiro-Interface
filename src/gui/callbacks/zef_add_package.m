function zef_add_package(package_path, package_folder, file_folder, file_folder_dir)
% --- Zeffiro documentation header ---
% zef_add_package — Zef add package.
%
% Purpose:
%   Zef add package.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   package_path
%   package_folder
%   file_folder
%   file_folder_dir
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   zef_add_package
%   zef_read_function_call
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_add_package(package_path, package_folder, file_folder, file_folder_dir)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if not(isempty(package_folder))
    mkdir([package_path filesep '+' package_folder]);
    package_path = [package_path filesep '+' package_folder];
end

if nargin == 3
    file_folder_dir = dir(file_folder);
end

for k = 1 : length(file_folder_dir)

    fnc_str = '';
    fnc_name = '';
    fnc_call = '';
    if   not(ismember(file_folder_dir(k).name,{'.','..'})) && not(isempty(file_folder_dir(k).name))
        [~,file_name,file_ext] = fileparts(file_folder_dir(k).name);

        if isequal(file_ext,'.m')

            [fnc_call,fnc_str,fnc_name] = zef_read_function_call([file_folder_dir(k).folder filesep file_folder_dir(k).name]);

            if  not(isempty(fnc_name)) && not(isempty(fnc_call))

                fid = fopen([package_path filesep fnc_name '.m'],'w');
                if not(isempty(fnc_str))
                    fprintf(fid,[fnc_str '\n' fnc_call ';' '\n' 'end']);
                else
                    fprintf(fid,[fnc_call ';\n']);
                end
                fclose(fid);
                fprintf([file_name file_ext '\n'],'%s')

            end

        elseif isfolder([file_folder filesep file_folder_dir(k).name]) &&  not(ismember('+',file_folder_dir(k).name))

            zef_add_package(package_path, file_folder_dir(k).name, [file_folder filesep file_folder_dir(k).name]);

        end

    end
end
end
