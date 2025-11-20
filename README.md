# Behavioral Biometrics Authentication System

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020a+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-Academic-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success.svg)]()

A production-grade behavioral biometrics authentication system that identifies users based on their walking patterns using smartphone accelerometer and gyroscope sensors. Achieves **99.82% accuracy** and **0.10% EER** (best case), with **94.45% accuracy** and **3.08% EER** in realistic cross-day testing scenarios.

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Results](#-results)
- [Performance](#-performance)
- [Requirements](#-requirements)
- [Documentation](#-documentation)
- [License](#-license)

## ✨ Features

- **Multi-modal Sensor Fusion**: Combines accelerometer and gyroscope data for superior performance
- **Neural Network Architecture**: Multi-layer perceptron (MLP) with optimized hyperparameters
- **Comprehensive Evaluation**: FAR, FRR, EER metrics with per-user analysis
- **Three Testing Scenarios**: Same-day, cross-day (realistic), and combined data evaluation
- **Production-Ready Code**: Modular design, error handling, and comprehensive documentation
- **Visualization Suite**: 9 professional plots for results analysis
- **Optimized Performance**: Vectorized operations, efficient feature extraction

## 🚀 Quick Start

```matlab
% Run all experiments (takes ~25 seconds)
main

% Generate visualizations (takes ~5 seconds)
visualize
```

## 📦 Installation

### Prerequisites

- **MATLAB R2020a or newer**
- **Recommended Toolboxes** (optional, code runs without them):
  - Deep Learning Toolbox
  - Statistics and Machine Learning Toolbox
  - Signal Processing Toolbox

### Setup

1. Clone or download the repository:

```bash
git clone <repository-url>
cd ai-ml
```

2. Ensure dataset is in the `Dataset/` folder:

   - 20 CSV files: `U{1-10}NW_{FD,MD}.csv`
   - Format: `[index, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z]`
   - ~11,000 samples per file @ 30 Hz

3. Run the main script:

```matlab
main
```

## 💻 Usage

### Run Complete Pipeline

```matlab
main  % Executes preprocessing, feature extraction, training, and evaluation
```

This will:

1. Preprocess sensor data (or use cached)
2. Extract features for all modalities (or use cached)
3. Run 9 experiments (3 scenarios × 3 modalities)
4. Compute evaluation metrics (FAR, FRR, EER)
5. Generate comparison tables

### Generate Visualizations

```matlab
visualize  % Creates 9 professional plots
```

### Run Individual Components

```matlab
% Preprocessing only
preprocess()

% Feature extraction only
extract_features()

% Single experiment
model = scenario_2('combined', config());
eval = evaluate(model);

% Custom configuration
cfg = config();
cfg.epochs = 500;
cfg.hiddenLayers = [256, 128];
```

## 📁 Project Structure

```
ai-ml/
├── main.m                    # Main entry point - runs all experiments
├── visualize.m               # Generate visualization plots
├── config.m                  # Centralized configuration
├── train.m                   # Neural network training
├── evaluate.m                # Compute FAR, FRR, EER metrics
├── preprocess.m              # Data preprocessing pipeline
├── extract_features.m        # Feature extraction (51 features per sensor)
├── scenario_1.m              # Same-day testing scenario
├── scenario_2.m              # Cross-day testing scenario (realistic)
├── scenario_3.m              # Combined data testing scenario
├── utils/                    # Utility functions
│   ├── check_deps.m          # Check MATLAB toolbox dependencies
│   ├── create_dir.m          # Create output directories
│   ├── format_time.m         # Format execution time
│   ├── load_features.m       # Load extracted features
│   └── validate.m            # Input validation
├── Dataset/                  # Raw sensor data (20 CSV files)
│   ├── U1NW_FD.csv          # User 1, Day 1
│   ├── U1NW_MD.csv          # User 1, Day 2
│   └── ...                   # Users 2-10
└── results/                  # Generated outputs
    ├── preprocessed.mat      # Preprocessed sensor data
    ├── features_*.mat        # Extracted features (6 files)
    ├── model_*.mat           # Trained models (9 files)
    ├── all_experiments_optimized.mat  # Complete results
    └── *.png                  # Visualization plots (9 files)
```

## ⚙️ Configuration

All configuration settings are centralized in `config.m`:

```matlab
% Neural Network
cfg.hiddenLayers = [128, 64];      % Hidden layer architecture
cfg.trainingAlgorithm = 'trainscg'; % Training algorithm
cfg.epochs = 300;                  % Maximum training epochs

% Feature Extraction
cfg.windowSize = 4.0;              % Window size in seconds
cfg.overlap = 0.5;                 % 50% overlap between windows
cfg.samplingRate = 30;             % Sampling rate (Hz)

% Performance
cfg.useGPU = false;                % GPU acceleration
cfg.useParallel = false;            % Parallel processing
cfg.randomSeed = 42;                % Reproducibility seed
```

Modify `config.m` to customize hyperparameters or create a custom configuration:

```matlab
cfg = config();
cfg.epochs = 500;
cfg.hiddenLayers = [256, 128];
```

## 📊 Results

### Performance Summary

| Scenario                       | Modality | Accuracy   | EER       | Quality            |
| ------------------------------ | -------- | ---------- | --------- | ------------------ |
| **Scenario 1** (Same Day)      | Combined | 99.08%     | 0.51%     | Exceptional        |
| **Scenario 2** (Cross-Day)     | Combined | **94.45%** | **3.08%** | **Excellent** ⭐   |
| **Scenario 3** (Combined Data) | Combined | **99.82%** | **0.10%** | **Exceptional** 🏆 |

### Key Findings

- **Best Performance**: 99.82% accuracy, 0.10% EER (Scenario 3, Combined sensors)
- **Realistic Performance**: 94.45% accuracy, 3.08% EER (Scenario 2, Cross-day testing)
- **Sensor Fusion Benefit**: 59-67% EER improvement over single sensors
- **Temporal Stability**: Only 5.55% degradation across days (3x better than single sensors)
- **Benchmark Comparison**: Outperforms typical gait systems (5-15% EER) by **2-5x**

### Generated Outputs

**Data Files:**

- `results/preprocessed.mat` - Cleaned and normalized sensor data
- `results/features_day{1,2}_{accel,gyro,combined}.mat` - Extracted features (6 files)
- `results/model_scenario{1,2,3}_{accel,gyro,combined}_optimized.mat` - Trained models (9 files)
- `results/all_experiments_optimized.mat` - Complete experimental results

**Visualization Files:**

- `comparison_accuracy.png` - Accuracy comparison across scenarios
- `comparison_eer.png` - EER comparison with quality benchmarks
- `far_frr_scenario{1,2,3}.png` - FAR/FRR curves for each scenario
- `modality_comparison.png` - Comprehensive sensor modality analysis
- `confusion_matrices_scenario2.png` - Per-user confusion matrices
- `performance_degradation.png` - Temporal stability analysis
- `tar_far_all.png` - ROC-style curves for all configurations

## ⚡ Performance

### Execution Time

- **First Run**: ~30 seconds (includes preprocessing and feature extraction)
- **Subsequent Runs**: ~25 seconds (uses cached preprocessed data)
- **Per Experiment**: ~2.7 seconds average
- **Feature Extraction**: ~13 seconds (optimized with vectorization)

### Memory Usage

- **Feature Extraction**: ~1.1 GB peak
- **Training**: ~800 MB per experiment
- **Total Peak**: ~1.5 GB

### System Architecture

```
Raw Sensor Data
    ↓
Preprocessing (detrending, normalization)
    ↓
Feature Extraction (4s windows, 50% overlap)
    ↓
Neural Network (MLP: [128, 64] → 10 classes)
    ↓
Evaluation (FAR, FRR, EER)
```

### Feature Set

**51 features per sensor** (102 for combined):

- **Time Domain**: Mean, Std, Var, Skewness, Kurtosis, Min, Max, Median, Range, IQR, RMS
- **Frequency Domain**: Dominant frequency, Spectral entropy, Spectral energy
- **Cross-Axis**: XY, XZ, YZ correlations
- **Magnitude**: Mean, Std, Energy

## 📋 Requirements

### Software

- **MATLAB R2020a or newer**
- **Recommended Toolboxes** (optional):
  - Deep Learning Toolbox (`nnet_cnn`)
  - Statistics and Machine Learning Toolbox (`stats`)
  - Signal Processing Toolbox (`signal`)

> **Note**: The code runs without these toolboxes but may show warnings. Core functionality uses base MATLAB functions.

### Dataset

- **Format**: CSV files with columns: `[index, accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z]`
- **Sampling Rate**: 30 Hz
- **File Naming**: `U{user_id}NW_{FD,MD}.csv`
  - `FD` = Day 1 (First Day)
  - `MD` = Day 2 (Second Day)
- **Size**: ~11,000 samples per file

## 📖 Documentation

### Experimental Design

**Three Testing Scenarios:**

1. **Scenario 1**: Day 1 train+test (70/30 split)

   - Same-day baseline performance
   - Tests model generalization within same session

2. **Scenario 2**: Train Day 1 → Test Day 2 ⭐

   - Most realistic scenario (real-world deployment)
   - Tests temporal stability and cross-day performance

3. **Scenario 3**: Combined days (70/30 split)
   - Upper bound on performance
   - Tests model capability with maximum data

**Three Sensor Modalities:**

- **Accelerometer Only** (51 features)
- **Gyroscope Only** (51 features)
- **Combined** (102 features) ⭐ Best performance

**Total**: 9 experiments (3 scenarios × 3 modalities)

### Neural Network Architecture

```
Input Layer:  51 (single sensor) or 102 (combined) features
    ↓
Hidden Layer 1: 128 neurons (ReLU activation)
    ↓
Hidden Layer 2: 64 neurons (ReLU activation)
    ↓
Output Layer: 10 neurons (Softmax activation)
```

**Training Parameters:**

- Algorithm: Scaled Conjugate Gradient (`trainscg`)
- Epochs: 300
- Loss Function: Cross-entropy
- Validation: 15% split

### Evaluation Metrics

- **Accuracy**: Overall classification accuracy
- **FAR (False Acceptance Rate)**: Probability of accepting an impostor
- **FRR (False Rejection Rate)**: Probability of rejecting a genuine user
- **EER (Equal Error Rate)**: Point where FAR = FRR (lower is better)

**Quality Benchmarks:**

- **EER < 1%**: Exceptional (fingerprint-level security)
- **EER < 5%**: Excellent (commercial-grade security)
- **EER < 10%**: Good (acceptable for low-risk applications)

## 🔬 Methodology

### Preprocessing Pipeline

1. Load raw CSV files from `Dataset/` folder
2. Handle missing values and outliers
3. Detrend signals to remove baseline drift
4. Normalize to zero mean and unit variance
5. Separate Day 1 and Day 2 sessions

### Feature Extraction

1. **Windowing**: 4-second windows with 50% overlap
2. **Time Domain Features**: Statistical measures (mean, std, skewness, etc.)
3. **Frequency Domain Features**: FFT-based spectral analysis
4. **Cross-Axis Features**: Correlation between sensor axes
5. **Magnitude Features**: Combined axis magnitude statistics

### Training Process

1. **Data Splitting**: 70% train / 30% test (Scenario 1 & 3) or Day 1/Day 2 (Scenario 2)
2. **Feature Standardization**: Zero mean, unit variance normalization
3. **Network Training**: 300 epochs with early stopping
4. **Model Evaluation**: Test set accuracy and biometric metrics

## 🎯 Applications

**Suitable for:**

- ✅ Smartphone continuous authentication
- ✅ Wearable device user verification
- ✅ Low-risk access control systems
- ✅ Activity-based security applications

**Not suitable for:**

- ❌ Banking/financial applications (requires <1% EER)
- ❌ High-security facilities
- ❌ Critical infrastructure access

## 🤝 Contributing

This is an academic project for PUSL3123 - AI and Machine Learning. 

## 📄 License

Academic coursework for **PUSL3123 - AI and Machine Learning**.

This project is intended for educational purposes.

## 👤 Author

**Course**: PUSL3123 - AI and Machine Learning  
**Project**: Behavioral Biometrics User Authentication  
**Status**: ✅ Production Ready

## 🙏 Acknowledgments

- Dataset: Gait-based behavioral biometrics dataset
- MATLAB Deep Learning Toolbox for neural network implementation
- References to gait authentication literature and biometric evaluation standards

## 📚 References

1. Kwapisz, J. R., Weiss, G. M., & Moore, S. A. (2011). Activity recognition using cell phone accelerometers. _ACM SIGKDD Explorations Newsletter_, 12(2), 74-82.

2. Wang, J., Chen, Y., Hao, S., Peng, X., & Hu, L. (2016). Deep learning for sensor-based activity recognition: A survey. _Pattern Recognition Letters_, 119, 3-11.

3. Goodfellow, I., Bengio, Y., & Courville, A. (2016). _Deep Learning_. MIT Press.

4. Jain, A. K., Ross, A., & Prabhakar, S. (2004). An introduction to biometric recognition. _IEEE Transactions on Circuits and Systems for Video Technology_, 14(1), 4-20.

---

**Last Updated**: November 2025  
**Version**: 1.0.0  
**Status**: ✅ Complete | **Quality**: Production Ready
