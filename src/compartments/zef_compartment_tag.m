function compartment_tag = zef_compartment_tag(zef)
%ZEF_COMPARTMENT_TAG  Generate an unused compartment tag name.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Increments c1, c2, ... until the tag is not already in
%   zef.compartment_tags.
%
%   compartment_tag = zef_compartment_tag(zef)
%
%   Input
%     zef - session struct with compartment_tags cell array.
%
%   Output
%     compartment_tag - new tag string of the form 'cN'.
%
%   See also zef_create_compartment.

ismember_tag = 1;
compartment_counter = 0;

while ismember_tag

    compartment_counter = compartment_counter + 1;
    compartment_tag = ['c' num2str(compartment_counter)];
    ismember_tag = ismember(compartment_tag,eval('zef.compartment_tags'));

end

end
