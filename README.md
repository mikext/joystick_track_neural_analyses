# Decode Two-dimensional Joystick Kinematics in Humans by ECoG Signals 

### ECE 209 Group Project 

*Xiaotian Wang, Yudi Wang*


**Related Document**
- Feature Extraction
 1. paper_method.m: the main code to obtained the processed data
 2. feature_extract_paper_method_smo_pca.m: the related function to actually process the data

**Pipeline**

- Feature Extraction based on signal processing
  1. Implement of the feature extraction method mentioned by the paper
     - Common average reference (CAR) montage
     - Obtained time bins and get the related psd
     - extract specific frequency band value from the psd curve and do average
     - using sliding window to smooth data
     - CFS
  
  2. Try another feature extraction method, draw tuning curve of each and do comparasion
     - Use the index or value of the First/Second/Third Largest Frequnency
     - Use one/two/three Eigen vector generated by PCA to achieve dimension reduction

   
- Model fitting and selection
    1. Benchmark (method of the original paper) : Linear Regression
        - Dataset split
           - random K fold CV
           - time slices K fold CV
        - Features included
           - LMP only
           - LMP and power densities (raw)
           - LMP and power densities (selected)

    2. Apply Kalman Filter to decode kinematic parameters.
        - state variables
           - posX, posY
           - posX, posY, Vx, Vy
        - Dataset split
           - time slices K fold CV
        - Features included
           - LMP only
           - LMP and power densities (raw)
           - LMP and power densities (selected)

    3. (If time permits) Apply Kalman Filter to decode kinematic parameters on polar coordinates, e.g., phase, amplitude, angular velocity, angular acceleration.

        - state variables
           - amplitude, angular velocity, angular acceleration
        - Dataset split
           - time slices K fold CV
        - Features included
           - LMP only
           - LMP and power densities (raw)
           - LMP and power densities (selected)
