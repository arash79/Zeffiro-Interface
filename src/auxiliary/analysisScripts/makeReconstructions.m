%MAKERECONSTRUCTIONS  Lab script: MNE/CSM/RAMUS/dipole/beamformer → databank.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Runs those inverse functions on the current zef (L +
%   measurements already set) and zef_dataBank_addButtonPress after each.
%   Beamformer branch uses zef.beamformer.estimation_attr.Value. One-off
%   paper helper; plugins must already be initialized.
%

[zef.reconstruction, zef.reconstruction_information]=zef_find_mne_reconstruction;
zef_dataBank_addButtonPress;

%sLoreta

[zef.reconstruction, zef.reconstruction_information]=zef_CSM_iteration;
zef_dataBank_addButtonPress;

%ramus
zef_update_ramus_inversion_tool;
[zef.reconstruction, zef.reconstruction_information]  = zef_ramus_iteration([]);
zef_dataBank_addButtonPress;

%dipole
[zef.reconstruction, zef.reconstruction_information]=zef_dipoleScan;
zef_dataBank_addButtonPress;

%beamformer
if strcmp(zef.beamformer.estimation_attr.Value,'1')
    [zef.reconstruction,~, zef.reconstruction_information] = zef_beamformer;
elseif strcmp(zef.beamformer.estimation_attr.Value,'2')
    [~,zef.reconstruction, zef.reconstruction_information] = zef_beamformer;
else; [zef.reconstruction,zef.bf_var_loc, zef.reconstruction_information] = zef_beamformer;
end
zef_dataBank_addButtonPress;
