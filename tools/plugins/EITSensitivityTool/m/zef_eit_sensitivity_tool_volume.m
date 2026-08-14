function tilavuus_vec = zef_eit_sensitivity_tool_volume
%ZEF_EIT_SENSITIVITY_TOOL_VOLUME  Tetra volumes accumulated on EIT source indices.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   tilavuus_vec = zef_eit_sensitivity_tool_volume
%
%   Reads zef.nodes, tetra, eit_ind, brain_ind, eit_count from base.
%   zef_tetra_volume then accumarray. Used when substituting a
%   volume-weighted sensitivity. Does not write reconstruction.
%
%   See also zef_eit_sensitivity_tool_substitute.

nodes = evalin('base','zef.nodes');
tetrahedra = evalin('base','zef.tetra');

tilavuus = zef_tetra_volume(nodes, tetrahedra, true);
tilavuus = tilavuus(:);
tilavuus_vec = accumarray(evalin('base','zef.eit_ind'),tilavuus(evalin('base','zef.brain_ind')),[size(evalin('base','zef.eit_count'),1) 1]);
