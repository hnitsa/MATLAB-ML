# MATLAB-ML
MATLAB VFH Simulation and Machine Learning Project


Regression neural network that learns to predict robot movement direction (radians) from a Vector Field Histogram (VFH) polar histogram. Trained on data collected from a MATLAB VFH navigation simulation.

---

## Dataset

| Property | Value |
|---|---|
| File | `combined_dataset.mat` |
| Samples | 115,107 |
| Input `Y` | VFH polar histogram — `(N × 128)` |
| Output `X` | Movement direction in radians — `(N × 1)` |
| Direction range | `[−1, 2]` rad |

---

## Pipeline

```
combined_dataset.mat
        │
        ▼
  Scale directions → [−1, 1]
        │
        ▼
  Shuffle & split  (80 / 10 / 10)
        │
        ▼
  Z-score normalise inputs (μ, σ from train set)
        │
        ▼
  Gaussian noise augmentation (σ = 0.01)
        │
        ▼
  Train network  (Adam, 50 epochs)
        │
        ▼
  Evaluate on test set → MAE / RMSE
        │
        ▼
  trained_model_vfh.mat
```

---

## Network Architecture

```
featureInputLayer(128)
        │
fullyConnectedLayer(64)
LeakyReLU(α = 0.01)
        │
fullyConnectedLayer(32)
LeakyReLU(α = 0.01)
        │
fullyConnectedLayer(1)
regressionLayer  [MSE]
```

---

## Training Configuration

| Hyperparameter | Value |
|---|---|
| Optimizer | Adam |
| Initial LR | 0.0005 |
| LR schedule | Piecewise drop ×0.1 every 15 epochs |
| Max epochs | 50 |
| Mini-batch size | 128 |
| L2 regularization | 0.001 |
| Noise augmentation | Gaussian, σ = 0.01 |
| Shuffle | Every epoch |

---

## Output

`trained_model_vfh.mat` contains:

| Variable | Shape | Description |
|---|---|---|
| `paramValues{1}` W1 | `128 × 64` | FC layer 1 weights |
| `paramValues{2}` b1 | `64 × 1` | FC layer 1 bias |
| `paramValues{3}` W2 | `64 × 32` | FC layer 2 weights |
| `paramValues{4}` b2 | `32 × 1` | FC layer 2 bias |
| `paramValues{5}` W3 | `32 × 1` | FC layer 3 weights |
| `paramValues{6}` b3 | `1 × 1` | FC layer 3 bias |
| `mu` | `1 × 128` | Input mean (z-score) |
| `sigma` | `1 × 128` | Input std + ε (z-score) |
| `dir_min` | scalar | `−1` rad |
| `dir_max` | scalar | `2` rad |

To inverse-scale a prediction back to radians:
```matlab
dir_rad = (pred_scaled + 1) / 2 * (dir_max - dir_min) + dir_min;
```

---

## Usage

```matlab
% Load model
load('trained_model_vfh.mat');   % paramValues, mu, sigma, dir_min, dir_max

% Normalise new VFH histogram (1 × 128)
x_norm = (vfh_histogram - mu) ./ sigma;

% Predict
pred_scaled = predict(net, x_norm);
pred_rad    = (pred_scaled + 1) / 2 * (dir_max - dir_min) + dir_min;
```

---

## Files

| File | Description |
|---|---|
| `ML_VFH_Navigation.m` | Full training + evaluation script |
| `combined_dataset.mat` | Raw dataset |
| `trained_model_vfh.mat` | Saved model weights and normalisation params |
| `pathFollowingWithObstacleAvoidanceExample2.slxc` | Simulink model used for data collection |
| `Training Maps.zip` | Training Maps used for data collection |
| `Training Data.zip` | Simout data collected for training|
| `dataset_prep1.m` | Matlab script used to combine data into the dataset |

