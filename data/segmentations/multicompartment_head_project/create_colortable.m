%CREATE_COLORTABLE  Save FreeSurfer aparc annotation tables as .mat color tables.
%
%   Zeffiro Interface helper for the bundled multicompartment head sample.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Requires dir_name in the workspace (FreeSurfer subject directory
%   containing label/). Calls read_annotation for lh/rh aparc.a2009s and
%   aparc, then saves color_table_{lh,rh}_{76,36}.mat with colortable,
%   label, and vertices. The .annot reader in this folder is FreeSurfer's
%   Read_Brain_Annotation (MGH copyright), not a Zeffiro function.
%
%   Workspace
%     dir_name  - path to a FreeSurfer subject directory.
%
%   See also Read_Brain_Annotation.

[vertices,label,colortable]=read_annotation([dir_name '/label/lh.aparc.a2009s.annot']);
save color_table_lh_76.mat colortable label vertices;
[vertices,label,colortable]=read_annotation([dir_name '/label/rh.aparc.a2009s.annot']);
save color_table_rh_76.mat colortable label vertices;
[vertices,label,colortable]=read_annotation([dir_name '/label/lh.aparc.annot']);
save color_table_lh_36.mat colortable label vertices;
[vertices,label,colortable]=read_annotation([dir_name '/label/rh.aparc.annot']);
save color_table_rh_36.mat colortable label vertices;
