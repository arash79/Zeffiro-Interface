function lf_tag = lf_tag_from_lf_type( lf_type )
%LF_TAG_FROM_LF_TYPE Map lead-field type code to human-readable tag.
%
% LF_TAG = lf_tag_from_lf_type(LF_TYPE) returns the string tag corresponding
% to the lead field type code used by Zeffiro Interface plugins:
%   1 -> 'EEG', 2 -> 'MEG', 3 -> 'gMEG', 4 -> 'EIT', 5 -> 'tES'.
%
% Input:
%   lf_type - (1,1) double, mustBeMember([1, 2, 3, 4, 5])
%             Lead field type code (1=EEG, 2=MEG, 3=gMEG, 4=EIT, 5=tES).
%
% Output:
%   lf_tag  - (1,1) char
%             Human-readable tag (e.g. 'EEG', 'MEG').
%

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
