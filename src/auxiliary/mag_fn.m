function mag = mag_fn(La, Lfem)
%MAG_FN  Magnitude error 1 - ||Lfem|| / ||La|| per column.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   mag = mag_fn(La, Lfem)
%
%   Column Euclidean norms; no scaling of the matrices first. Typical
%   pair: analytic La vs FEM Lfem. Not on the menu.
%
%   See also rdm_fn, zef_lead_field_eeg_multilayer_sphere.

mag = 1 - sqrt(sum(Lfem.^2))' ./ sqrt(sum(La.^2))';
end
