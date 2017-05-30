function [bag] = picturebag(image, root)

siftarr = image.sift;
tempbag = [];
tmax = 0;
[~, siftarrsize] = size(siftarr);
for yy = 1: siftarrsize
    %find one word for each sift item and add to imagefiles(ii).bag
    tempnode = getword(siftarr(:,yy), root);
    %disp(tempnode.label);
    if tmax < tempnode.label
        tempbag{tempnode.label} = 1;
        tmax = tempnode.label;
    else
        if isempty(tempbag{tempnode.label})
            tempbag{tempnode.label} = 1;
        else
            tempbag{tempnode.label} = tempbag{tempnode.label} + 1;
        end
    end
end
bag = tempbag;