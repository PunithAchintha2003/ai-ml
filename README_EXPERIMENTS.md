# Behavioral Biometrics - Experimental Setup Implementation

## 🎯 Quick Start

### Run All Experiments
```matlab
>> cd /Volumes/Apple/workspace/ai-ml
>> run_experiments
```

**This single command will:**
1. ✅ Preprocess data (Day 1 and Day 2 separation)
2. ✅ Extract features (3 modalities × 2 days = 6 feature sets)
3. ✅ Train and test all 9 configurations
4. ✅ Compute FAR, FRR, EER for each
5. ✅ Generate comprehensive comparison tables

**Expected Time:** 10-20 minutes

### Generate Visualizations
```matlab
>> visualize_results
```

---

## 📊 What You Get

### Console Output
- **Real-time progress** for all 9 experiments
- **Comprehensive comparison table** with all metrics
- **Best performing configurations** automatically identified
- **Per-user performance** for each scenario

### Example Output:
```
════════════════════════════════════════════════════════════════════════════════
COMPREHENSIVE RESULTS COMPARISON (All Scenarios × All Modalities)
════════════════════════════════════════════════════════════════════════════════
Scenario                                  | Modality             | Train Acc  | Test Acc   | EER      | Avg FAR   | Avg FRR
────────────────────────────────────────────────────────────────────────────────
Test 1: Day 1 Train+Test                 | Accelerometer Only   | 94.23      | 91.45      | 4.12     | 3.89      | 4.35
Test 1: Day 1 Train+Test                 | Gyroscope Only       | 89.67      | 86.23      | 6.78     | 6.23      | 7.34
Test 1: Day 1 Train+Test                 | Combined Sensors     | 96.34      | 94.12      | 2.89     | 2.67      | 3.12
Test 2: Day 1→2 (REALISTIC)              | Accelerometer Only   | 94.23      | 87.56      | 6.23     | 5.89      | 6.58
Test 2: Day 1→2 (REALISTIC)              | Gyroscope Only       | 89.67      | 82.34      | 8.91     | 8.45      | 9.38
Test 2: Day 1→2 (REALISTIC)              | Combined Sensors     | 96.34      | 91.23      | 4.45     | 4.12      | 4.78
Test 3: Combined 70/30                   | Accelerometer Only   | 95.12      | 92.34      | 3.78     | 3.45      | 4.12
Test 3: Combined 70/30                   | Gyroscope Only       | 90.45      | 87.89      | 5.89     | 5.56      | 6.23
Test 3: Combined 70/30                   | Combined Sensors     | 97.23      | 95.67      | 2.34     | 2.12      | 2.56
════════════════════════════════════════════════════════════════════════════════
```

### Generated Files

#### Data Files (in `results/`)
- `preprocessed.mat` - Separated Day 1/Day 2 sensor data
- `features_day1_accel.mat` - Accelerometer features (Day 1)
- `features_day1_gyro.mat` - Gyroscope features (Day 1)
- `features_day1_combined.mat` - Combined features (Day 1)
- `features_day2_*.mat` - Same structure for Day 2
- `model_scenario1_accel.mat` - Model + evaluation (9 files total)
- `all_experiments.mat` - Complete results package

#### Visualization Files (in `results/`)
- `comparison_accuracy.png` - Bar chart comparing all configurations
- `comparison_eer.png` - EER comparison (lower is better)
- `far_frr_scenario1.png` - FAR/FRR curves for Scenario 1
- `far_frr_scenario2.png` - FAR/FRR curves for Scenario 2 ⭐
- `far_frr_scenario3.png` - FAR/FRR curves for Scenario 3
- `modality_comparison.png` - 4-panel comprehensive analysis
- `confusion_matrices_scenario2.png` - Per-user breakdown
- `performance_degradation.png` - Temporal stability analysis
- `tar_far_all.png` - ROC-style curves (3×3 grid)

---

## 🧪 The Three Testing Scenarios

### Scenario 1: Day 1 Train + Test (Same Day)
- **Split:** 70% train, 30% test (from Day 1 only)
- **Purpose:** Best-case performance (no temporal variation)
- **Use Case:** Ideal conditions benchmark
- **Expected:** Highest accuracy

### Scenario 2: Day 1 Train → Day 2 Test ⭐ MOST REALISTIC
- **Training:** ALL Day 1 data
- **Testing:** ALL Day 2 data
- **Purpose:** Real-world deployment simulation
- **Why Important:** Users don't retrain systems daily
- **Expected:** Some accuracy drop due to behavioral changes

### Scenario 3: Combined 70/30 Split
- **Data:** Combined Day 1 + Day 2
- **Split:** 70% train, 30% test (stratified)
- **Purpose:** Maximum achievable performance
- **Use Case:** Upper bound with diverse training data
- **Expected:** Best overall accuracy

---

## 🎛️ The Three Modalities

### 1. Accelerometer Only
- **Sensors:** X, Y, Z acceleration
- **Features:** 51 per window
- **Pros:** Captures gait patterns well, low cost
- **Cons:** Less information than combined

### 2. Gyroscope Only
- **Sensors:** X, Y, Z angular velocity
- **Features:** 51 per window
- **Pros:** Captures rotational movements
- **Cons:** Less discriminative for walking patterns

### 3. Combined Sensors ⭐
- **Sensors:** Accelerometer + Gyroscope
- **Features:** 102 per window
- **Pros:** Maximum information, best accuracy
- **Cons:** Higher computational cost

---

## 📈 Understanding the Metrics

### Accuracy
- **What:** % of correctly identified users
- **Goal:** > 90%
- **Interpretation:** General performance indicator

### FAR (False Acceptance Rate)
- **What:** % of impostors incorrectly accepted
- **Goal:** < 5%
- **Security Risk:** High FAR = easy to fool
- **Formula:** False Acceptances / Total Impostor Attempts

### FRR (False Rejection Rate)
- **What:** % of genuine users incorrectly rejected
- **Goal:** < 5%
- **Usability Issue:** High FRR = frustrating for users
- **Formula:** False Rejections / Total Genuine Attempts

### EER (Equal Error Rate) ⭐ PRIMARY METRIC
- **What:** Point where FAR = FRR
- **Goal:** < 5% (Excellent), < 10% (Good)
- **Why Important:** Balances security and usability
- **Quality Scale:**
  - **< 1%:** Exceptional (fingerprint-level) 🏆
  - **1-5%:** Excellent (commercial-grade) ✅
  - **5-10%:** Good (acceptable) 👍
  - **10-20%:** Fair (needs improvement) ⚠️
  - **> 20%:** Poor (not viable) ❌

---

## 📊 Using Results in Your Report

### Section: Results
Include these plots:
1. **comparison_accuracy.png** - "Figure X shows test accuracy across all 9 configurations..."
2. **comparison_eer.png** - "EER comparison (Figure X) demonstrates that combined sensors achieve..."

### Section: Realistic Scenario Analysis
Include:
1. **far_frr_scenario2.png** - "FAR/FRR curves for the most realistic scenario..."
2. **performance_degradation.png** - "Performance degradation from Day 1 to Day 2 indicates..."

### Section: Modality Comparison
Include:
1. **modality_comparison.png** - "Comprehensive analysis (Figure X) shows combined sensors outperform..."

### Section: Per-User Analysis
Include:
1. **confusion_matrices_scenario2.png** - "Confusion matrices reveal that Users 1 and 5..."

### Example Text:

#### Test 1 Results
> "Scenario 1 evaluated same-day performance by training and testing on Day 1 data with a 70/30 split. The combined modality achieved 94.12% accuracy with an EER of 2.89%, representing ideal conditions. This serves as an upper bound for same-session authentication."

#### Test 2 Results (MOST IMPORTANT)
> "Scenario 2 represents the most realistic deployment, training on Day 1 and testing on Day 2. The combined modality achieved 91.23% accuracy with an EER of 4.45%, demonstrating excellent performance (EER < 5%). Performance degradation of 2.89% from Day 1 to Day 2 indicates stable behavioral patterns across sessions, validating the system's temporal robustness."

#### Test 3 Results
> "Scenario 3 combined data from both days with a 70/30 split, achieving 95.67% accuracy and EER of 2.34%. This represents the maximum achievable performance when training on diverse multi-session data, providing an upper bound of 2.34% EER."

#### Modality Comparison
> "Combined sensors consistently outperformed single-sensor approaches across all scenarios. In the realistic scenario (Test 2), combined sensors achieved 91.23% accuracy vs 87.56% (accelerometer) and 82.34% (gyroscope), demonstrating that multi-modal fusion improves authentication by 3.67-8.89 percentage points. However, accelerometer-only still achieved excellent performance (EER = 6.23%), suggesting a viable low-cost alternative."

---

## 🔍 Interpreting Your Results

### If EER < 5% ✅
> "The system achieved commercial-grade performance suitable for smartphone authentication and continuous monitoring applications."

### If 5% < EER < 10% 👍
> "The system demonstrates good performance acceptable for low-risk applications, though improvements could enhance security."

### If EER > 10% ⚠️
> "Results suggest significant challenges with [specific modality/scenario]. Recommendations include: [feature engineering, more training data, different architecture]."

### If Performance Degrades Significantly (Day 1 → Day 2)
> "The X% performance drop indicates temporal behavioral instability. Potential causes include environmental changes, different footwear, or time-of-day effects. Future work should investigate adaptive models or periodic retraining strategies."

---

## 🎓 Discussion Points for Report

### 1. Why Scenario 2 is Most Important
- Real users don't retrain systems
- Captures day-to-day behavioral variations
- Tests true generalization ability
- Identifies temporal stability issues

### 2. Trade-offs Between Modalities
- **Combined:** Best accuracy but higher cost (requires both sensors)
- **Accelerometer:** Good balance of cost and performance
- **Gyroscope:** Weakest performer for gait-based authentication

### 3. Security vs Usability
- Lower threshold → Lower FAR (more secure) but Higher FRR (less usable)
- Higher threshold → Lower FRR (more usable) but Higher FAR (less secure)
- EER represents optimal balance point

### 4. Optimization Opportunities
- Reduce features while maintaining EER < 5%
- Use only accelerometer to reduce cost
- Adjust window size (currently 4 seconds)
- Test different neural network architectures

### 5. Limitations and Future Work
- Limited to walking patterns (not running, stairs, etc.)
- Performance may vary with footwear or terrain
- Long-term stability (weeks/months) not evaluated
- Small dataset (10 users, 2 days)

---

## ⚙️ Customization Options

### Change Window Size
In `extract_features.m`, line 47:
```matlab
windowSize = 4.0; % seconds (change to 2.0 or 6.0)
```

### Change Neural Network Architecture
In `train_test_scenarioX.m`, line 90:
```matlab
hiddenLayerSize = [128, 64]; % Change to [256, 128] or [64, 32]
```

### Change Train/Test Split
In `train_test_scenario1.m`, line 36:
```matlab
cv = cvpartition(y, 'HoldOut', 0.30); % 70/30 split (change 0.30 to 0.20 for 80/20)
```

### Process Fewer Users (for faster testing)
In `preprocess_data.m`, add after line 52:
```matlab
if userID > 5  % Only process first 5 users
    continue;
end
```

---

## 📋 Checklist for Report Submission

### Experiments
- [ ] Run `run_experiments.m` successfully (all 9 experiments)
- [ ] Run `visualize_results.m` to generate plots
- [ ] Verify results/ folder contains 9 model files

### Report Content
- [ ] Include comparison tables from console output
- [ ] Add comparison_accuracy.png in Results section
- [ ] Add comparison_eer.png in Results section
- [ ] Add far_frr_scenario2.png for realistic scenario
- [ ] Include modality_comparison.png
- [ ] Discuss all three scenarios
- [ ] Compare all three modalities
- [ ] Interpret EER values with quality scale
- [ ] Explain performance degradation (Test 2)
- [ ] Include per-user analysis

### Code Submission
- [ ] Attach all MATLAB files (.m)
- [ ] Include this README
- [ ] Add code snippets in appendix
- [ ] Comment code clearly

---

## 🆘 Troubleshooting

### "Out of memory" Error
**Solution:** Reduce hidden layer size or process fewer users

### "No such file" Error
**Solution:** Ensure you're in the project directory: `cd /Volumes/Apple/workspace/ai-ml`

### "Invalid modality" Error
**Solution:** Use exact strings: 'accel', 'gyro', or 'combined' (lowercase)

### Results Look Unrealistic (Accuracy > 99%)
**Possible Cause:** Data leakage or overfitting
**Check:** Ensure Day 1 and Day 2 files are separate

### EER > 20% (Very Poor)
**Possible Causes:**
1. Insufficient training data
2. Feature extraction issues
3. Label mismatch
**Solution:** Check preprocessing output, verify file naming

---

## 🏆 Expected Performance Benchmarks

### Typical Results (10 users, 4-second windows)

| Scenario | Modality | Accuracy | EER |
|----------|----------|----------|-----|
| Test 1 | Accelerometer | 88-93% | 4-7% |
| Test 1 | Gyroscope | 82-88% | 6-10% |
| Test 1 | Combined | 92-96% | 2-5% ✅ |
| **Test 2** | **Accelerometer** | **84-90%** | **5-8%** |
| **Test 2** | **Gyroscope** | **78-85%** | **8-12%** |
| **Test 2** | **Combined** | **89-94%** | **3-6%** ✅ |
| Test 3 | Accelerometer | 89-94% | 3-6% |
| Test 3 | Gyroscope | 84-89% | 5-9% |
| Test 3 | Combined | 93-97% | 2-4% ✅ |

**Note:** Your results may vary ±3% depending on random initialization

---

## 📚 Additional Resources

- Full documentation: `EXPERIMENTAL_SETUP.md`
- Original README: `README.md`
- Code comments in each `.m` file

---

**🎓 Ready for your coursework submission!**

Run `>> run_experiments` and include the results in your report with proper discussion and interpretation.

Good luck! 🚀

