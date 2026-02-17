# SAM 2 Demo - Troubleshooting Guide

## ✅ Issue Fixed: Backend Startup Failure

### Problem
Running `make backend-mps-uv` failed with error:
```
TypeError: expected str, bytes or os.PathLike object, not NoneType
```

### Root Cause
The **ffmpeg binary** was not installed on the system. The UV setup only installed the Python wrapper `ffmpeg-python`, but not the actual `ffmpeg` executable needed to process video files.

### Solution
1. **Installed ffmpeg via Homebrew:**
   ```bash
   brew install ffmpeg
   ```

2. **Updated Makefile** to automatically check for and install ffmpeg during UV setup

3. **Backend now starts successfully!**

## ✅ Verification

The backend now:
- ✓ Loads video files successfully
- ✓ Starts gunicorn server
- ✓ Responds to HTTP requests
- ✓ Ready to accept connections at http://localhost:7263/graphql

## 🚀 How to Start the Backend

```bash
cd /Users/karlchow/Desktop/code/sam2/demo
make backend-mps-uv
```

You should see:
```
Starting backend with UV venv + MPS support (Model: base_plus)...
Backend will be available at: http://localhost:7263/graphql
[INFO] Starting gunicorn 23.0.0
[INFO] Listening at: http://0.0.0.0:7263
100%|██████████| 5/5 [00:00<00:00, 13.18it/s]
```

⚠️ **Note:** You may see a warning about MPS being preliminary. This is expected and doesn't affect functionality:
```
WARNING: Support for MPS devices is preliminary. SAM 2 is trained with CUDA
and might give numerically different outputs and sometimes degraded
performance on MPS.
```

## 🎯 Complete Startup Guide

### Terminal 1 - Backend
```bash
cd /Users/karlchow/Desktop/code/sam2/demo
make backend-mps-uv
```

Wait until you see the progress bar reach 100% and the server starts listening.

### Terminal 2 - Frontend
```bash
cd /Users/karlchow/Desktop/code/sam2/demo
make frontend
```

### Access the Demo
Open your browser to: **http://localhost:7262**

## 🐛 Common Issues and Solutions

### Issue 1: ffmpeg not found
**Error:** `TypeError: expected str, bytes or os.PathLike object, not NoneType`

**Solution:**
```bash
brew install ffmpeg
```

The Makefile now checks for ffmpeg automatically, but if you installed before this update, you may need to install it manually.

### Issue 2: Port already in use
**Error:** `Address already in use`

**Solution:**
```bash
# Find and kill the process using the port
lsof -ti:7263 | xargs kill -9

# Or use a different port
make backend-mps-uv PORT_BACKEND=8000
```

### Issue 3: MPS crashes or errors
**Error:** MPS-related crashes or out of memory errors

**Solution:**
```bash
# Switch to CPU mode
make backend-cpu-uv
```

### Issue 4: Virtual environment issues
**Error:** Package import errors or missing dependencies

**Solution:**
```bash
# Recreate the virtual environment
rm -rf .venv
make setup-uv
```

### Issue 5: Model checkpoints not found
**Error:** Cannot find checkpoint files

**Solution:**
```bash
# Re-download checkpoints
cd ../checkpoints
./download_ckpts.sh
```

## 📊 Expected Performance

### On M4 Mac with MPS:
- **Model:** base_plus (default)
- **Expected FPS:** ~30-60 FPS
- **Memory:** ~4-8GB RAM
- **Startup time:** ~5-10 seconds

### Model Size Recommendations:
- **tiny** (fastest) - Use for quick testing, ~60+ FPS
- **small** (fast) - Use for development, ~50-60 FPS
- **base_plus** (balanced) - **Recommended for production**, ~30-60 FPS
- **large** (best quality) - Use when quality matters most, ~20-30 FPS

## 🔍 Debugging Commands

```bash
# Check if ffmpeg is installed
which ffmpeg
ffmpeg -version

# Check if virtual environment is created
ls -la .venv/

# Check if dependencies are installed
source .venv/bin/activate
python -c "import torch; import sam2; print('✓ All imports successful')"

# Check if backend is running
curl http://localhost:7263/graphql

# Check backend logs (if running in background)
tail -f /tmp/backend_test.log

# Test MPS availability
source .venv/bin/activate
python -c "import torch; print('MPS available:', torch.backends.mps.is_available())"
```

## 📝 System Requirements Check

Run this to verify your system is ready:

```bash
# Check all requirements
echo "=== System Check ==="
echo "UV: $(uv --version)"
echo "Python: $(python3 --version)"
echo "ffmpeg: $(ffmpeg -version | head -1)"
echo "Homebrew: $(brew --version | head -1)"
echo ""
echo "Virtual environment:"
ls -la .venv/ > /dev/null 2>&1 && echo "✓ .venv exists" || echo "✗ .venv not found"
echo ""
echo "Checkpoints:"
ls -la ../checkpoints/*.pt 2>/dev/null | wc -l | xargs echo "  Models downloaded:"
```

## ✨ Everything Working!

If you see:
- ✓ ffmpeg installed
- ✓ Backend starts and loads videos
- ✓ Server listening on port 7263
- ✓ No critical errors

Then you're ready to use SAM 2! 🚀

## 🆘 Still Having Issues?

1. Check this troubleshooting guide first
2. Review the logs for specific error messages
3. Ensure all dependencies are installed
4. Try recreating the virtual environment
5. Check the main README.md for additional help

For persistent issues, check:
- SAM 2 GitHub Issues: https://github.com/facebookresearch/sam2/issues
- Demo README: demo/README.md
- UV Quick Start: demo/UV_QUICK_START.md
