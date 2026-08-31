%ZEF_FILTER_SAVE_PROCESSED_DATA_AS  Save processed data as a .mat.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_filter_save_processed_data. uiputfile
%   '*.mat'. save(..., 'zef_data') where zef_data is processed_data
%   (-v7.3). Does not run the pipeline; Plot / Substitute already did
%   if the user pressed those first.
%
%   See also zef_filter_raw_data, zef_filter_save_as.

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
