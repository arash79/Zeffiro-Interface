%ZEF_LEADFIELDPROCESSINGTOOL_LOADTRA  uigetfile a *.dat transformation matrix.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. loadTraButton. Stores path/name on the tool struct and
%   readmatrix → zef.LeadFieldProcessingTool.tra. Mag2Grad multiplies
%   checked bank L by this matrix.
%
%   See also zef_LeadfieldProcessingTool_mag2Grad.

[zef.LeadFieldProcessingTool.traName, zef.LeadFieldProcessingTool.traPath]=uigetfile('./', 'select tra file', '*.dat');

zef.LeadFieldProcessingTool.tra=readmatrix(strcat(zef.LeadFieldProcessingTool.traPath, zef.LeadFieldProcessingTool.traName));
