# Acceleration-Based Continuous User Authentication using Neural Networks

**Course:** PUSL3123 – AI and Machine Learning  
**Project Type:** Coursework Submission  
**Date:** November 2025

---

## 📋 Project Overview

This project implements a **continuous user authentication system** using accelerometer data from smart devices. By analyzing unique patterns in how individuals walk and move, the system can identify users through behavioral biometrics. A Multi-Layer Perceptron (MLP) neural network is trained to classify user identity based on extracted motion features.

### Key Objectives

1. ✅ Preprocess raw accelerometer data from smart devices
2. ✅ Extract meaningful time-domain and frequency-domain features
3. ✅ Analyze feature variability and uniqueness across users
4. ✅ Design and train a Neural Network (MLP) for user classification
5. ✅ Evaluate performance using FAR, FRR, EER, and accuracy metrics
6. ✅ Optimize model through feature selection and hyperparameter tuning
7. ✅ Discuss privacy, security, and usability aspects

---

## 📁 Project Structure

```
ai-ml/
├── Dataset/                    # Raw accelerometer CSV files
│   ├── U1NW_FD.csv
│   ├── U1NW_MD.csv
│   └── ... (U2-U10)
│
├── results/                    # Generated outputs (created automatically)
│   ├── preprocessed.mat
│   ├── featuresTable.mat
│   ├── baseline_model.mat
│   ├── evalResults.mat
│   ├── optResults.mat
│   ├── PCA_scatter.png
│   ├── feature_boxplots.png
│   ├── confusion_matrix.png
│   ├── FAR_FRR_curve.png
│   └── TAR_vs_FAR.png
│
├── run_all.m                   # Main orchestration script
├── preprocess_data.m           # Data cleaning and normalization
├── extract_features.m          # Feature computation
├── train_nn.m                  # Neural network training
├── evaluate_model.m            # Performance evaluation
├── optimize_model.m            # Feature selection & tuning
├── helpers_variability_plot.m  # Visualization functions
└── README.md                   # This file
```

---

## 🔧 Requirements

### Software
- **MATLAB**: R2023b or newer
- **Toolboxes**:
  - Deep Learning Toolbox
  - Statistics and Machine Learning Toolbox
  - Signal Processing Toolbox

### Dataset
The `Dataset/` folder should contain accelerometer CSV files from multiple users:
- Format: `U<N>NW_FD.csv` and `U<N>NW_MD.csv` (N = 1 to 10)
- Columns: `[index, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z]`
- Data collected from walking trials over ~12 minutes per user

---

## 🚀 How to Run

### Quick Start

1. Open MATLAB and navigate to the project directory
2. Ensure `Dataset/` folder contains the CSV files
3. Run the main script:

```matlab
>> run_all
```

This will execute all 6 steps automatically:
1. Preprocessing
2. Feature Extraction
3. Variability Analysis
4. Model Training
5. Model Evaluation
6. Model Optimization

### Running Individual Steps

You can also run each step independently:

```matlab
>> preprocess_data();              % Step 1
>> extract_features();             % Step 2
>> helpers_variability_plot();     % Step 3
>> train_nn();                     % Step 4
>> evaluate_model();               % Step 5
>> optimize_model();               % Step 6
```

---

## 📊 Dataset and Preprocessing

### Data Collection
- **Source**: Accelerometer sensors from smartphones/wearables
- **Activity**: Normal walking patterns
- **Users**: 10 participants (User 1 - User 10)
- **Duration**: ~12 minutes per user across 2 sessions

### Preprocessing Steps (`preprocess_data.m`)

1. **Data Loading**: Read CSV files from `Dataset/` folder
2. **Signal Extraction**: Extract x, y, z accelerometer axes
3. **Missing Values**: Fill gaps using linear interpolation
4. **Detrending**: Remove DC offset from signals
5. **Normalization**: Z-score normalization per axis
6. **Output**: `results/preprocessed.mat`

---

## 🧬 Feature Extraction

### Window Configuration
- **Window Size**: 2.0 seconds
- **Overlap**: 50%
- **Sampling Rate**: 30 Hz (standardized)

### Features Computed (per window)

#### Time Domain Features (per axis: X, Y, Z)
- **Statistical**: Mean, Std, Variance, Skewness, Kurtosis
- **Range-based**: Min, Max, Median, Range, IQR
- **Signal**: RMS, Zero Crossing Rate

#### Frequency Domain Features (per axis)
- **Dominant Frequency**: Peak in power spectrum
- **Spectral Entropy**: Measure of signal complexity
- **Energy**: Total signal energy

#### Cross-Axis Features
- **Correlations**: XY, XZ, YZ correlation coefficients

#### Magnitude Features
- **Magnitude Signal**: √(x² + y² + z²)
- **Magnitude Statistics**: Mean, Std, Energy

**Total Features**: 51 features per window

---

## 🧠 Neural Network Architecture

### Baseline Model (`train_nn.m`)

```
Input Layer:  51 neurons (features)
      ↓
Hidden Layer 1: 128 neurons (ReLU)
      ↓
Hidden Layer 2: 64 neurons (ReLU)
      ↓
Output Layer: 10 neurons (Softmax - one per user)
```

### Training Configuration
- **Loss Function**: Cross-entropy
- **Optimizer**: Scaled Conjugate Gradient (trainscg)
- **Epochs**: 300
- **Data Split**: 75% training / 25% testing (stratified)
- **Validation**: 15% of training data
- **Preprocessing**: Z-score normalization

---

## 📈 Evaluation Metrics

### Performance Metrics (`evaluate_model.m`)

#### 1. Classification Accuracy
Percentage of correctly identified users on test set.

#### 2. Confusion Matrix
Visual representation of true vs. predicted classifications.

#### 3. False Acceptance Rate (FAR)
```
FAR = Number of Impostor Acceptances / Total Impostor Attempts
```
Probability that the system incorrectly accepts an unauthorized user.

#### 4. False Rejection Rate (FRR)
```
FRR = Number of Genuine Rejections / Total Genuine Attempts
```
Probability that the system incorrectly rejects an authorized user.

#### 5. Equal Error Rate (EER)
```
EER = Point where FAR = FRR
```
Lower EER indicates better system performance. Typical good values: < 5%

#### 6. TAR vs FAR Curve
True Acceptance Rate vs False Acceptance Rate (similar to ROC curve).

---

## 🔬 Optimization Approach

### Feature Selection (`optimize_model.m`)

**Methods** (in priority order):
1. **FSCMRMR**: Minimum Redundancy Maximum Relevance
2. **ReliefF**: Weight features by nearest-neighbor analysis
3. **ANOVA F-test**: Statistical significance testing (fallback)

**Feature Count Testing**: k = [5, 10, 15, 20, 30, All]

### Architecture Search

**Tested Architectures**:
- `[64, 32]`: Smaller network
- `[128, 64]`: Baseline (default)
- `[256, 128]`: Larger network
- `[128]`: Single hidden layer
- `[256]`: Single larger layer

### Cross-Validation
- **Method**: 4-fold stratified CV
- **Purpose**: Robust performance estimation

### Expected Improvements
- Baseline accuracy: ~85-95%
- Optimized accuracy: typically +2-5% improvement
- Reduced computational cost through feature selection

---

## 📸 Generated Outputs

### 1. `PCA_scatter.png`
2D visualization showing how users cluster in feature space. Well-separated clusters indicate strong discriminative power.

### 2. `feature_boxplots.png`
Distribution of top 6 discriminative features across users. Shows within-user consistency vs. between-user variability.

### 3. `confusion_matrix.png`
Per-user classification accuracy. Diagonal elements show correct classifications.

### 4. `FAR_FRR_curve.png`
Trade-off between false acceptances and false rejections across different decision thresholds. Shows EER point.

### 5. `TAR_vs_FAR.png`
ROC-style curve showing True Acceptance Rate vs. False Acceptance Rate.

---

## 💡 Key Insights

### Feature Variability
- **Between-user variance**: High variability indicates features can distinguish users
- **Within-user variance**: Low variability indicates consistency for same user
- **Top discriminative features**: Typically magnitude-based and frequency features

### Security Implications

**Advantages**:
- ✅ Continuous authentication (not just at login)
- ✅ Passive monitoring (transparent to user)
- ✅ Difficult to forge behavioral patterns
- ✅ No additional hardware required

**Privacy Concerns**:
- ⚠️ Continuous data collection
- ⚠️ Potential health information leakage (gait abnormalities)
- ⚠️ User tracking across sessions

**Limitations**:
- ⚠️ Performance may degrade with injuries or mood changes
- ⚠️ Environmental factors (terrain, footwear)
- ⚠️ Requires sufficient walking data

---

## 📚 References

[1] Kwapisz, J. R., Weiss, G. M., & Moore, S. A. (2011). Activity recognition using cell phone accelerometers. *ACM SIGKDD Explorations Newsletter*, 12(2), 74-82.

[2] Wang, J., Chen, Y., Hao, S., Peng, X., & Hu, L. (2016). Deep learning for sensor-based activity recognition: A survey. *Pattern Recognition Letters*, 119, 3-11.

[3] Goodfellow, I., Bengio, Y., & Courville, A. (2016). *Deep Learning*. MIT Press.

[4] Jain, A. K., Ross, A., & Prabhakar, S. (2004). An introduction to biometric recognition. *IEEE Transactions on Circuits and Systems for Video Technology*, 14(1), 4-20.

[5] Guyon, I., & Elisseeff, A. (2003). An introduction to variable and feature selection. *Journal of Machine Learning Research*, 3, 1157-1182.

[6] Jolliffe, I. T., & Cadima, J. (2016). Principal component analysis: a review and recent developments. *Philosophical Transactions of the Royal Society A*, 374(2065).

---

## 🎓 Academic Submission Checklist

- ✅ All code files properly commented
- ✅ Academic references included in code
- ✅ Reproducible results (random seed set)
- ✅ Comprehensive documentation
- ✅ Results folder with all outputs
- ✅ Privacy and ethical considerations discussed
- ✅ Performance metrics clearly defined
- ✅ Optimization approach explained

---

## 👨‍💻 Usage Tips

1. **First Run**: The complete pipeline takes ~5-15 minutes depending on dataset size
2. **Memory**: Ensure sufficient RAM for neural network training (~2-4 GB)
3. **Figures**: All plots saved automatically (no GUI interaction needed)
4. **Reproducibility**: Random seed set to 42 for consistent results
5. **Debugging**: Check `results/` folder if any step fails

---

## 📞 Support

For coursework questions:
- Review MATLAB documentation for toolbox functions
- Check error messages in console output
- Verify dataset format matches expected structure

---

## 📄 License

This project is for educational purposes as part of PUSL3123 coursework.

---

**✨ Ready for submission! All requirements met. ✨**
