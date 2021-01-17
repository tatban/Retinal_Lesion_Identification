function clusteredRegions = clusterRegion(labeledBinaryImage, numberOfGroups)
    stats = regionprops(labeledBinaryImage,'Area','ConvexArea','Eccentricity','EquivDiameter','MajorAxisLength','MinorAxisLength','Perimeter','Solidity');
    ppas = [stats.Perimeter]./[stats.Area];
    circularities = [stats.Perimeter].^2 ./ (4*pi*[stats.Area]);
    minor2MajoraxisRatio = [stats.MinorAxisLength]./[stats.MajorAxisLength];
%    statsMat = table2array(stats);
    %statsMat = [stats.Area,stats.ConvexArea,stats.Eccentricity,stats.EquivDiameter,stats.MajorAxisLength,stats.MinorAxisLength,stats.Perimeter,stats.Solidity, ppas, circularities];%might need to ad row identifier
    %statsMat = [[stats.Eccentricity]',[stats.EquivDiameter]',[stats.Solidity]', ppas', circularities', minor2MajoraxisRatio',[stats.Area]',[stats.Perimeter]',[stats.ConvexArea]',[stats.MajorAxisLength]',[stats.MinorAxisLength]'];%might need to ad row identifier
    statsMat = [[stats.Eccentricity]',[stats.EquivDiameter]',[stats.Solidity]', ppas', circularities', minor2MajoraxisRatio'];
    groupIndeces = kmeans(statsMat,numberOfGroups,'Replicates',3);
    clusteredRegions =groupIndeces;
end