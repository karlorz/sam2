# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

SAM 2 (Segment Anything Model 2) is a foundation model for promptable visual segmentation in images and videos. It extends SAM to video by treating images as single-frame videos, using a transformer architecture with streaming memory for real-time video processing.

## Installation and Setup

```bash
# Install SAM 2 (requires python>=3.10, torch>=2.5.1, torchvision>=0.20.1)
pip install -e .

# Install with notebook dependencies (includes jupyter, matplotlib, opencv-python)
pip install -e ".[notebooks]"

# Install with development dependencies (for training/fine-tuning)
pip install -e ".[dev]"

# Install with interactive demo dependencies
pip install -e ".[interactive-demo]"

# Download model checkpoints
cd checkpoints && ./download_ckpts.sh && cd ..
```

**Important**: The installation attempts to build a custom CUDA kernel (`sam2/_C`). If compilation fails, SAM 2 will still work (some post-processing may be limited). Set `SAM2_BUILD_CUDA=0` to skip CUDA build entirely.

## Project Structure

```
sam2/
├── sam2/                      # Main package
│   ├── modeling/              # Core model architecture
│   │   ├── sam2_base.py      # SAM2Base: main model class
│   │   ├── backbones/        # Image encoders (Hiera architecture)
│   │   ├── sam/              # SAM components (mask decoder, prompt encoder, transformer)
│   │   ├── memory_attention.py
│   │   └── memory_encoder.py
│   ├── build_sam.py          # Model builder functions
│   ├── sam2_image_predictor.py      # Image prediction API
│   ├── sam2_video_predictor.py      # Video prediction API (new implementation)
│   ├── sam2_video_predictor_legacy.py  # Previous video predictor
│   ├── automatic_mask_generator.py
│   ├── configs/              # Model configurations (YAML)
│   │   ├── sam2/            # Original SAM 2 configs
│   │   ├── sam2.1/          # SAM 2.1 configs (improved checkpoints)
│   │   └── sam2.1_training/ # Training configs
│   └── utils/
├── training/                  # Training and fine-tuning code
│   ├── train.py              # Main training script
│   ├── trainer.py            # Trainer class with train/eval loop
│   ├── dataset/              # Dataset loaders (SA-1B, SA-V, DAVIS-style)
│   ├── model/                # SAM2Train wrapper for training
│   └── utils/
├── tools/                     # Utility scripts
│   └── vos_inference.py      # Video object segmentation inference
├── demo/                      # Web demo (React frontend + Flask backend)
├── notebooks/                 # Example Jupyter notebooks
└── sav_dataset/              # SA-V dataset utilities and evaluation
```

## Architecture Overview

### Model Components

SAM 2 consists of these key components (all in `sam2/modeling/`):

1. **Image Encoder** (`backbones/`): Hiera backbone that processes frames
2. **Prompt Encoder** (`sam/prompt_encoder.py`): Encodes user prompts (points, boxes, masks)
3. **Memory Encoder** (`memory_encoder.py`): Encodes mask predictions into memory for video tracking
4. **Memory Attention** (`memory_attention.py`): Cross-attends to memory from previous frames
5. **Mask Decoder** (`sam/mask_decoder.py`): Generates segmentation masks
6. **SAM2Base** (`sam2_base.py`): Main model class orchestrating all components

### Key Design Patterns

- **Hydra Configuration**: All models use Hydra for configuration management. Configs are in `sam2/configs/` and loaded via `build_sam.py`.
- **Predictor Pattern**: User-facing APIs (`SAM2ImagePredictor`, `SAM2VideoPredictor`) wrap the base model with state management.
- **Memory-based Video Tracking**: For videos, the model maintains an "inference state" tracking memory features across frames.

### Video Prediction: New vs Legacy

As of 12/11/2024, `SAM2VideoPredictor` was updated with independent per-object inference:
- **New** (`sam2_video_predictor.py`): Each object tracked independently; can add new objects after tracking starts
- **Legacy** (`sam2_video_predictor_legacy.py`): Batched inference; assumes non-prompted objects don't exist in frame

Use the new predictor unless you need exact backward compatibility.

## Common Development Commands

### Building Models

```python
from sam2.build_sam import build_sam2, build_sam2_video_predictor

# Image model
predictor = build_sam2(
    config_file="configs/sam2.1/sam2.1_hiera_l.yaml",
    ckpt_path="./checkpoints/sam2.1_hiera_large.pt",
    device="cuda"
)

# Video model (standard)
video_predictor = build_sam2_video_predictor(
    config_file="configs/sam2.1/sam2.1_hiera_b+.yaml",
    ckpt_path="./checkpoints/sam2.1_hiera_base_plus.pt"
)

# Video model (VOS-optimized with torch.compile - requires PyTorch >= 2.5.1)
video_predictor = build_sam2_video_predictor(
    config_file="configs/sam2.1/sam2.1_hiera_b+.yaml",
    ckpt_path="./checkpoints/sam2.1_hiera_base_plus.pt",
    vos_optimized=True  # Enables full model compilation for major speedup
)
```

### Loading from Hugging Face

```python
from sam2.sam2_image_predictor import SAM2ImagePredictor
from sam2.sam2_video_predictor import SAM2VideoPredictor

# Automatically downloads from HF Hub
image_predictor = SAM2ImagePredictor.from_pretrained("facebook/sam2-hiera-large")
video_predictor = SAM2VideoPredictor.from_pretrained("facebook/sam2.1-hiera-base-plus")
```

### Training and Fine-tuning

```bash
# Fine-tune on MOSE dataset (example)
python training/train.py \
    -c configs/sam2.1_training/sam2.1_hiera_b+_MOSE_finetune.yaml \
    --use-cluster 0 \
    --num-gpus 8

# Multi-node training with SLURM
python training/train.py \
    -c configs/sam2.1_training/sam2.1_hiera_b+_MOSE_finetune.yaml \
    --use-cluster 1 \
    --num-gpus 8 \
    --num-nodes 2 \
    --partition $PARTITION
```

Training outputs go to `sam2_logs/` by default. Monitor with TensorBoard logs in `sam2_logs/${config_name}/tensorboard/`.

### Video Object Segmentation (VOS) Inference

```bash
# DAVIS/MOSE datasets (all objects appear in frame 0)
python ./tools/vos_inference.py \
  --sam2_cfg configs/sam2.1/sam2.1_hiera_b+.yaml \
  --sam2_checkpoint ./checkpoints/sam2.1_hiera_base_plus.pt \
  --base_video_dir /path/to/JPEGImages \
  --input_mask_dir /path/to/Annotations \
  --video_list_file /path/to/val.txt \
  --output_mask_dir ./outputs/pred_pngs

# SA-V dataset (requires per-object PNG files)
python ./tools/vos_inference.py \
  --sam2_cfg configs/sam2.1/sam2.1_hiera_b+.yaml \
  --sam2_checkpoint ./checkpoints/sam2.1_hiera_base_plus.pt \
  --base_video_dir /path/to/JPEGImages_24fps \
  --input_mask_dir /path/to/Annotations_6fps \
  --video_list_file /path/to/sav_val.txt \
  --per_obj_png_file \
  --output_mask_dir ./outputs/sav_val_pred_pngs

# LVOS/YouTube-VOS (objects may appear later in video)
python ./tools/vos_inference.py \
  --sam2_cfg configs/sam2.1/sam2.1_hiera_b+.yaml \
  --sam2_checkpoint ./checkpoints/sam2.1_hiera_base_plus.pt \
  --base_video_dir /path/to/JPEGImages \
  --input_mask_dir /path/to/Annotations \
  --video_list_file /path/to/val.txt \
  --track_object_appearing_later_in_video \
  --output_mask_dir ./outputs/pred_pngs

# Use VOS-optimized predictor (torch.compile for speed)
python ./tools/vos_inference.py \
  --sam2_cfg configs/sam2.1/sam2.1_hiera_b+.yaml \
  --sam2_checkpoint ./checkpoints/sam2.1_hiera_base_plus.pt \
  --base_video_dir /path/to/JPEGImages \
  --input_mask_dir /path/to/Annotations \
  --video_list_file /path/to/val.txt \
  --use_vos_optimized_video_predictor \
  --output_mask_dir ./outputs/pred_pngs
```

### Running the Web Demo

```bash
# Using Docker (CPU only on macOS)
docker compose up --build
# Frontend: http://localhost:7262
# Backend: http://localhost:7263/graphql

# Running backend locally with MPS support (macOS)
cd demo/backend/server/
PYTORCH_ENABLE_MPS_FALLBACK=1 \
APP_ROOT="$(pwd)/../../../" \
API_URL=http://localhost:7263 \
MODEL_SIZE=base_plus \
DATA_PATH="$(pwd)/../../data" \
DEFAULT_VIDEO_PATH=gallery/05_default_juggle.mp4 \
gunicorn \
    --worker-class gthread app:app \
    --workers 1 \
    --threads 2 \
    --bind 0.0.0.0:7263 \
    --timeout 60

# Running frontend locally
cd demo/frontend
yarn install
yarn dev --port 7262
```

Set `SAM2_DEMO_FORCE_CPU_DEVICE=1` if MPS causes crashes.

## Model Checkpoints

SAM 2.1 (released 09/30/2024) is the recommended version:
- `sam2.1_hiera_tiny.pt` - 38.9M params
- `sam2.1_hiera_small.pt` - 46M params
- `sam2.1_hiera_base_plus.pt` - 80.8M params (default for demo)
- `sam2.1_hiera_large.pt` - 224.4M params

Original SAM 2 checkpoints (07/29/2024) also available with `sam2_hiera_*` naming.

## Important Implementation Details

### Inference State Management (Video)

Video tracking requires maintaining state across frames:

```python
with torch.inference_mode(), torch.autocast("cuda", dtype=torch.bfloat16):
    state = predictor.init_state(<your_video>)

    # Add prompts on specific frames
    frame_idx, object_ids, masks = predictor.add_new_points_or_box(state, <prompts>)

    # Propagate throughout video
    for frame_idx, object_ids, masks in predictor.propagate_in_video(state):
        # Process masks
        pass
```

### Memory and Conditioning Frames

- **`num_maskmem`**: Number of memory frames (default 7 = 1 current + 6 previous)
- **`max_cond_frames_in_attn`**: Maximum conditioning frames for memory attention (-1 = unlimited)
- Temporal locality: closer frames are more important for tracking

### Compilation and Optimization

- Set `vos_optimized=True` in `build_sam2_video_predictor` for full model `torch.compile`
- Requires PyTorch >= 2.5.1 for full support
- May introduce small numerical differences but provides major FPS speedup
- Alternatively, set `compile_image_encoder: True` in config for backbone-only compilation

### Device Compatibility

- **CUDA**: Full support, recommended for production
- **MPS** (Apple Silicon): Supported but may require `PYTORCH_ENABLE_MPS_FALLBACK=1`
- **CPU**: Works but significantly slower
- Docker on macOS only supports CPU (no MPS passthrough)

## File Organization Conventions

- Model definitions: `sam2/modeling/`
- Predictors (user APIs): `sam2/*_predictor.py`
- Configuration files: `sam2/configs/`
- Training utilities: `training/`
- Inference scripts: `tools/`
- Example notebooks: `notebooks/`

## Testing and Validation

This repository does not include a formal test suite. Validation is typically done via:
- Running example notebooks in `notebooks/`
- VOS benchmark evaluation using `tools/vos_inference.py` + dataset-specific evaluators
- Visual inspection via the web demo

## Key Configuration Parameters

When modifying configs or using Hydra overrides:

- `model._target_`: Model class (e.g., `sam2.modeling.sam2_base.SAM2Base`)
- `model.image_encoder`: Backbone config (Hiera variants)
- `model.num_maskmem`: Number of memory frames for video
- `model.compile_image_encoder`: Whether to torch.compile the backbone
- `apply_postprocessing`: Enables dynamic multimask and hole filling
- For training: `batch_sizes`, `phases_per_epoch`, dataset paths in config

## Common Pitfalls

1. **Running Python from parent directory**: Do not run Python from the parent of the `sam2` repo (where you cloned it). This causes import shadowing. Run from the repo directory itself or elsewhere after installation.

2. **CUDA extension build failures**: Safe to ignore if you see "Failed to build the SAM 2 CUDA extension". The model works without it.

3. **VOS datasets with late-appearing objects**: Add `--track_object_appearing_later_in_video` flag for datasets like LVOS/YouTube-VOS where not all objects appear in frame 0.

4. **Memory constraints**: Reduce `num_maskmem` or `max_cond_frames_in_attn` for long videos or limited GPU memory.

5. **Video predictor version**: Use `sam2_video_predictor.py` (new) unless you need exact legacy behavior. The new version allows adding objects mid-tracking.

6. **PyTorch version**: For VOS-optimized inference with full compilation, use PyTorch >= 2.5.1.
