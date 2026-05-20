%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isempty(zef.save_file_path)) & not(zef — If not(isempty(zef.save file path)) & not(zef.
%
% Purpose:
%   If not(isempty(zef.save file path)) & not(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.file (read)
%   zef.file_path (read)
%   zef.file_type (read, write)
%   zef.raw_data (read, write)
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
    [zef.file zef.file_path zef.file_type] = uigetfile({'*.mat','*.dat'},'Import',zef.save_file_path);
else
    [zef.file zef.file_path zef.file_type] = uigetfile({'*.mat','*.dat'},'Import');
end
if not(isequal(zef.file,0));
    if zef.file_type == 1
        [zef.raw_data] = struct2cell(load([zef.file_path zef.file]));
        zef.raw_data = zef.raw_data{1};
    else
        [zef.raw_data] = load([zef.file_path zef.file]);
    end
end
