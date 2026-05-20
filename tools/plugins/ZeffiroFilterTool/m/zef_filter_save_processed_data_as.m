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
%   zef.filter_save_file (read)
%   zef.filter_save_file_path (read)
%   zef.processed_data (read)
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
    [zef.file zef.file_path] = uiputfile('*.mat','Save processed data as...',[zef.filter_save_file_path zef.filter_save_file]);
else
    [zef.file zef.file_path] = uiputfile('*.mat','Save processed data as...');
end
if not(isequal(zef.file,0));

    zef_data = zef.processed_data;
    save([zef.file_path zef.file],'zef_data','-v7.3');
    clear zef_data;

end
