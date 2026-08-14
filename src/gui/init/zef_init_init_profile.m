%ZEF_INIT_INIT_PROFILE  Apply zef.init_profile rows into zef (script).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Each init_profile row: column 3 is the zef field name,
%   column 2 the value, column 4 the type — 'string' (quoted assign),
%   'number' (eval assign), or 'evaluate' (eval the value as MATLAB).
%   Called from zef_apply_init_profile after Settings → Pre-settings
%   profile Apply. Does not open the dialog.
%
%   See also zef_open_init_profile, zef_apply_init_profile.
for zef_i = 1 : size(zef.init_profile,1)

    if not(isstring(zef.init_profile{zef_i,2}))
        zef.init_profile{zef_i,2} = num2str(zef.init_profile{zef_i,2});
    end

    if isequal(zef.init_profile{zef_i,4},'string')
        eval(['zef.' zef.init_profile{zef_i,3} '= ''' zef.init_profile{zef_i,2}  ''';']);
    elseif isequal(zef.init_profile{zef_i,4},'number')
        eval(['zef.' zef.init_profile{zef_i,3} '= ' zef.init_profile{zef_i,2}  ';']);
    elseif isequal(zef.init_profile{zef_i,4},'evaluate')
        eval(zef.init_profile{zef_i,2});
    end

end

clear zef_i;
