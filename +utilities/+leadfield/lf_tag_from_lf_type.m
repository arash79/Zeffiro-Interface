function lf_tag = lf_tag_from_lf_type( lf_type )
%LF_TAG_FROM_LF_TYPE  Map isotropic lead_field_type 1–5 to a sensor tag.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   1 EEG, 2 MEG, 3 gMEG, 4 EIT, 5 tES. mustBeMember rejects 6–10
%   (anisotropic twins of 1–5) and any other code. No first-party caller;
%   src/forward uses numeric zef.lead_field_type directly.
%
%   lf_tag = lf_tag_from_lf_type(lf_type)

arguments

    lf_type (1,1) double { mustBeMember( lf_type, [1, 2, 3, 4, 5] ) }

end

if lf_type == 1

    lf_tag = 'EEG' ;

elseif lf_type == 2

    lf_tag = 'MEG' ;

elseif lf_type == 3

    lf_tag = 'gMEG' ;

elseif lf_type == 4

    lf_tag = 'EIT' ;

elseif lf_type == 5

    lf_tag = 'tES' ;

else

    error ( "Unknown lead field type " + lf_type + ". Must be one of 1, 2, 3, 4 or 5." ) ;

end

end % function
