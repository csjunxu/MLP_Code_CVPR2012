
clear;
Original_image_dir  =    'C:\Users\csjunxu\Desktop\JunXu\Datasets\kodak24\kodak_color\';
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);


addpath 'model';
method = 'MLP';
write_sRGB_dir = ['C:/Users/csjunxu/Desktop/ICCV2017/24images/'];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

% nSig = [5 30 15];
% nSig = [40 20 30];
% nSig = [30 10 50];



nSig = [30 10 50];

format compact;
PSNR = [];
SSIM = [];
modelnSig = [35 10 35];
for i = 1 : im_num
    IM_GT = double(imread(fullfile(Original_image_dir, im_dir(i).name)));
    S = regexp(im_dir(i).name, '\.', 'split');
    IMname = S{1};
    [h, w, ch] = size(IM_GT);
    IM = zeros(size(IM_GT));
    for c = 1:ch
        randn('seed',0);
        IM(:, :, c) = IM_GT(:, :, c) + nSig(c) * randn(size(IM_GT(:, :, c)));
    end
    fprintf('%s: \n', im_dir(i).name);
    fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', csnr( IM,IM_GT, 0, 0 ), cal_ssim( IM, IM_GT, 0, 0 ));
    %         randn('seed',0);
    %         noise_img          =   I+ nSig*randn(size(I));
    %         noise_img = double(uint8(noise_img));
    model = {};
    % width of the Gaussian window for weighting output pixels
    model.weightsSig = 2;
    % the denoising stride. Smaller is better, but is computationally
    % more expensive.
    model.step = 3;
    IMout = zeros(size(IM));
    for c = 1:ch
        %% denoising
        IMoutcc = fdenoiseNeural(IM(:,:,c), modelnSig(c), model);
        IMout(:,:,c) = IMoutcc;
    end
    PSNR = [PSNR csnr( IMout, IM_GT, 0, 0 )];
    SSIM = [SSIM cal_ssim( IMout, IM_GT, 0, 0 )];
    fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
    imwrite(IMout/255, [write_sRGB_dir method '_nSig' num2str(nSig(1)) num2str(nSig(2)) num2str(nSig(3)) '_modelnSig' num2str(modelnSig(1)) num2str(modelnSig(2)) num2str(modelnSig(3)) '_' IMname '.png']);
end
mPSNR = mean(PSNR);
mSSIM = mean(SSIM);
save([write_sRGB_dir method, '_nSig' num2str(nSig(1)) num2str(nSig(2)) num2str(nSig(3)) '_modelnSig' num2str(modelnSig(1)) num2str(modelnSig(2)) num2str(modelnSig(3)) '.mat'],'nSig','PSNR','mPSNR','SSIM','mSSIM');