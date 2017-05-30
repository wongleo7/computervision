%we take a descriptor and a tree (root) and return a word (node) that is
%closest to the descriptor
%return the best choice until it is a leaf (no more children), that is then the word. 
%everything has k children.
%to get the word associated with the input, 
function [node] = getword(desc, root)
        

%bug: it grabs the first one every time. 
    [~,k] = size(root);
    
    %disp(size(desc));
    %disp(size(root(1).w));
    minval = dist2(desc', root(1).w);
    mindex = 1;
    
    for ii = 1:k
        %we go through the children
        temp = dist2(desc', root(ii).w);
        if temp < minval
            minval = temp;
            mindex = ii;
        end
    end
    
    if isempty(root(mindex).child)
        node = root(mindex);
    else
        node = getword(desc, root(mindex).child);
    end
    
end
