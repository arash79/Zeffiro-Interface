function [struct_out] = zef_dataBank_text2struct(text)
%ZEF_DATABANK_TEXT2STRUCT  Build a struct with empty fields named by a cellstr.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Tiny helper: for each cell, struct_out.(text{i}) = []. No zef fields.
%   Not called from zef_open_dataBank or other first-party files in this
%   repository (kept for local/plugin use).
%
%   struct_out = zef_dataBank_text2struct(text)
%
%   Inputs
%     text  - cellstr of valid MATLAB field names.
%
%   Output
%     struct_out  - struct with those fields, each [].
%
%   See also zef_dataBank_sortTree.

struct_out=[];
for i=1:length(text)
    struct_out.(text{i})=[];
end

end
