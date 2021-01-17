# Retinal_Lesion_Segmentation
This code is used to automatically segment out the lesions from retinal images.


### Usage: 
1. Use the folder **'codeforMATLAB2014aORAbove'** or **'codeforMATLAB2018aORAbove'** as per your system.

2. Go inside that folder from MATLAB using `cd` command or using UI.

3. In the MATLAB command window type following (case sensetive) and press enter:
	`retinalLesionSegmentation`

4. Choose the selection mode `Single Processing` or `Bulk Processing` from the UI Popup.

5. Choose an image file or folder based on previous coice of single or bulk processing from the UI browse window.

6. Opt whether you would like to see all the intermediate images while processing. Please note choosing this as `Yes` will slow down the process. And even if you choose `No`, it will save all intermediate images in the folder inside the data folder. so you can see them later point of time.


### Caution:
The program is tested on **MATLAB R2018a** and **MATLAB R2014a** with two versions of the code maintained in two folder. However, the lower version code has an inefficiency in saving two of the resulting images due to non availability of window fullscreen feature. But, Higher version of the code i.e. for MATLAB R2018a or above runs perfectly fine.


### Notes:
1. To save some of the MATLAB figures, this code uses `export_fig.m` and 3 corresponding functions (`crop_borders.m`,`print2array.m`,`using_hg2.m`) from [this url](https://www.mathworks.com/matlabcentral/fileexchange/23629-export-fig). For those 4 files credit goes to the corresponding author of that code, Yair Altman.

2. The code was built on a private dataset, however it should work on any RGB dataset of retinal scan (fundus images) probably with some alteration on image dimension if required. 

3. There is no current plan of sharing the dataset due to privacy and proprietary reasons. However, the code is released to facilitate further research. Should there be any change in the plan, this repository will be updated with necessary information.   


### Reference:
Please find the paper in [this link](https://link.springer.com/chapter/10.1007/978-3-030-14802-7_27)

### Citation:
If you find this code helpful to your research please consider citing following paper:
````
@inproceedings{bandyopadhyay2019semi,
  title={A Semi-Supervised Learning Approach for Automatic Segmentation of Retinal Lesions Using SURF Blob Detector and Locally Adaptive Binarization},
  author={Bandyopadhyay, Tathagata and Kubicek, Jan and Penhaker, Marek and Timkovic, Juraj and Oczka, David and Krejcar, Ondrej},
  booktitle={Asian Conference on Intelligent Information and Database Systems},
  pages={311--323},
  year={2019},
  organization={Springer}
}
````
