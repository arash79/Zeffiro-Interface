%GMM_SUBPLOT  Lab script: rebuild GMM databank nodes then subplot figures.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. For typ in Prob/Comp/kmeans, deletes GMM nodes whose name
%   does not contain typ, then plots. Needs zef.dataBank. Pair with
%   p_outputNew.
%

tree.all=zef.dataBank.tree;

for iii=1:3

    switch iii
        case 1
            typ='Prob';
        case 2
            typ='Comp';
        case 3
            typ='kmeans';
    end

    dltType='gmm';

    onlyIn='node';

    allHashes=fieldnames(zef.dataBank.tree);
    allHashes=allHashes(startsWith(allHashes, onlyIn));

    i=1;
    while i<=length(allHashes)

        if strcmp(zef.dataBank.tree.(allHashes{i}).type, dltType) && (~contains(zef.dataBank.tree.(allHashes{i}).name, typ) || contains(zef.dataBank.tree.(allHashes{i}).name, '25'))
            zef.dataBank.hash=allHashes{i};
            zef.dataBank.tree=zef_dataBank_delete(zef.dataBank.tree, zef.dataBank.hash, 'false');
            %zef_dataBank_uiTreeDeleteHash(zef.dataBank.app.Tree, zef.dataBank.hash);
            allHashes=fieldnames(zef.dataBank.tree);
            allHashes=allHashes(startsWith(allHashes, onlyIn));

            i=1;
        else
            i=i+1;
        end

    end

    tree.(typ)=zef.dataBank.tree;

    zef.dataBank.tree=tree.all;

end

subIndex=1;
figure;
for iii=1:3

    switch iii
        case 1
            typ='Comp';
        case 2
            typ='Prob';
        case 3
            typ='kmeans';
    end

    zef.dataBank.tree=tree.(typ);
    p_outputNew_subplot;

end
