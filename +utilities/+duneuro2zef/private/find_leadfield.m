function lf = find_leadfield(raw, modality)
%FIND_LEADFIELD  Locate an EEG or MEG lead-field array on a DUNEuro struct.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    lf = [];
    if strcmp(modality, 'eeg')
        names = {'eegL', 'LF_EEG', 'eeg_lf', 'eeg_leadfield'};
    else
        names = {'megL', 'LF_MEG', 'meg_lf', 'meg_leadfield'};
    end
    lf = find_named(raw, names, 2);
    if isempty(lf) && isfield(raw, 'lf') && strcmp(modality, 'eeg')
        lf = raw.lf;
    end
end
