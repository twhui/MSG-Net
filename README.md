# MSG-Net (Multi-scale guidance network)
</p>
<p align="center"><img src="https://github.com/twhui/MSG-Net/blob/master/MSGNet-release/misc/MSG_Net.png" align="center" {:height="70%" width="80%"}></p>
<p align="center">Multi-scale guidance network</p>

</p>
<p align="center"><img src="https://github.com/twhui/MSG-Net/blob/master/MSGNet-release/misc/illus.png" align="center" {:height="60%" width="70%"}></p>

This repository (<strong>https://github.com/twhui/MSG-Net</strong>) is the offical release of <strong>MSG-Net</strong> for our paper <a href="http://personal.ie.cuhk.edu.hk/~ccloy/files/eccv_2016_depth.pdf"><strong>Depth Map Super-Resolution by Deep Multi-Scale Guidance </strong></a> in ECCV16. It comes with four trained networks (x2, x4, x8, and x16), one hole-filled RGBD training set, and three hole-filled RGBD testing sets (A, B, and C).

<strong>To the best of our knowledge, MSG-Net is the FIRST convolution neural networkwhich attempts to <i> upsample depth images under multi-scale guidance from the corresponding high-resolution RGB images</i></strong>.

Another <a href="https://github.com/twhui/MS-Net"><strong>repository</strong> </a> for <strong>MS-Net</strong> (without multi-scale guidance) is also available.

For more details, please visit <a href="http://mmlab.ie.cuhk.edu.hk/projects/guidance_SR_depth.html"><strong>my project page</strong></a>.

# License and Citation
All code and other materials (including but not limited to the paper, figures, and tables) are provided for research purposes only and without any warranty. Any commercial use requires our consent. When using any parts of the code package or the paper (<i>Depth Map Super-Resolution by Deep Multi-Scale Guidance</i>) in your work, please cite the following paper:

<pre><code>@InProceedings{hui16msgnet,    
 author = {Tak-Wai Hui and Chen Change Loy and and Xiaoou Tang},    
 title  = {Depth Map Super-Resolution by Deep Multi-Scale Guidance},    
 booktitle  = {Proceedings of European Conference on Computer Vision (ECCV)},    
 pages = {353--369},  
 year = {2016},    
 url = {http://mmlab.ie.cuhk.edu.hk/projects/guidance_SR_depth.html}}</code></pre>

# Dependency
We train our models using <a href="https://github.com/BVLC/caffe">caffe</a> and evaluate the results on Matlab.

# Installation and Running
You need to install <a href="https://github.com/BVLC/caffe">caffe</a> and remeber to complie matcaffe. You can put the folder <code>MSGNet-release</code> in <code>caffe/examples</code>. Finally, you need to get into the the directory of <code>examples/MSGNet-release/util</code>, and run <code>MSGNet.m</code>. </li>

# Training data
Our <a href="https://www.dropbox.com/sh/p45abqvpzv66m2p/AACwDh0iIu67Us3IPLusfPXXa?dl=0e">RGBD training set</a> consists of 58 RGBD images from <a href="http://sintel.is.tue.mpg.de/depth">MPI Sintel depth dataset</a>, and 34 RGBD images from <a href="http://vision.middlebury.edu/stereo/data/">Middlebury dataset</a>. 82 images are used for training and 10 images (frames 1, 20, 28, 58, 64, 66, 69, 73, 75 and 79) are used for validation.

# Testing data
Testig set is available at the folder <code>MSGNet-release/testing sets</code>.
