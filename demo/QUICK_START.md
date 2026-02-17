# SAM 2 Demo - Quick Reference for M4 Mac

## ✅ Makefile Testing Results

The Makefile has been created and basic validation passed:
- ✓ Makefile syntax is correct
- ✓ Help command works
- ✓ Environment checks work properly
- ✓ Project structure is valid
- ✓ Checkpoint download script exists

## 🚀 Quick Start (Copy & Paste)

### First Time Setup:
```bash
cd /Users/karlchow/Desktop/code/sam2/demo
./test_makefile.sh              # Run validation test
make setup                      # Create environment & install dependencies
conda activate sam2-demo        # Activate the environment
```

### Running the Demo:

**Terminal 1 - Backend (with MPS):**
```bash
cd /Users/karlchow/Desktop/code/sam2/demo
conda activate sam2-demo
make backend-mps
```

**Terminal 2 - Frontend:**
```bash
cd /Users/karlchow/Desktop/code/sam2/demo
make frontend
```

Then open: http://localhost:7262

## 📋 Common Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make backend-mps` | Run backend with MPS (base_plus model) |
| `make backend-mps-tiny` | Run backend with tiny model (faster) |
| `make backend-mps-large` | Run backend with large model (better quality) |
| `make backend-cpu` | Run with CPU if MPS crashes |
| `make frontend` | Run frontend dev server |
| `./test_makefile.sh` | Run validation tests |

## 🎯 Model Size Selection

Use different models based on your needs:

```bash
# Fast performance (tiny model)
make backend-mps-tiny

# Balanced (default - base_plus)
make backend-mps

# Best quality (large model)
make backend-mps-large

# Custom model size
make backend-mps MODEL_SIZE=small
```

## 🐛 Troubleshooting

### If MPS crashes or gives errors:
```bash
# Use CPU fallback instead
make backend-cpu
```

### If conda is not found:
```bash
# Initialize conda in your shell
conda init zsh  # or 'bash' if using bash
# Then restart your terminal
```

### If you need to start fresh:
```bash
# Remove the conda environment
conda deactivate
conda env remove -n sam2-demo

# Run setup again
make setup
```

## 📊 What Each Model Provides

| Model | Size | Speed | Quality | Best For |
|-------|------|-------|---------|----------|
| tiny | 38.9M | Fastest | Good | Quick testing, demos |
| small | 46M | Fast | Better | Development work |
| base_plus | 80.8M | Moderate | Great | Production (default) |
| large | 224.4M | Slower | Best | Highest quality results |

## 🔍 Validation Test

Run the validation script to check your setup:
```bash
./test_makefile.sh
```

This will verify:
- ✓ Makefile is present and working
- ✓ conda is available and working
- ✓ Python version is compatible
- ✓ Project structure is correct
- ✓ Required scripts exist

## 📝 Environment Variables

You can customize the behavior:

```bash
# Change backend port
make backend-mps PORT_BACKEND=8000

# Change frontend port
make frontend PORT_FRONTEND=3000

# Change model size
make backend-mps MODEL_SIZE=large

# Use different conda environment name
make setup CONDA_ENV=my-sam2-env
```

## 🎬 Complete Workflow Example

```bash
# 1. One-time setup
cd /Users/karlchow/Desktop/code/sam2/demo
make setup
conda activate sam2-demo

# 2. Start backend (Terminal 1)
make backend-mps

# 3. Start frontend (Terminal 2 - new terminal)
cd /Users/karlchow/Desktop/code/sam2/demo
make frontend

# 4. Open browser
# Visit: http://localhost:7262

# 5. When done, press Ctrl+C in both terminals to stop
```

## ✨ Ready to Test!

Everything is set up. To start testing:

1. Open your terminal application
2. Navigate to the demo directory: `cd /Users/karlchow/Desktop/code/sam2/demo`
3. Run the test script: `./test_makefile.sh`
4. Follow the on-screen instructions!
