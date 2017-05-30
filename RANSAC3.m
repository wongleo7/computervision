%from assignment 3, edited to accept objects
function [score, highmatx] = RANSAC(im1, im2, show)
warning('off','all');
upbound = 30;

rng(0, 'twister')

refim = im1.data;  refimc = im1.datac;
testim = im2.data; testimc = im2.datac;

[FRAMES,DESCR] = sift(refim);
[FRAMES1,DESCR1] = sift(testim);

FRAMES = im1.frames;
FRAMES1 = im2.frames;
DESCR = im1.sift;
DESCR1 = im2.sift;

matches = siftmatch(DESCR, DESCR1);
matchsize = size(matches);

highmatch = [];
highscore = 0;
highmatx = [];

for abc = 1: 7000

    numliers = 0;
    
    pick = randperm(matchsize(2), 3);

    p = [];
    pt = [];
    px = [];
    pxt = [];
    pyt = [];


    for x = 1: 3
        m1 = matches(:,pick(x));
        temp = FRAMES(:,m1(1));
        tempt = FRAMES1(:,m1(2));
        p = [ p; temp(1), temp(2), 0, 0, 1, 0; 0,0,temp(1), temp(2), 0, 1];
        pt = [pt; tempt(1); tempt(2)];

        %another equation
        px = [px; temp(1), temp(2), 1];
        pxt = [pxt; tempt(1);];
        pyt = [pyt; tempt(2);];
    end

    %a = inv(p) * pt;
    a = p\pt;
    %a = pt\p;

    A = [a(1) a(2) a(5); a(3) a(4) a(6)];

    %lets set inliers under 100
    inlier = 0;

    for x = 1: length(matches)
        matchx = matches(:,x);
        temp = FRAMES(:,matchx(1));
        temp1 = FRAMES1(:,matchx(2));
        x1 = temp(1);
        y1 = temp(2);
        x2 = temp1(1);
        y2 = temp1(2);
        point1 = (A * [x1;y1;1]);
        point1 = point1';
        inval = norm(point1 - [x2,y2]);
        if (inval < upbound)
            inlier = inlier + 1;
        end
    end

    if (inlier > highscore)
        highscore = inlier;
        highmatch = pick;
        highmatx = A;
    end
end

match = highmatch;
score = inlier;

if true(show)
    %***********************Important points***********************************
    tra = length(refim(1,:));
    trz = 1;
    tla = 1;
    tlz = 1;
    [brz, bra] = size(refim);
    bla = 1;
    blz = length(refim);
    %**************************************************************************



    tr = (highmatx * [tra;trz;1]);
    tl = (highmatx * [tla;tlz;1]);
    br = (highmatx * [bra;brz;1]);
    bl = (highmatx * [bla;blz;1]);

    figure;
    imshow(testimc);
    hold on;
    line([tr(1) tl(1)], [tr(2) tl(2)], [1 1],'LineWidth',4);
    line([br(1) tr(1)], [br(2) tr(2)], [1 1],'LineWidth',4);
    line([bl(1) tl(1)], [bl(2) tl(2)], [1 1],'LineWidth',4);
    line([bl(1) br(1)], [bl(2) br(2)], [1 1],'LineWidth',4);
    hold off;
end

S = sprintf('image: %s, image: %s, score %d', im2.name, im1.name, score);
disp(S);
warning('on','all');


