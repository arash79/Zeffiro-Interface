%CREATE_POINTS  Convert FreeSurfer label ASCII tables to point .dat files.
%
%   Zeffiro Interface helper for the bundled multicompartment head sample.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Must be run from this folder. Loads lh/rh *_labels_76.asc and
%   *_labels_36.asc, drops the first two header rows, keeps columns 1–4,
%   and writes lh_point_76.dat, rh_point_76.dat, lh_point_36.dat.
%
%   Notes
%     The last two save commands both write lh_point_36.dat (including the
%     rh 36-label table). That overwrite is in the original script; do not
%     treat rh_point_36.dat as produced here.
%
%   See also creat_points, create_colortable.

a = load ('lh_labels_76.asc');
c = a([3:end],[1:4]);
save lh_point_76.dat c
b = load ('rh_labels_76.asc');
d = b([3:end],[1:4]);
save rh_point_76.dat d
e = load ('lh_labels_36.asc');
f = e([3:end],[1:4]);
save lh_point_36.dat f
g = load ('lh_labels_36.asc');
h = g([3:end],[1:4]);
save lh_point_36.dat h
i = load ('rh_labels_36.asc');
j = i([3:end],[1:4]);
save lh_point_36.dat j
