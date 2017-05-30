%reproducing function. 
% - calc kmeans
% - split the current batch of descriptors into the k groups.
% - return the new node (input + the childrens) (check if this works)
%input: k, node, 
%output: children  split into k
function [index, numba] = expand(k, alldesc, numba)

sizeoword = 50;
%take the input list of descriptors (SIFT) and 
%find k-means so we could use that for reference indexing

[idx,w] = kmeans(alldesc',k, 'Maxiter',500);
size(w);

%now... we need to compile the index with these words (w). Link all
%assosiated words with their respective images
% Word  |   Descr
% ----------------
%       |
%       |
%for each descriptor, we look for closest

for ii = 1:k
    index(ii).list = [];
    index(ii).label = numba;
    index(ii).w =  w(ii,:);
    numba = numba + 1;
end

[adx, ady] = size(alldesc);

for ii=1:ady
    
    %disp(ii);
    %alldesc(:,ii);
    %w(1,:);
    
    smalldist = dist2(alldesc(:,ii)', w(1,:));
    tempyy = 1;
    %goes through all the words for each image
    for yy = 2:k
        %-------------tempdist = dist2(imagefiles(ii).sift, w(yy));
        tempdist = dist2(alldesc(:,ii)', w(yy,:));
        if (tempdist < smalldist)
            smalldist = tempdist;
            tempyy = yy;
            %smalldist = dist2(imagefiles(ii).sift, w(yy))
        end
    end
    %every time a desc is processed, add to index
    %w.list = cat(1, w.list, alldesc(:,ii));
    index(tempyy).list = cat(2, index(tempyy).list, alldesc(:, ii));
end

for ii = 1:k
    %disp(size(index(ii).list));
    %disp(length(index(ii).list));
    [indx, indy] = size(index(ii).list);
    if indy > sizeoword
        [index(ii).child, numba] = expand(k, index(ii).list, numba);
    else
        index(ii).child = [];
    end
end

