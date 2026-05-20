%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isempty(zef.save_file_path)) & not(zef — If not(isempty(zef.save file path)) & not(zef.
%
% Purpose:
%   If not(isempty(zef.save file path)) & not(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.L (read, write)
%   zef.aux (read, write)
%   zef.file (read)
%   zef.file_path (read)
%   zef.save_file_path (read)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `if not(isempty(zef.save_file_path)) & not(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
    [zef.file zef.file_path] = uigetfile('*.mat','Merge lead field with...',zef.save_file_path);
else
    [zef.file zef.file_path] = uigetfile('*.mat','Merge lead field with...');
end
if not(isequal(zef.file,0));
    zef.aux = load([zef.file_path zef.file], 'L');
    if size(zef.aux.L,2) == size(zef.L,2) || isempty(zef.L)
        zef.L = [zef.L ; zef.aux.L];
    end
    zef = rmfield(zef,'aux');
end
