function [folder_list] = zef_add_path(import_path,varargin)
%ZEF_ADD_PATH  Recursively addpath folders, skipping packages and external/.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Walks import_path with dir(), skipping names that are empty, "external",
%   or start with + or @ (MATLAB packages/classes must not be addpath'd).
%   Unique folders are addpath'd; an optional accumulator avoids re-adding.
%
%   folder_list = zef_add_path(import_path)
%   folder_list = zef_add_path(import_path, recursive)
%   folder_list = zef_add_path(import_path, recursive, folder_list_aux)
%
%   Inputs
%     import_path     - root directory to scan.
%     varargin{1}     - 1 or 'recursive' to descend into subfolders.
%     varargin{2}     - existing cell list of folders already on the path;
%                       only the setdiff is addpath'd.
%
%   Output
%     folder_list  - unique cell column of folder paths discovered (including
%                    those already in varargin{2}).
%
%   See also zeffiro_interface.


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
