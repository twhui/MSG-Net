%----------------------------------------------------------------
% Depth Map Super-Resolution by Deep Multi-Scale Guidance, ECCV16
%                     written by T.-W. HUI
%---------------------------------------------------------------
clear all;
close all;
clc;

%% Settings
dataDir = '/path/to/training_data/';
dataSet = 'Train_v3d';
saveDir = '/path/to/h5/';

grad_thd = 0.0005;
chunksz = 128;

scale = 2;
size_dataY = 40;
size_dataD = 20;
size_label = 40;
border_dataY = 1;
border_label = 1;

stride = 22;

data_aug = true;

%%
if strcmp(dataSet, 'Train_v3d')
    index_val = [1 20 28 58 64 66 69 73 75 79];
else
    error('Undefined training data set!\n');
end

%% Initialization
dataY = zeros(size_dataY, size_dataY, 1, 1);
dataD = zeros(size_dataD, size_dataD, 1, 1);
label = zeros(size_label, size_label, 1, 1);

size_subIm = size_dataD*scale;

pad_dataY = (size_subIm - size_dataY)/2;
pad_label = (size_subIm - size_label)/2;
assert(pad_dataY >= 0, 'pad_dataY cannot be an negative number!');
assert(pad_label >= 0, 'pad_label cannot be an negative number!');

count = 0;
count_edge = 0;
count_edge_pre = 0;
count_flat = 0;
count_flat_pre = 0;

%% Generate training  data
load([dataDir dataSet '/RGB']);
load([dataDir dataSet '/Df']);

index_train = setdiff(1:numel(Df), index_val);
fprintf('%d images is used for training.\n', numel(index_train));

RGB = RGB(index_train);
Df  = Df(index_train);

h = ones(3,3)/9;

for k = 1 : size(Df,1)

    fprintf('Processing %d of %d, id: %d, ', k, size(Df,1), index_train(k));

    im_Dh = modcrop(Df{k}, scale);
    im_M  = im_Dh > 0;
    im_Dh = normalizeIm(im_Dh, [0 1]);
    im_Dl = imresize(im_Dh, 1/scale, 'bicubic');
    im_Dl_LF = imfilter(im_Dl, h, 'symmetric');
    im_label = im_Dh - imresize(im_Dl_LF, scale, 'bicubic');
    [H, W] = size(im_label);

    I = RGB{k};
    I = rgb2ycbcr(I);
    Y = double(I(:,:,1));
    im_Y = modcrop(Y, scale);
    im_Y = normalize_cleanIm(im_Y);
    im_Y_LF = imfilter(im_Y, h, 'symmetric');
    im_inputY = normalize_cleanIm(im_Y - im_Y_LF);

    im_grad_Dh = imgradient(im_Dh, 'sobel');

    stride_ = stride;

    if strcmp(dataSet, 'Train_v3d')
        if index_train(k) >= 75
            stride_ = floor(2.0*stride_);
        elseif index_train(k) >= 65
            stride_ = floor(1.5*stride_);
        end
    else
        error('Undefinined dataSet!\n');
    end

    for x = 1 : stride_ : H-size_subIm+1
        for y = 1 :stride_ : W-size_subIm+1

            subIm_M = im_M(x : x+size_subIm-1, y : y+size_subIm-1);

            if sum(sum(subIm_M == 0)) == 0

                subim_dataY = im_inputY(x+pad_dataY : x+pad_dataY+size_dataY-1, y+pad_dataY : y+pad_dataY+size_dataY-1);

                subim_dataD = imresize(im_Dh(x : x+size_subIm-1, y : y+size_subIm-1), 1/scale, 'bicubic');
                subim_dataD = subim_dataD - imfilter(subim_dataD, h, 'symmetric');

                subim_label = im_label(x+pad_label : x+pad_label+size_label-1, y+pad_label : y+pad_label+size_label-1);

                count = count + 1;
                dataY(:, :, 1, count) = subim_dataY;
                dataD(:, :, 1, count) = subim_dataD;
                label(:, :, 1, count) = subim_label;

            end

        end
    end

end

fprintf('---------------------------------------\n')

fprintf('Total: %d patches.\n', count);
num_patches = count;

% Data augmntation
if data_aug
    num_patches = num_patches*2;
    dataY_tmp = dataY; clear dataY;
    dataD_tmp = dataD; clear dataD;
    label_tmp = label; clear label;
    dataY = cat(4, dataY_tmp, rot90(dataY_tmp,1));
    dataD = cat(4, dataD_tmp, rot90(dataD_tmp,1));
    label = cat(4, label_tmp, rot90(label_tmp,1));
end

fprintf('Number of patches used: %d\n', num_patches);

% Remove left-most column and bottom row of dataY and label
dataY = dataY(1:end-border_dataY,1:end-border_dataY,:,:);
label = label(1:end-border_label,1:end-border_label,:,:);

% Re-arrange order
order = randperm(num_patches);
dataY = dataY(:,:,:,order);
dataD = dataD(:,:,:,order);
label = label(:,:,:,order);
