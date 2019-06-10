# Decode Two-dimensional Joystick Kinematics in Humans by ECoG Signals 

### ECE 209 Group Project 

*Xiaotian Wang, Yudi Wang*


**Related Code**
- Feature Extraction
 1. `paper_method.m`: the main code to obtain the processed data
 2. `feature_extract_paper_method_smo_pca`.m: the related function to actually process the data
- Model fitting
 1. `Ct4_one_fold.m`: the script for running one-fold training and evaluation.
 2. `Ct4_CV.m` the script for running 5-fold cross validation.


**Pipeline**
- Feature Extraction based on signal processing. Implement of the feature extraction method mentioned by the paper
     - Common average reference (CAR) montage
     - Obtained time bins and get the related psd
     - extract specific frequency band value from the psd curve and do average
     - extract LMP features
     - using sliding window to smooth data
  

- Model fitting
    1. Benchmark (method of the original paper) : Linear Regression
        - Dataset split
           - time slices K fold CV
        - Features included
           - LMP
           - PSD

    2. Apply Kalman Filter to decode kinematic parameters.
        - state variables
           - posX, posY, Vx, Vy
        - Dataset split
           - time slices K fold CV
        - Features included
           - LMP
           - PSD

