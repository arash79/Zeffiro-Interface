function [posOri, magnetometerLabel, gradiometerLabel, tra] = getMagnetometerPositions(MEGdata, OptionalName, OptionalPlace, OptionalSave1or0)
%GETMAGNETOMETERPOSITIONS  CTF-style MEG coils from MEGdata.grad (FieldTrip).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [posOri, magLabel, gradLabel, tra] = getMagnetometerPositions(MEGdata)
%   [posOri, magLabel, gradLabel, tra] = getMagnetometerPositions(..., name, place, saveFlag)
%
%   posOri = [coilpos coilori]. Assumes 271 measurement gradiometers plus
%   refmag/refgrad in chantype 272:298. Keeps first 542 coils plus extra
%   columns used by tra(1,:). Default save writes
%   <place><name>_magnetometerLabel.dat, _gradiometerLabel.dat, _tra.dat,
%   _posOri.dat. Not on the Import menu. Lab helper for one MEG layout.
%
%   See also getElectrodePositions.

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
