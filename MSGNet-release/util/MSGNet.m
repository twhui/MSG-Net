% This code is only for non-commercial and scientific research purposes without any warranty.
% When using this code, please cite "T.-W. Hui, C. C. Loy, X. Tang, Depth Map Super-Resolution by Deep Multi-Scale Guidance, pp.353 – 369, ECCV16"

clear all;
close all;
clc;
addpath('./matlab');
root = './examples/MSGNet-release/';

%% CNN models
cnn = './models/MSGNet_x2';  up_scale = 2;   
% cnn = './models/MSGNet_x4';  up_scale = 4;  
% cnn = './models/MSGNet_x8';  up_scale = 8;  
% cnn = './models/MSGNet_x16'; up_scale = 16; 

%% Testing image
split = true; evaSet = 'A'; image_name = {'art', 'books', 'moebius'};
image_id = 1;

% split = true; evaSet = 'B'; image_name = {'art', 'books', 'dolls', 'laundry', 'moebius', 'reindeer'};
% image_id = 3;

% split = false; evaSet = 'C'; image_name = {'tsukuba', 'venus', 'teddy', 'cones'};
% image_id = 4;

%% Parameters settings
gpu_id = 7;
h = ones(3,3)/9;
hole_defect = false;  
margin = 8*up_scale;

%% Read ground truth depth map and RGB image
if strcmp(evaSet, 'A')
    imGtD0 = imread([root './testing sets/A/Depth/' image_name{image_id} '.png']);
    imRGB0 = imread([root './testing sets/A/RGB/'   image_name{image_id} '.png']);
    [M, N] = size(imGtD0);
    [Mmb, Nmb, ~] = size(imRGB0);
    dd = [Mmb - M; Nmb - N];  
    imRGB0 = imRGB0(dd(1)/2+1:end-dd(1)/2, dd(2)/2+1:end-dd(2)/2, :);
    
elseif strcmp(evaSet, 'B')
    imGtD0 = imread([root './testing sets/B/Depth/' image_name{image_id} '.bmp']);
    imRGB0 = imread([root './testing sets/B/RGB/'   image_name{image_id} '.bmp']);
    
    if strcmp(image_name{image_id}, 'dolls')
        hole_defect = true;
    end
   
elseif strcmp(evaSet, 'C')
    load([root './testing sets/C/Depth/' image_name{image_id} '_2']);
    imGtD0 = img_double;
    imRGB0 = imread([root './testing sets/C/RGB/'   image_name{image_id} '.bmp']);
    [M, N] = size(imGtD0);
    [Mmb, Nmb, ~] = size(imRGB0);
    dd = [Mmb - M; Nmb - N];  
    imRGB0 = imRGB0(1:end-dd(1), 1:end-dd(2), :);
end

%% Main
im_RGB0 = modcrop(imRGB0, up_scale);
im_GtD0 = modcrop(imGtD0, up_scale);
size_Dh = size(im_GtD0);
size_Dl = size_Dh/up_scale;

% Due to the limit of MAX_INT in Caffe, upsampling of depth map is
% performed patch by patch. Final result is obtained by combining the two
% patches together.
if split
    num_split = 2;
    
    if margin > 0
        size_Dl(1) = size_Dl(1)/2;
        size_Dh(1) = size_Dh(1)/2;
    else
        error('Padded margin size must be greater than zero !\n');
    end
    
    cropSz_Dh = (size_Dl(1) - floor(size_Dl(1)))*up_scale;
    if cropSz_Dh > 0
        fprintf('Increased margin by %d pixels \n\n', cropSz_Dh);
        margin = margin + cropSz_Dh;
    else
        fprintf('\n');
    end
    
    ims_RGB{1} = im_RGB0(1:size_Dh(1)+margin,:,:);
    ims_GtD{1} = im_GtD0(1:size_Dh(1)+margin,:);
        
    ims_RGB{2} = im_RGB0(size_Dh(1)+1-margin:end,:,:);
    ims_GtD{2} = im_GtD0(size_Dh(1)+1-margin:end,:);
    
else
    num_split = 1;
    ims_RGB{1} = im_RGB0;
    ims_GtD{1} = im_GtD0;
end

for k_sub = 1 : num_split
    
    if num_split > 1
        fprintf('Splitting %d of %d\n', k_sub, num_split);
    end
    
    % Y-channel
    if size(ims_RGB{k_sub}, 3) > 1
        im_I = rgb2ycbcr(ims_RGB{k_sub});
        im_Y = double(im_I(:,:,1));
    else
        im_Y = double(im_I);
    end
    im_Y = normalize_cleanIm(im_Y);
    im_Y_LF = imfilter(im_Y, h, 'symmetric');
    im_Y = normalize_cleanIm(im_Y - im_Y_LF);
    
    im_Y = im_Y(1:end-1, 1:end-1);
    
    % D-channel
    im_GtD = double(ims_GtD{k_sub});
    im_Dl = imresize(im_GtD,  1/up_scale, 'bicubic');
    [im_Dl, min_D, max_D] = normalize_cleanIm(im_Dl);
    
    im_Dl_LF = imfilter(im_Dl, h, 'symmetric');
    in_D = im_Dl - im_Dl_LF;
    
    % Run CNN
    caffe.reset_all();
    caffe.set_mode_gpu();
    caffe.set_device(gpu_id);
    
    net_model   = [root cnn '_deploy.prototxt'];
    net_weights = [root cnn '.caffemodel'];
    
    net = caffe.Net(net_model, net_weights, 'test');
   
    blobs_input{1} = permute(im_Y, [2 1 3]);
    blobs_input{2} = permute(in_D, [2 1 3]);
    
    net.blobs('data-Y').reshape([size(blobs_input{1},1) size(blobs_input{1},2) 1 1]);
    net.blobs('data-D').reshape([size(blobs_input{2},1) size(blobs_input{2},2) 1 1]);
    net.reshape();
    
    fprintf('Run CNN ... \n');
    blobs_output = net.forward(blobs_input);
    fprintf('Finished. \n');
    
    im_Dh = permute(blobs_output{1}, [2 1 3]);
    im_D_LF = imresize(im_Dl_LF, up_scale, 'bicubic');
    im_Dh = im_Dh + im_D_LF(1:end-1, 1:end-1);
    im_Dh = im_Dh*(max_D - min_D) + min_D;
   
    if split
        im_Dh_sub(:,:,k_sub) = im_Dh;
    end
    
end

%% Combine splitted images to a single one if necessary
if split
    im_Dh = [im_Dh_sub(1:end-(margin-1),:,1); im_Dh_sub(1+margin:end,:,2)];
end

%% Prepare ground truth
im_GtD = double(im_GtD0);

if hole_defect
    im_occ = im_GtD > 9;
else
    im_occ = true(size(im_GtD));
end

im_GtD = im_GtD(1:end-1, 1:end-1);
im_occ = im_occ(1:end-1, 1:end-1);

%% Convert to uint8 or uint16 
if max(max(im_GtD)) > 2^8-1
    im_Dh  = uint16(im_Dh);
    im_GtD = uint16(im_GtD);
else
    im_Dh  = uint8(im_Dh);
    im_GtD = uint8(im_GtD);
end

%% Compute RMSE
rmse_cnn = compute_RMSE(im_GtD, im_Dh, im_occ);

fprintf('------------------------------------------\n');
fprintf('Model: %s\n', cnn);
fprintf('Testing set %s: %s\n', evaSet, image_name{image_id});
fprintf('MSG-Net %dx upsampling, RMSE = %.3f\n', up_scale, rmse_cnn);

