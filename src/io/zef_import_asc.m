function [c_1] = zef_import_asc(c_0,varargin)
%ZEF_IMPORT_ASC  Parse one line of FreeSurfer-style ASCII numeric data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Converts a character line with str2num and returns columns 1:3 by
%   default, or columns n_1:n_2 when two extra arguments are given.
%
%   c_1 = zef_import_asc(c_0)
%   c_1 = zef_import_asc(c_0, n_1, n_2)
%
%   Inputs
%     c_0  - character vector or string from one file line.
%     n_1  - first column index (optional).
%     n_2  - last column index (optional).
%
%   Output
%     c_1 - numeric matrix of selected columns.
%
%   See also zef_import_segmentation_legacy, zef_import_parcellation_points.

c_1 = str2num(c_0);

n_varargin = length(varargin);
if n_varargin == 2
    n_1 = varargin{1};
    n_2 = varargin{2};
    c_1 = c_1(:,n_1:n_2);
else
    c_1 = c_1(:,1:3);
end

end
