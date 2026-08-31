function [size1, size2] = zef_size(data, field)
%ZEF_SIZE  First two dimensions of data.(field), without loading a matfile.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Data Bank table helper (zef_databank_showAll). If data is an object
%   (matfile when save2disk is On), uses size(data, field) so the array is
%   not loaded. If data is a struct, uses size(data.(field)). Only the
%   first two dimensions are returned.
%
%   [size1, size2] = zef_size(data, field)
%
%   Inputs
%     data   - node payload struct or matfile object.
%     field  - char name ('L', 'measurements', 'reconstruction').
%
%   Output
%     size1, size2  - sizeOfField(1) and sizeOfField(2).
%
%   See also zef_databank_showAll.

if isobject(data)
    sizeOfField=size(data, field);
else
    sizeOfField=size(data.(field));
end

size1=sizeOfField(1);
size2=sizeOfField(2);

end
