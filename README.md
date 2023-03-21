# Yolov5-for-tree-species-classification-in-point-cloud-derived-images


# Train- Validation-dataset split
In order to train the YOLO classification model and to validate the performance during training we randomly split the original tre3d training-dataset into a training- (90%) and validation (10%) dataset. 

# Derivation of images from single Tree point clouds

# Training of the YOLO classification model
We used the following hyperparameters for training
|Hyperparamters|value|
|--------------|-----|
|learning rate |0.001|

# Results
The trained YOLO classification model achieved an overall accuracy of 84 % over all 33 tree species classes on the validation dataset. The class specific accuracies achieved by the application of the trained YOLO model on the validataion dataset are depicted in Figure 1. The best performing YOLO classification model was trained after 26 epochs. 
![tr3d_spec_classification_validation](https://user-images.githubusercontent.com/78412402/226630824-a4b1ffc8-60a2-4040-95b5-c702de010ff4.png)
Figure 1
