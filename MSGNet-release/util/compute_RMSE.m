function rmse = compute_RMSE(im1, im2, occ)
if size(im1, 3) == 3,
    im1 = rgb2ycbcr(im1);
    im1 = im1(:, :, 1);
end

if size(im2, 3) == 3,
    im2 = rgb2ycbcr(im2);
    im2 = im2(:, :, 1);
end

imdff = double(im1) - double(im2);
imdff = imdff(occ == 1);

rmse = sqrt(mean(imdff.^2));
