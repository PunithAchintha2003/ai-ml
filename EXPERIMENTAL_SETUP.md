# Behavioral Biometrics - Complete Experimental Setup

## 📋 Overview

This project implements a comprehensive behavioral biometrics authentication system following the specified experimental setup with:

- **3 Testing Scenarios** (Train/Test configurations)
- **3 Modalities** (Accelerometer, Gyroscope, Combined)
- **Complete Evaluation Metrics** (FAR, FRR, EER)

**Total Experiments: 9** (3 scenarios × 3 modalities)

---

## 🧪 Experimental Scenarios

### Test 1: Train and Test on Day 1 Data
- **Training:** Random 70% of Day 1 data
- **Testing:** Remaining 30% of Day 1 data
- **Purpose:** Evaluates same-day performance (ideal conditions)
- **Expected:** Highest accuracy (no temporal variation)

### Test 2: Train on Day 1, Test on Day 2 ⭐ **MOST REALISTIC**
- **Training:** ALL Day 1 data
- **Testing:** ALL Day 2 data
- **Purpose:** Evaluates cross-day generalization
- **Why Realistic:** Users don't retrain the system every time
- **Expected:** Some accuracy drop due to behavioral changes

### Test 3: Combined Data with 70/30 Split
- **Training:** Random 70% from combined Day 1 + Day 2
- **Testing:** Remaining 30% from combined data
- **Purpose:** Shows maximum achievable performance
- **Expected:** Upper bound on accuracy

---

## 🎯 Modalities Tested

### 1. Accelerometer Only
- Features from X, Y, Z acceleration axes
- 51 features per window

### 2. Gyroscope Only
- Features from X, Y, Z gyroscope axes
- 51 features per window

### 3. Combined Sensors
- Features from both accelerometer and gyroscope
- 102 features per window
- Expected to provide best performance

---

## 📁 File Structure

```
ai-ml/
├── Dataset/                          # Raw CSV files
│   ├── U1NW_FD.csv                  # User 1, Day 1
│   ├── U1NW_MD.csv                  # User 1, Day 2
│   └── ... (U2-U10)
│
├── results/                          # Auto-generated outputs
│   ├── preprocessed.mat
│   ├── features_day1_*.mat          # Day 1 features
│   ├── features_day2_*.mat          # Day 2 features
│   ├── model_scenario*_*.mat        # Trained models
│   ├── all_experiments.mat          # Complete results
│   └── *.png                        # Visualization plots
│
├── preprocess_data.m                # Step 1: Data preprocessing
├── extract_features.m               # Step 2: Feature extraction
├── train_test_scenario1.m           # Test 1 implementation
├── train_test_scenario2.m           # Test 2 implementation
├── train_test_scenario3.m           # Test 3 implementation
├── evaluate_scenarios.m             # FAR/FRR/EER computation
├── run_experiments.m                # Main orchestration script
├── visualize_results.m              # Generate comparison plots
└── EXPERIMENTAL_SETUP.md            # This file
```

---

## 🚀 How to Run

### Option 1: Run All Experiments (Recommended)

```matlab
>> run_experiments
```

This will:
1. Preprocess all data (Day 1 and Day 2 separation)
2. Extract features for all modalities
3. Train and test all 9 configurations
4. Compute FAR, FRR, EER for each
5. Generate comparison tables
6. Save all results

**Estimated Time:** 10-20 minutes (depending on hardware)

### Option 2: Generate Visualizations

After running experiments:

```matlab
>> visualize_results
```

This creates:
- Accuracy comparison charts
- EER comparison (lower is better)
- FAR/FRR curves for all scenarios
- Confusion matrices
- Performance degradation analysis
- Comprehensive modality comparison

### Option 3: Run Individual Steps

```matlab
% Step 1: Preprocess
>> preprocess_data();

% Step 2: Extract features
>> extract_features();

% Step 3: Run specific scenario
>> results_s1_accel = train_test_scenario1('accel');
>> results_s2_gyro = train_test_scenario2('gyro');
>> results_s3_combined = train_test_scenario3('combined');

% Step 4: Evaluate
>> evaluation = evaluate_scenarios(results_s2_combined);

% Step 5: Visualize
>> visualize_results();
```

---

## 📊 Output Files

### Data Files (`.mat`)
- `preprocessed.mat` - Cleaned sensor data
- `features_day1_accel.mat` - Day 1 accelerometer features
- `features_day1_gyro.mat` - Day 1 gyroscope features
- `features_day1_combined.mat` - Day 1 combined features
- `features_day2_*.mat` - Day 2 features (same structure)
- `model_scenario1_accel.mat` - Trained model + evaluation
- ... (9 model files total)
- `all_experiments.mat` - Comprehensive results

### Visualization Files (`.png`)
- `comparison_accuracy.png` - Accuracy across scenarios
- `comparison_eer.png` - EER comparison
- `far_frr_scenario1.png` - FAR/FRR curves (Scenario 1)
- `far_frr_scenario2.png` - FAR/FRR curves (Scenario 2)
- `far_frr_scenario3.png` - FAR/FRR curves (Scenario 3)
- `modality_comparison.png` - All metrics by modality
- `confusion_matrices_scenario2.png` - Per-user analysis
- `performance_degradation.png` - Temporal stability
- `tar_far_all.png` - ROC-style curves

---

## 📈 Evaluation Metrics

### 1. Accuracy
- Percentage of correctly identified users
- Standard classification metric

### 2. False Acceptance Rate (FAR)
- **Definition:** Probability system accepts an impostor
- **Security Metric:** Lower is better
- **Calculation:** FA / Total Impostor Attempts
- **Goal:** FAR < 5%

### 3. False Rejection Rate (FRR)
- **Definition:** Probability system rejects genuine user
- **Usability Metric:** Lower is better
- **Calculation:** FR / Total Genuine Attempts
- **Goal:** FRR < 5%

### 4. Equal Error Rate (EER) ⭐
- **Definition:** Point where FAR = FRR
- **Primary Metric:** Balances security and usability
- **Quality Levels:**
  - **< 1%:** Exceptional (fingerprint-level)
  - **1-5%:** Excellent (commercial-grade) ✅ TARGET
  - **5-10%:** Good (acceptable)
  - **10-20%:** Fair (needs improvement)
  - **> 20%:** Poor (not viable)

### 5. True Acceptance Rate (TAR)
- **Definition:** TAR = 1 - FRR
- **Used in:** TAR vs FAR curves (ROC-style)

---

## 🎯 Expected Results

### Scenario Ranking (by accuracy)
1. **Test 3 (Combined):** Highest (has diverse training data)
2. **Test 1 (Day 1):** High (no temporal variation)
3. **Test 2 (Day 1→2):** Lowest (cross-day generalization)

### Modality Ranking
1. **Combined:** Best (most information)
2. **Accelerometer:** Good (captures gait patterns well)
3. **Gyroscope:** Fair (less discriminative for walking)

### Performance Degradation (Test 2)
- **Expected:** 2-10% accuracy drop from Day 1 to Day 2
- **Reason:** Behavioral variations (time, mood, environment)
- **If > 10%:** Significant temporal instability

---

## 📝 Report Recommendations

### Required Visualizations
1. **comparison_accuracy.png** - Show all scenarios
2. **comparison_eer.png** - Primary evaluation metric
3. **far_frr_scenario2.png** - Most realistic scenario
4. **modality_comparison.png** - Justify sensor choice

### Discussion Points

#### Test 1 Results
- "Test 1 achieved XX% accuracy with EER of XX%, representing ideal same-day performance. This serves as an upper bound for what the system can achieve in controlled conditions."

#### Test 2 Results (MOST IMPORTANT)
- "Test 2 is the most realistic scenario, achieving XX% accuracy with EER of XX%. This represents real-world deployment where users don't retrain the system daily."
- "Performance degradation of XX% from Day 1 to Day 2 indicates [stable/variable] behavioral patterns."

#### Test 3 Results
- "Test 3 achieved XX% accuracy by training on diverse data from multiple sessions, providing an upper bound with XX% EER."

#### Modality Comparison
- "Combined sensors achieved XX% accuracy vs XX% (accel) and XX% (gyro), demonstrating that multi-modal fusion improves authentication by XX%."

#### Optimization
- "While combined sensors provide best performance, accelerometer-only achieves XX% accuracy with lower cost (no gyroscope needed)."

---

## 🔍 Troubleshooting

### Issue: "No CSV files found"
**Solution:** Ensure Dataset/ folder contains U1NW_FD.csv through U10NW_MD.csv (20 files)

### Issue: Memory error during training
**Solution:** 
- Close other MATLAB figures
- Reduce hidden layer sizes in scenario scripts
- Process fewer users (modify code to use subset)

### Issue: Plots not displaying
**Solution:** MATLAB figures are auto-saved to results/. Check folder even if not displayed.

### Issue: Different results each run
**Note:** Random seed is set (rng(42)) for reproducibility. Results should be consistent.

---

## ⚙️ Configuration

### Window Segmentation
- **Window size:** 4 seconds (120 samples at 30 Hz)
- **Overlap:** 50% (2-second step)
- **Modify in:** `extract_features.m` line 47-48

### Neural Network Architecture
- **Default:** [128, 64] hidden layers
- **Modify in:** Each `train_test_scenarioX.m` line 90
- **Alternatives:** [256, 128], [64, 32], [128]

### Train/Test Split Ratios
- **Scenario 1:** 70/30 (line 36 in scenario1)
- **Scenario 3:** 70/30 (line 68 in scenario3)
- **Modify:** Change `cvpartition` HoldOut parameter

---

## 🎓 Academic Context

### Coursework Requirements Met
✅ Three different testing scenarios  
✅ Data segmentation with overlapping windows  
✅ Feature extraction (time + frequency domain)  
✅ Neural network training (MLP/PatternNet)  
✅ FAR, FRR, EER evaluation  
✅ Multiple modality comparison  
✅ Optimization analysis  
✅ Comprehensive visualizations  

### Key Insights to Discuss
1. **Scenario 2 is most realistic** - no retraining per use
2. **EER shows security-usability tradeoff**
3. **Combined sensors improve accuracy but increase cost**
4. **Performance degradation reveals temporal stability**
5. **Per-user variation identifies challenging cases**

---

## 📚 References

[1] Kwapisz, J. R., et al. (2011). Activity recognition using cell phone accelerometers.  
[2] Wang, J., et al. (2016). Deep learning for sensor-based activity recognition.  
[3] Goodfellow, I., et al. (2016). Deep Learning. MIT Press.  
[4] Jain, A. K., et al. (2004). An introduction to biometric recognition.  
[5] Guyon, I., & Elisseeff, A. (2003). Feature selection review.

---

## ✅ Quick Checklist

Before submitting:
- [ ] Run `run_experiments.m` successfully
- [ ] Run `visualize_results.m` to generate plots
- [ ] Check results/ folder contains all output files
- [ ] Review comparison table in console output
- [ ] Include key plots in report
- [ ] Discuss all three scenarios
- [ ] Compare all three modalities
- [ ] Interpret EER values
- [ ] Explain performance degradation (Test 2)
- [ ] Attach MATLAB code in appendix

---

## 🏆 Success Criteria

- ✅ All 9 experiments complete without errors
- ✅ EER < 10% for most configurations
- ✅ Test 3 accuracy > Test 2 accuracy (as expected)
- ✅ Combined modality outperforms single sensors
- ✅ Clear visualizations for report
- ✅ Comprehensive evaluation metrics

---

**Ready to run!** Start with: `>> run_experiments`

Good luck with your coursework! 🎓
