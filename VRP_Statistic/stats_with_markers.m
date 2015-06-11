function stats_with_markers
stats = getStats; %get data

perms = [1 2;1 3;1 4;2 3;2 4;3 4];%all permutations
params = struct('name',{'e','alpha','beta','tau0'}); %description of parameters

colors = hsv(length(stats));

for permN = 1:length(perms(:,1))
    c1 = perms(permN,1);
    c2 = perms(permN,2);
    
     figure %new figure
     
     mainMatrix = unique([stats(1).params(:,c1),stats(1).params(:,c2)],'rows');
     markerSizes = ones(size(mainMatrix,1),1);
     for task = 2:length(stats)
         newMatrix = unique([stats(task).params(:,c1),stats(task).params(:,c2)],'rows');
         [mainMatrix, markerSizes] = getMarkerSizes(mainMatrix, newMatrix, markerSizes);
     end
     
     subplot(4,1,[1,2,3])
     for j = 1:length(mainMatrix)
        markerSize = markerSizes(j)*30;
        scatter(mainMatrix(j,1),mainMatrix(j,2),markerSize,'filled',...
            'MarkerFaceColor',colors(markerSizes(j),:));
        hold on;
     end
    
     xlabel(params(c1).name);
     ylabel(params(c2).name);
     
     %output new figure with markers (colors,sizes and number of occurrences)
     [uniquePoints,imS,~] = unique(markerSizes,'rows');
     uniqueMarkerPoints = [mainMatrix(imS,:) uniquePoints];
     legcolors = cell(1,length(uniquePoints));
     subplot(4,1,4)
     for j = 1:size(uniqueMarkerPoints,1)
        markerSize = uniqueMarkerPoints(j,3)*30;
        scatter(j,1,markerSize,'filled',...
            'MarkerFaceColor',colors(uniqueMarkerPoints(j,3),:));
        legcolors(1,j) = cellstr(sprintf('%d',uniqueMarkerPoints(j,3)));
        hold on; %
     end
     l = legend(legcolors);
     v = get(l,'title');
     set(v,'string','Colors = number of occurrences in tasks');

end
end

function [main, markerSizes] = getMarkerSizes(main, new, markerSizes)
    newlength = length(new);
    for i = 1:newlength
        [b,indMain] = ismember(new(i,:),main,'rows');
        if b == 1
            markerSizes(indMain) = markerSizes(indMain) + 1;
        else
            main = [main;new(i,:)];
            markerSizes = [markerSizes;1];
        end
    end
end


    
    
