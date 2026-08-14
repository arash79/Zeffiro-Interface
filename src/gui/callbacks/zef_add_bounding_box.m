function zef = zef_add_bounding_box(zef,name_str)
%ZEF_ADD_BOUNDING_BOX  Add a hidden outer-box compartment (PML / domain box).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Not a Segmentation-table menu. Callers: zef_import_segmentation when
%   a row type is 'box', and utilities.brainstorm2zef.zef_bst_create_project.
%   The box is a compartment with sources −1 (PML / inactive-for-sources),
%   visible 0, merge 0, so meshing can close the domain without showing it.
%
%   What it does
%     1. zef_add_compartment prepends a new tag (tags{1}).
%     2. Sets that tag's name (default 'Box'), sources −1, visible 0, merge 0.
%     3. Rotates tags so the new one is last: tags = [tags(2:end) tags(1)].
%        With the reversed compartment table, last tag is table row 1 (top).
%     4. zef_build_compartment_table.
%
%   zef = zef_add_bounding_box(zef)
%   zef = zef_add_bounding_box(zef, name_str)
%   zef_add_bounding_box          % nargout 0 → assignin base
%
%   Inputs
%     zef       - session. Omitted → evalin('base','zef').
%     name_str  - compartment name. Default 'Box'.
%
%   Output
%     zef  - session with the extra compartment and rebuilt table.
%
%   See also zef_add_compartment, zef_import_segmentation.

if nargin == 0
    zef = evalin('base','zef');
end

if nargin < 2
    name_str = 'Box';
end

zef = zef_add_compartment(zef);
zef.([zef.compartment_tags{1} '_name']) = name_str;
zef.([zef.compartment_tags{1} '_sources']) = -1;
zef.([zef.compartment_tags{1} '_visible']) = 0;
zef.([zef.compartment_tags{1} '_merge']) = 0;

% New tag was prepended; move it to the end so it sits as table row 1.
zef.compartment_tags = [zef.compartment_tags(2:end) zef.compartment_tags(1)];
zef = zef_build_compartment_table(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
