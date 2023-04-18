# Introduction
This workflow performs tree species classification on cross section images of individual tree point clouds using a YOLOv5 classification model. 

# Setup
## Get Yolov5
Download YOLOv5 and setup a working environment as explained [here](https://github.com/ultralytics/yolov5).

## Get Julia
Download Julia from [here](https://julialang.org/downloads/).

## Set up Julia environment
Clone this repository and use the folder ./treeprojection, which contains a Project.toml, a Manifest.toml and the julia script (treeprojection.jl) as Julia environment.

# Data preparation 
## Prepare point clouds
The julia package [LasIO](https://github.com/visr/LasIO.jl), which is used here to load the point clouds, only supports las-format 1.1 - 1.3. If your files are in las-format==1.4 you can use the rscript "transform_las-format_1.2_.r" to transform your las files into las-format 1.2.

## Folder structure
Create a tree spiecies oriented folder structure as shown below and store your point clouds into these folders.

```bash
├── pointclouds
│   ├── tree_species_1
│   │   ├── tree.las
│   │   ├── tree.las
│   │   ├── ...
│   ├── tree_species_2
│   │   ├── tree.las
│   │   ├── tree.las
│   │   ├── ...
│   ├── ...
│   │   ├── tree.las
│   │   ├── tree.las
│   │   ├── ...
│   ├── tree_species_99
│   │   ├── tree.las
│   │   ├── tree.las
│   │   ├── ...
```
Create a similar tree spiecies oriented folder structure with empty folders for the output images. The treeprojection.jl script expects the shown folder structure. 

# Creating cross sections from individual tree point clouds with treeprojection.jl
The Julia script "treeprojection.jl" creates four cross section images (600px x 800px) from different angles (angles: 0, 45, 90, 135) of each passed las-file. A example of a cross section image is presented below.
![00069_0](https://user-images.githubusercontent.com/78412402/226636637-7d45849d-55ef-4d1f-8f39-362403407133.png)

Go to the folder of your julia installation and run the command below. Note that the script is opted for parallel computing. You can set the number of processors with -p. For example, if you have only one processor set -p 1. 

> ./julia -p 7 -O ./treeprojection/treeprojection.jl ./pathto/pointclouds ./pathto/output

# Train- Validation-dataset split
For Training of the YOLOv5 model split the dataset of cross section images into a training and validation dataset.
 Save the split dataset in a folder structure like this, because YOLOv5 expects it:

```bash
├── images
│   ├── train
│   │   ├── tree_species_1
│   │   │   ├── treeid_0.png
│   │   │   ├── treeid_45.png
│   │   │   ├── treeid_90.png
│   │   │   ├── treeid_135.png
│   │   │   ├── ...
│   │   ├── ...
│   ├── val
│   │   ├── tree_species_1
│   │   │   ├── treeid_0.png
│   │   │   ├── treeid_45.png
│   │   │   ├── treeid_90.png
│   │   │   ├── treeid_135.png
│   │   │   ├── ...
│   │   ├── ...

```

# YOLOv5 classification model training
After setting up a YOLOv5 environment activate this environment and navigate to the YOLOv5 classification folder for training YOLOv5/classify/.
Run the following code from the terminal

> python train.py --model yolov5l-cls.pt --data /pathto/images --epochs 200 --optimizer AdamW

# Apply to test dataset
After training apply the trained YOLOv5 classification model to a test data set. Activate the YOLOv5 environment and navigate to the YOLOv5 classification folder YOLOv5/classify/. Use the command below for prediction.

> python predict.py -- weight ./runs/train-cls/Your_EXP/weights/best.pt --sources path/to/test_data_images --save-txt

As a result YOLOv5 saves the predicted classes of each cross section image in a result folder as text files. Use these text files for the next step. Since you have four cross section images of a single tree point cloud, it can happen that YOLOv5 predicts different tree species for each of these images. In order to get the final tree species prediction for the individual tree point cloud apply the r script "" on the text files created by the application of the trained YOLOv5 classification model on the test dataset (see below). 

# Get final tree species prediction for each individual tree point cloud
Apply the R-Script "" on the text files created by the application of the trained YOLOv5 classification model on the test dataset. The result is a csv file containing the tree id's and the final casts for tree species. 

# Our results
In order to train the YOLO classification model and to validate the performance during training we randomly split the original [tre3d](https://github.com/stefp/Tr3D_species) training-dataset into a training- (90%) and validation (10%) dataset. We performed this 90% / 10% split for each tree species.
Using the above presented workflow our trained YOLOv5 classification model achieved an overall accuracy of 84 % over all 33 tree species classes on the validation dataset.The best performing YOLO classification model was trained after 26 epochs. The class specific accuracies (confusion matrix) achieved by the application of the trained YOLO model on the validataion dataset are depicted here:

![tr3d_spec_classification_validation](https://user-images.githubusercontent.com/78412402/226630824-a4b1ffc8-60a2-4040-95b5-c702de010ff4.png)


# Hyperparamteres used for training 
We used the following hyperparameters for training
|Hyperparamters|value|
|--------------|-----|
|learning rate |0.001|


