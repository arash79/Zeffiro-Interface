function [posOri, magnetometerLabel, gradiometerLabel, tra] = getMagnetometerPositions(MEGdata, OptionalName, OptionalPlace, OptionalSave1or0)
% --- Zeffiro documentation header ---
% getMagnetometerPositions — Get Magnetometer Positions.
%
% Purpose:
%   Get Magnetometer Positions.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   MEGdata
%   OptionalName
%   OptionalPlace
%   OptionalSave1or0
%
% Outputs:
%   posOri
%   magnetometerLabel
%   gradiometerLabel
%   tra
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[posOri, magnetometerLabel, gradiometerLabel]] = getMagnetometerPositions(MEGdata, OptionalName, OptionalPlace, OptionalSave1or0)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if nargin==1
    OptionalSaveToFile0or1=1;
    OptionalName='magnetometer';
    OptionalPlace='';
end

if nargin==2
    OptionalSaveToFile0or1=1;
    OptionalPlace='';
end

if nargin==3
    OptionalSaveToFile0or1=1;
end

tra=MEGdata.grad.tra;

posOri=horzcat(MEGdata.grad.coilpos, MEGdata.grad.coilori);

gradiometerLabel=MEGdata.grad.label;

magnetometerLabel=cell(587,1);

for i=1:271
    %for the regular gradiometers, it is grad(i)=mag(i)+mag(i+271)

    magnetometerLabel{i}=strcat(gradiometerLabel{i}, '_mag1');
    magnetometerLabel{i+271}=strcat(gradiometerLabel{i}, '_mag2');
end

i=543;
for j=272:298
    %for the references, coils seem to be positioned consecutively

    if strcmp(MEGdata.grad.chantype{j}, 'refmag')
        magnetometerLabel{i}=gradiometerLabel{j};
        i=i+1;
    end

    if strcmp(MEGdata.grad.chantype{j}, 'refgrad')
        magnetometerLabel{i}=strcat(gradiometerLabel{j}, '_mag1');
        magnetometerLabel{i+1}=strcat(gradiometerLabel{j}, '_mag2');

        i=i+2;
    end

end

%some coils are only used for higher order gradiometers or other things
%we will ignore these coils later, so we cut them out and do not
%calculate leadfields for them

index=find(tra(1,:));

index=horzcat(1:271*2, index(3:end)); %the first 271*2 coils are for measurement, the rest as ref

posOri=posOri(index, :);
gradiometerLabel=gradiometerLabel(1:271);
tra=tra(1:271, index);
magnetometerLabel=magnetometerLabel(index);

%
%
if OptionalSaveToFile0or1

    name=strcat(OptionalPlace, OptionalName, '_');

    disp(strcat({'writing data to '}, name, '*.dat'));

    writecell(magnetometerLabel, strcat(name, 'magnetometerLabel.dat')) ;
    writecell(gradiometerLabel, strcat(name, 'gradiometerLabel.dat'));
    writematrix(tra, strcat(name, 'tra.dat')) ;
    writematrix(posOri, strcat(name, 'posOri.dat')) ;
end
%

end
