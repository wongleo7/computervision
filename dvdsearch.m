%variable declarations
descperim = 200;
images = {};
frames = [];
desc = [];
alldesc = [];
allrdesc = [];
imagefiles = dir('libsized\*.jpg');
nfiles = length(imagefiles);
refimagefiles = dir('ref\*.jpg');
nrfiles = length(refimagefiles);
k = 10;
scores = [];

%batch import ref images (pictures of posters)
for ii=1:nrfiles
   currentfilename = refimagefiles(ii).name;
   currentimage = rgb2gray(double(imread(currentfilename)/255));
   currentimagecolor = imread(currentfilename);
   %images{ii} = currentimage;
   refimagefiles(ii).data = currentimage;
   refimagefiles(ii).datac = currentimagecolor;
   [refimagefiles(ii).frames, refimagefiles(ii).sift] = sift(currentimage);
   allrdesc = cat(2, allrdesc, refimagefiles(ii).sift);
end

%batch import images (picture database)
for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   currentimage = rgb2gray(double(imread(currentfilename)/255));
   currentimagecolor = imread(currentfilename);
   %images{ii} = currentimage;
   imagefiles(ii).data = currentimage;
   imagefiles(ii).datac = currentimagecolor;
   [imagefiles(ii).frames, imagefiles(ii).sift] = sift(currentimage);
   alldesc = cat(2, alldesc, imagefiles(ii).sift);
end

%number of sift descriptors in total
[~, numdesc] = size(alldesc);

%uses the expand function, k (k-means), and all of the sift descriptors to
%make a tree
top  = expand(k, alldesc, 1);

%now that i have the tree, for each image i need to make a bag of words
maxbag = 0;
for ii = 1:nfiles
    imagefiles(ii).bag = picturebag(imagefiles(ii), top);
    [~, tempbagsize] = size(imagefiles(ii).bag);
    if tempbagsize > maxbag
        maxbag = tempbagsize;
    end
end

%make bag of words for reference images too
for ii = 1:nrfiles
    refimagefiles(ii).bag = picturebag(refimagefiles(ii), top);
    [~, tempbagsize] = size(imagefiles(ii).bag);
    if tempbagsize > maxbag
        maxbag = tempbagsize;
    end
end

%'normalize' all the bags to be the same array size so they could be
%compared to each other, also normalize the values.
for ii = 1:nfiles
    total = sum([imagefiles(ii).bag{:}]);
    imagefiles(ii).bag{maxbag} = 0;
    for yy = 1:maxbag
        if isempty(imagefiles(ii).bag{yy})
            imagefiles(ii).bag{yy} = 0;
        end
    end
end

%normalize reference images with 0s and maxbag size as above
for ii = 1:nrfiles
    total = sum([imagefiles(ii).bag{:}]);
    refimagefiles(ii).bag{maxbag} = 0;
    for yy = 1:maxbag
        if isempty(refimagefiles(ii).bag{yy})
            refimagefiles(ii).bag{yy} = 0;
        end
    end
end

%get total occurances of each word for tf-idf normalization below
totalcount = [imagefiles(1).bag{:}];
for ii = 2:nfiles
    totalcount = totalcount + [imagefiles(ii).bag{:}];
end

%'normalize', via tf-idf, all the database visual word bags
for ii = 1:nfiles
    total = sum([imagefiles(ii).bag{:}]);
    imagefiles(ii).bag{maxbag} = 0;
    for yy = 1:maxbag
        if not(isempty(imagefiles(ii).bag{yy}))
            imagefiles(ii).bag{yy} = (imagefiles(ii).bag{yy}/ (1+total)) * log(numdesc/(totalcount(yy)+1));
        end
    end
end

%normalize via tf-idf the reference images
for ii = 1:nrfiles
    total = sum([imagefiles(ii).bag{:}]);
    refimagefiles(ii).bag{maxbag} = 0;
    for yy = 1:maxbag
        if not(isempty(imagefiles(ii).bag{yy}))
            imagefiles(ii).bag{yy} = (imagefiles(ii).bag{yy}/ (1+ total)) * log(numdesc/(totalcount(yy)+1));
        end
    end
end

%compare the reference word bags to the database word bags. We compare the
%distance between the bags, keeping the highscore per reference bag
for ii = 1:nrfiles
    scores = [];
%   compare image to db
    for yy = 1:nfiles
        s2 = pdist2([refimagefiles(ii).bag{:}], [imagefiles(yy).bag{:}]);
        scores = cat(1, scores, [yy s2]);
    end
    refimagefiles(ii).scores = scores;
end

%Goes through top ten (based on bag of words), and computes the homography
%between the reference and 10 top database images. We save the homography
%for each of the top images and also find the top match. The top match is
%then displayed side-by-side with the reference image. Using homography,
%an estimate of the poster is outlined on the reference image. 
for ii = 1:nrfiles
    %do this for each reference image
    tempstring = sprintf('%s:', refimagefiles(ii).name);
    disp(tempstring);
    temp = sortrows(refimagefiles(ii).scores, 2);
    
    highscore = 0;
    for yy = 1:10
        %within top ten, compare inliers and choose the highest
        [tscore, tmatch] = RANSAC3(imagefiles(temp(yy,1)), refimagefiles(ii), 0);
        if tscore > highscore
            highscore = tscore;
            refimagefiles(ii).topmatch = temp(yy);
            refimagefiles(ii).homography = tmatch;
        end
    end
    bestmatch = refimagefiles(ii).topmatch;
    RANSAC3(imagefiles(bestmatch), refimagefiles(ii), 1);
    figure;
    imshowpair(refimagefiles(ii).datac, imagefiles(bestmatch).datac, 'montage');
end

%for each descriptor, we need to find all the closest words
% --1) find closest word to each desc
% --2) add to index of (1)
%
%implement here

% We expand on the tree. We keep applying k-means the each word and their
%   descriptors.
% We just need to feed in the already ready list of descriptors into
%   kmeans function
%%% --remember to stop at a certain threshold. and we should have a helper
%%% function for this.

%Each image needs a 'bag of words' representation with tf-idf normalization
%--reference image needs too. We compare these bag of words after we get
%the sublist using the tree. 

%We need to have a database that links each descriptor to their images...
%--dictionary? so we could do 'bag of words' matching... 
% For each image
%   add image to that dictionary key (descr) for each descr

% For each image, sort 
%To get the image result. We pass each descriptor down the tree and get the
% descriptors that match, pull all the associated images, then make bag of
% words/ histogram thing to match. success?
% apply tf-idf

%Optimization ideas:
%maybe we can weed out the images that don't overlap (only 1 occurance, or
%top frequency /10 or sth)
