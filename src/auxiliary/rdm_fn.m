function rdm = rdm_fn(La, Lfem)
%RDM_FN  Relative difference measure, one value per lead-field column.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   rdm = rdm_fn(La, Lfem)
%
%   Column-normalizes La and Lfem by Euclidean column norms, then
%   rdm(j) = ||Lfem(:,j)/||.|| - La(:,j)/||.||||_2. Used to compare an
%   analytic sphere field to FEM L. Not on the Zeffiro menu.
%
%   See also mag_fn, zef_lead_field_eeg_multilayer_sphere.

arguments
    La double
    Lfem double
end

scaled_Lfem = Lfem ./ repmat(sqrt(sum(Lfem.^2)), size(Lfem, 1), 1);
scaled_La = La ./ repmat(sqrt(sum(La.^2)), size(La, 1), 1);

diffs = scaled_Lfem - scaled_La;

rdm = sqrt(sum(diffs.^2))';

end
