function zef = zef_start_log(zef)
%ZEF_START_LOG  Open a rotating session log file under data/log/.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   When zef.use_log is true, creates data/log if needed, names a new
%   *.log file, deletes the oldest *.log files so at most
%   zef.max_n_log_files remain after the new file is opened, and writes a
%   banner with version, date, and path. Non-log files (this tree's
%   README) are ignored. Always stores the current log path on
%   zef.h_zeffiro_menu.ZefCurrentLogFile (adding the dynamic property if
%   missing), even when logging is off.
%
%   Input / output
%     zef  - session; current_log_file is set when logging is enabled.
%
%   See also zef_start.


if zef.use_log
    log_dir_path = [zef.program_path filesep 'data' filesep 'log'];
    if not(exist(log_dir_path,'dir'))
        mkdir(log_dir_path);
    end

    log_files = dir(fullfile(log_dir_path, '*.log'));
    n_files = numel(log_files);
    zef.current_log_file = fullfile(log_dir_path, ...
        [zef.zeffiro_log_file_name '_' num2str(n_files + 1) '.log']);
    if n_files >= zef.max_n_log_files
        date_info_cell = {log_files.datenum}';
        date_info_array = zeros(n_files,6);
        for i = 1 : n_files
            date_info_array(i,:) = datevec(date_info_cell{i});
        end
        [~,I] = sortrows(date_info_array);
        for i = 1 : n_files - zef.max_n_log_files + 1
            delete(fullfile(log_dir_path, log_files(I(i)).name));
        end
    end
    fid = fopen(zef.current_log_file,'a');
    fprintf(fid,'%s',['**************************************************************************' newline]);
    fprintf(fid,'%s',['ZEFFIRO Interface ' num2str(zef.current_version) ', Date: ' datestr(now) newline]);
    fprintf(fid,'%s',['**************************************************************************' newline] );
    fprintf(fid,'%s',['Path: ' zef.program_path newline]);
    fprintf(fid,'%s',['**************************************************************************' newline]);
    fclose(fid);
end

if not(ismember('ZefCurrentLogFile',properties(zef.h_zeffiro_menu)))
    addprop(zef.h_zeffiro_menu,'ZefCurrentLogFile');
end
zef.h_zeffiro_menu.ZefCurrentLogFile = zef.current_log_file;

end
