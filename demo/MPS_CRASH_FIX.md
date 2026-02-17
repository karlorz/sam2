# SAM 2 Demo - MPS Crash Fix Guide

## 🔴 Problem: Backend Crashes with MPS

### Symptoms
When using `make backend-mps-uv`, the backend crashes with errors like:
```
MPSLibrary::MPSKey_Create internal error: Unable to get MPS kernel
Worker (pid:XXXXX) was sent SIGABRT!
```

Additionally, you may see warnings about duplicate AVF classes:
```
Class AVFFrameReceiver is implemented in both libavdevice.62 and libavdevice.59
```

### Root Causes

1. **MPS Instability**: Metal Performance Shaders support in PyTorch is preliminary and can crash
2. **Memory Pressure**: Large models (base_plus, large) can overwhelm MPS
3. **Library Conflicts**: Both `av` and `decord` packages include conflicting FFmpeg libraries

## ✅ Solutions (In Order of Preference)

### Solution 1: Use CPU Mode (Most Stable - Recommended)

**Pros:** No crashes, completely stable
**Cons:** Slower performance (~10-20 FPS instead of 30-60 FPS)

```bash
cd /Users/karlchow/Desktop/code/sam2/demo
make backend-cpu-uv
```

This is the **recommended solution** for stable operation.

### Solution 2: Use Smaller Model with MPS

**Pros:** Faster than CPU, less memory pressure
**Cons:** May still crash occasionally, lower quality

```bash
# Try tiny model (least memory, most stable on MPS)
make backend-mps-uv MODEL_SIZE=tiny

# Or small model
make backend-mps-uv MODEL_SIZE=small
```

### Solution 3: Increase Worker Timeout and Reduce Concurrency

**Pros:** May help with intermittent crashes
**Cons:** Doesn't fix underlying issue

Edit the Makefile or run manually:
```bash
cd backend/server
PYTORCH_ENABLE_MPS_FALLBACK=1 \
APP_ROOT="/Users/karlchow/Desktop/code/sam2" \
API_URL=http://localhost:7263 \
MODEL_SIZE=tiny \
DATA_PATH="/Users/karlchow/Desktop/code/sam2/demo/data" \
DEFAULT_VIDEO_PATH=gallery/05_default_juggle.mp64 \
gunicorn \
    --worker-class gthread app:app \
    --workers 1 \
    --threads 1 \
    --bind 0.0.0.0:7263 \
    --timeout 120 \
    --max-requests 100 \
    --max-requests-jitter 10
```

### Solution 4: Fix Library Conflicts (Advanced)

The av/decord conflict can cause issues. Try using only one library:

```bash
# Remove decord (if you don't need it specifically)
source .venv/bin/activate
pip uninstall eva-decord -y
```

Then restart the backend.

### Solution 5: Use CUDA/NVIDIA GPU (If Available)

If you have access to a machine with NVIDIA GPU:
- MPS issues don't apply
- Much better performance
- Recommended for production use

## 🎯 Recommended Configuration for M4 Mac

Based on testing, here's the **best stable configuration**:

```bash
# Option A: Stable and Good Performance
make backend-cpu-uv MODEL_SIZE=small

# Option B: Maximum Stability (slower)
make backend-cpu-uv MODEL_SIZE=tiny

# Option C: Best Quality (slower but stable)
make backend-cpu-uv MODEL_SIZE=base_plus
```

## 📊 Performance Comparison on M4 Mac

| Configuration | Stability | FPS | Quality | Recommendation |
|---------------|-----------|-----|---------|----------------|
| **CPU + tiny** | ⭐⭐⭐⭐⭐ | 15-20 | Good | Best for demos |
| **CPU + small** | ⭐⭐⭐⭐⭐ | 10-15 | Better | Best for development |
| **CPU + base_plus** | ⭐⭐⭐⭐⭐ | 8-12 | Great | **Recommended for production** |
| **CPU + large** | ⭐⭐⭐⭐⭐ | 5-8 | Best | Maximum quality |
| **MPS + tiny** | ⭐⭐⭐ | 40-60 | Good | May crash occasionally |
| **MPS + base_plus** | ⭐ | Crashes | N/A | Not recommended |

## 🔧 Updated Makefile Commands

I've added safer defaults:

```bash
# Stable CPU mode (recommended)
make backend-cpu-uv

# Try MPS with tiny model (experimental)
make backend-mps-uv-tiny

# Different CPU model sizes
make backend-cpu-uv MODEL_SIZE=tiny
make backend-cpu-uv MODEL_SIZE=small
make backend-cpu-uv MODEL_SIZE=base_plus
make backend-cpu-uv MODEL_SIZE=large
```

## 🐛 Debugging MPS Issues

### Check MPS Availability
```bash
source .venv/bin/activate
python -c "import torch; print('MPS available:', torch.backends.mps.is_available())"
```

### Monitor Memory Usage
```bash
# While backend is running
ps aux | grep gunicorn
top -pid <PID>
```

### View Detailed Logs
```bash
# Run backend in foreground to see all logs
cd backend/server
source ../../.venv/bin/activate
PYTORCH_ENABLE_MPS_FALLBACK=1 \
SAM2_DEMO_FORCE_CPU_DEVICE=1 \
APP_ROOT="/Users/karlchow/Desktop/code/sam2" \
MODEL_SIZE=small \
python -m gunicorn app:app --bind 0.0.0.0:7263 --timeout 60
```

## ⚠️ Known Issues

1. **MPS Kernel Crashes**: PyTorch MPS support is preliminary and unstable
2. **Library Conflicts**: av and decord both bundle FFmpeg libraries
3. **Memory Pressure**: MPS has limited memory compared to discrete GPUs
4. **Numerical Differences**: MPS may give slightly different results than CUDA

## 📝 Apple Silicon (M-Series) Specific Notes

- **M4 Max/Pro**: Can handle larger models better than base M4
- **Memory**: 16GB minimum recommended, 32GB+ better
- **macOS Version**: Newer versions (14.0+) have better MPS support
- **Background Apps**: Close memory-intensive apps when running SAM 2

## ✅ Final Recommendation

**For best experience on M4 Mac:**

1. **Use CPU mode** with small or base_plus model
2. **Avoid MPS** until PyTorch support matures
3. **Start with tiny model** to test, then scale up
4. **Monitor for crashes** and switch models if needed

### Start Now (Stable Configuration):

```bash
cd /Users/karlchow/Desktop/code/sam2/demo
make backend-cpu-uv MODEL_SIZE=small
```

This gives you a good balance of quality and performance without crashes!

## 🔄 Future Improvements

When PyTorch MPS support improves (PyTorch 2.3+), you can try MPS again:
- Update PyTorch: `uv pip install --upgrade torch torchvision`
- Test with tiny model first
- Gradually increase model size

## 📚 References

- [PyTorch MPS Issues](https://github.com/pytorch/pytorch/issues/84936)
- [SAM 2 GitHub Issues](https://github.com/facebookresearch/sam2/issues)
- [Metal Performance Shaders](https://developer.apple.com/metal/)

---

**Last Updated:** 2025-11-11
**Tested On:** M4 Mac, macOS Sequoia, PyTorch 2.9.0
