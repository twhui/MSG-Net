# Caffe for MSG-Net (Multi-scale guidance network)
This is the release of MSG-Net for the paper Depth Map Super-Resolution by Deep Multi-Scale Guidance in ECCV16. It comes with 4 trained networks (x2, x4, x8, x16) and 3 testing sets (A, B, C).

For more details, please visit the <a href="http://mmlab.ie.cuhk.edu.hk/projects/guidance_SR_depth.html">project page </a>.

# Dependency
The codes are based on <a href="https://github.com/BVLC/caffe">caffe</a> and Matlab.

# Installation and Running
You need to install <a href="https://github.com/BVLC/caffe">caffe</a> and remeber to complie matcaffe. You can put the folder <code>MSGNet-release</code> in <code>caffe/examples</code>. Finally, you need to get into the the directory of <code>examples/MSGNet-release</code>, and run <code>MSGNet.m</code>. </li>

# Training data
It consists 58 RGBD images from MPI Sintel depth dataset, and 34 RGBD images (6, 10 and 18 images are from 2001, 2006 and 2014 datasets respectively) from Middlebury dataset. 82 images were used for training and 10 images.

If you want to use our training set for training your model, the RGB and depth images are available in <code>training_data/RGB.mat</code> and <code>training_data/Df.mat</code> respectively. RGBD frames: 1, 20, 28, 58, 64, 66, 69, 73, 75, 79 are used for validation.

# License and Citation
All code is provided for research purposes only and without any warranty. Any commercial use requires our consent. When using the code and/or training data in your research work, please cite the following paper:

"T.-W. Hui, C. C. Loy and X. Tang, Depth Map Super-Resolution by Deep Multi-Scale Guidance, pp. 353–369, ECCV16".
