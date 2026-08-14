function [reconstruction,reconstruction_information] = zef_reconstructionTool_import
%ZEF_RECONSTRUCTIONTOOL_IMPORT  uigetfile *.mat expecting those two variables.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [reconstruction, reconstruction_information] = zef_reconstructionTool_import
%
%   ImportButton loads into this workspace. If reconstruction_information
%   is still empty after load, sets .tag to the file name. Starting
%   folder './'. The start script assigns the outputs onto
%   zef.reconstruction / zef.reconstruction_information then refresh;
%   this function does not write zef itself. Cancelled uigetfile yields
%   empty outputs (load of '0' + filename).
%
%   See also zef_reconstructionTool_addCurrent2bank, zef_reconstructionTool_refresh.

[importName, importPath]=uigetfile('./', 'select reconstruction file', '*.mat');

reconstruction_information=[];
reconstruction=[];

load(strcat(importPath, importName)
);

if isempty(reconstruction_information)
    reconstruction_information.tag=importName;
end

end
