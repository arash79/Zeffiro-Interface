%ZEF_MERGE_LEAD_FIELD  Vertically concatenate an external L onto zef.L.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Menu **Edit → Merge lead field with...** opens a *.mat
%   file, loads variable L, and if size(L,2)==size(zef.L,2) or zef.L is
%   empty, zef.L = [zef.L; L]. Column mismatch silently skips the append.

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
