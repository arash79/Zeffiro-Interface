function code = imaging_method_for(modality)
%IMAGING_METHOD_FOR  Zeffiro imaging_method code for EEG or MEG.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    code = 1;
    if strcmp(modality, 'MEG')
        code = 2;
    end
end
