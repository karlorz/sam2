# SAM 2 Demo Makefile
# Simplifies running the backend and frontend locally, especially with MPS support on Apple Silicon

# Default variables
CONDA_ENV ?= sam2-demo
UV_VENV ?= .venv
PYTHON_VERSION ?= 3.10
MODEL_SIZE ?= base_plus
PORT_BACKEND ?= 7263
PORT_FRONTEND ?= 7262
WORKERS ?= 1
THREADS ?= 2
TIMEOUT ?= 60

# Paths
BACKEND_DIR = backend/server
FRONTEND_DIR = frontend
APP_ROOT = $(shell cd .. && pwd)
DATA_PATH = $(shell pwd)/data
DEFAULT_VIDEO = gallery/05_default_juggle.mp4

# Colors for output
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

.PHONY: help setup install-deps download-checkpoints backend-mps backend-cpu frontend docker-up docker-down clean setup-uv install-deps-uv backend-mps-uv check-uv check-ffmpeg

# Default target
help:
	@echo "$(BLUE)SAM 2 Demo - Makefile Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Setup Commands (Conda):$(NC)"
	@echo "  make setup                 - Complete setup (create conda env, install deps, download checkpoints)"
	@echo "  make create-conda-env      - Create conda environment ($(CONDA_ENV))"
	@echo "  make install-deps          - Install SAM 2 and demo dependencies"
	@echo "  make download-checkpoints  - Download SAM 2 model checkpoints"
	@echo ""
	@echo "$(GREEN)Setup Commands (UV - Fast Alternative):$(NC)"
	@echo "  make setup-uv              - Complete setup using UV (faster than conda)"
	@echo "  make install-uv            - Install UV package manager"
	@echo "  make install-deps-uv       - Install dependencies with UV"
	@echo "  make check-uv              - Check if UV is installed"
	@echo ""
	@echo "$(GREEN)Backend Commands (M4 Mac - MPS Support):$(NC)"
	@echo "  make backend-mps           - Run backend with MPS support (default: base_plus model)"
	@echo "  make backend-mps-tiny      - Run backend with MPS (tiny model)"
	@echo "  make backend-mps-small     - Run backend with MPS (small model)"
	@echo "  make backend-mps-large     - Run backend with MPS (large model)"
	@echo "  make backend-cpu           - Run backend with CPU fallback (if MPS crashes)"
	@echo "  make backend-mps-uv        - Run backend with MPS using UV venv (no conda needed)"
	@echo ""
	@echo "$(GREEN)Frontend Commands:$(NC)"
	@echo "  make frontend              - Run frontend development server"
	@echo "  make frontend-install      - Install frontend dependencies"
	@echo ""
	@echo "$(GREEN)Docker Commands:$(NC)"
	@echo "  make docker-up             - Start both services with Docker (CPU only)"
	@echo "  make docker-down           - Stop Docker containers"
	@echo "  make docker-rebuild        - Rebuild and start Docker containers"
	@echo ""
	@echo "$(GREEN)Utility Commands:$(NC)"
	@echo "  make clean                 - Clean temporary files"
	@echo "  make check-env             - Check if conda environment is activated"
	@echo ""
	@echo "$(YELLOW)Environment Variables:$(NC)"
	@echo "  MODEL_SIZE=<size>          - Model size: tiny, small, base_plus (default), large"
	@echo "  CONDA_ENV=<name>           - Conda environment name (default: $(CONDA_ENV))"
	@echo "  PORT_BACKEND=<port>        - Backend port (default: $(PORT_BACKEND))"
	@echo "  PORT_FRONTEND=<port>       - Frontend port (default: $(PORT_FRONTEND))"
	@echo ""
	@echo "$(YELLOW)Example:$(NC)"
	@echo "  make backend-mps MODEL_SIZE=large"

# Complete setup
setup: create-conda-env install-deps download-checkpoints
	@echo "$(GREEN)✓ Setup complete!$(NC)"
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1. Activate conda environment: conda activate $(CONDA_ENV)"
	@echo "  2. Run backend: make backend-mps"
	@echo "  3. Run frontend: make frontend"

# Create conda environment
create-conda-env:
	@echo "$(BLUE)Creating conda environment: $(CONDA_ENV)$(NC)"
	@if conda env list | grep -q "^$(CONDA_ENV) "; then \
		echo "$(YELLOW)Environment $(CONDA_ENV) already exists. Skipping...$(NC)"; \
	else \
		conda create --name $(CONDA_ENV) python=$(PYTHON_VERSION) --yes; \
		echo "$(GREEN)✓ Conda environment created$(NC)"; \
		echo "$(YELLOW)Activate it with: conda activate $(CONDA_ENV)$(NC)"; \
	fi

# Install dependencies
install-deps: check-env
	@echo "$(BLUE)Installing SAM 2 demo dependencies...$(NC)"
	@cd $(APP_ROOT) && pip install -e '.[interactive-demo]'
	@conda install -c conda-forge ffmpeg --yes
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

# Download checkpoints
download-checkpoints:
	@echo "$(BLUE)Downloading SAM 2 checkpoints...$(NC)"
	@if [ -d "$(APP_ROOT)/checkpoints/sam2.1_hiera_base_plus.pt" ]; then \
		echo "$(YELLOW)Checkpoints already exist. Skipping...$(NC)"; \
	else \
		cd $(APP_ROOT)/checkpoints && ./download_ckpts.sh; \
		echo "$(GREEN)✓ Checkpoints downloaded$(NC)"; \
	fi

# Run backend with MPS support
backend-mps: check-env
	@echo "$(BLUE)Starting backend with MPS support (Model: $(MODEL_SIZE))...$(NC)"
	@echo "$(YELLOW)Backend will be available at: http://localhost:$(PORT_BACKEND)/graphql$(NC)"
	@cd $(BACKEND_DIR) && \
	PYTORCH_ENABLE_MPS_FALLBACK=1 \
	APP_ROOT="$(APP_ROOT)" \
	API_URL=http://localhost:$(PORT_BACKEND) \
	MODEL_SIZE=$(MODEL_SIZE) \
	DATA_PATH="$(DATA_PATH)" \
	DEFAULT_VIDEO_PATH=$(DEFAULT_VIDEO) \
	gunicorn \
		--worker-class gthread app:app \
		--workers $(WORKERS) \
		--threads $(THREADS) \
		--bind 0.0.0.0:$(PORT_BACKEND) \
		--timeout $(TIMEOUT)

# Run backend with MPS - tiny model
backend-mps-tiny:
	@$(MAKE) backend-mps MODEL_SIZE=tiny

# Run backend with MPS - small model
backend-mps-small:
	@$(MAKE) backend-mps MODEL_SIZE=small

# Run backend with MPS - large model
backend-mps-large:
	@$(MAKE) backend-mps MODEL_SIZE=large

# Run backend with CPU fallback (if MPS crashes)
backend-cpu: check-env
	@echo "$(BLUE)Starting backend with CPU fallback (Model: $(MODEL_SIZE))...$(NC)"
	@echo "$(YELLOW)⚠️  Running on CPU - performance may be slower$(NC)"
	@echo "$(YELLOW)Backend will be available at: http://localhost:$(PORT_BACKEND)/graphql$(NC)"
	@cd $(BACKEND_DIR) && \
	PYTORCH_ENABLE_MPS_FALLBACK=1 \
	SAM2_DEMO_FORCE_CPU_DEVICE=1 \
	APP_ROOT="$(APP_ROOT)" \
	API_URL=http://localhost:$(PORT_BACKEND) \
	MODEL_SIZE=$(MODEL_SIZE) \
	DATA_PATH="$(DATA_PATH)" \
	DEFAULT_VIDEO_PATH=$(DEFAULT_VIDEO) \
	gunicorn \
		--worker-class gthread app:app \
		--workers $(WORKERS) \
		--threads $(THREADS) \
		--bind 0.0.0.0:$(PORT_BACKEND) \
		--timeout $(TIMEOUT)

# Install frontend dependencies
frontend-install:
	@echo "$(BLUE)Installing frontend dependencies...$(NC)"
	@cd $(FRONTEND_DIR) && yarn install
	@echo "$(GREEN)✓ Frontend dependencies installed$(NC)"

# Run frontend
frontend:
	@echo "$(BLUE)Starting frontend development server...$(NC)"
	@echo "$(YELLOW)Frontend will be available at: http://localhost:$(PORT_FRONTEND)$(NC)"
	@cd $(FRONTEND_DIR) && yarn dev --port $(PORT_FRONTEND)

# Docker commands
docker-up:
	@echo "$(BLUE)Starting services with Docker...$(NC)"
	@echo "$(YELLOW)⚠️  Docker on macOS only supports CPU (no MPS)$(NC)"
	@cd .. && docker compose up

docker-down:
	@echo "$(BLUE)Stopping Docker containers...$(NC)"
	@cd .. && docker compose down

docker-rebuild:
	@echo "$(BLUE)Rebuilding Docker containers...$(NC)"
	@cd .. && docker compose up --build

# Check if conda environment is activated
check-env:
	@if [ -z "$$CONDA_DEFAULT_ENV" ]; then \
		echo "$(YELLOW)⚠️  No conda environment is activated$(NC)"; \
		echo "$(YELLOW)Please activate the environment first:$(NC)"; \
		echo "  conda activate $(CONDA_ENV)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Conda environment active: $$CONDA_DEFAULT_ENV$(NC)"

# Clean temporary files
clean:
	@echo "$(BLUE)Cleaning temporary files...$(NC)"
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null || true
	@rm -rf $(UV_VENV) 2>/dev/null || true
	@echo "$(GREEN)✓ Cleaned$(NC)"

# ============================================================================
# UV-based Setup (Fast Alternative to Conda)
# ============================================================================

# Check if UV is installed
check-uv:
	@echo "$(BLUE)Checking UV installation...$(NC)"
	@if command -v uv &> /dev/null; then \
		echo "$(GREEN)✓ UV is installed: $$(uv --version)$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  UV is not installed$(NC)"; \
		echo "$(YELLOW)Install with: make install-uv$(NC)"; \
		exit 1; \
	fi

# Install UV
install-uv:
	@echo "$(BLUE)Installing UV package manager...$(NC)"
	@if command -v uv &> /dev/null; then \
		echo "$(YELLOW)UV is already installed: $$(uv --version)$(NC)"; \
	else \
		echo "$(YELLOW)Installing UV via pip...$(NC)"; \
		pip install uv || curl -LsSf https://astral.sh/uv/install.sh | sh; \
		echo "$(GREEN)✓ UV installed successfully$(NC)"; \
	fi

# Create UV virtual environment
create-uv-venv:
	@echo "$(BLUE)Creating UV virtual environment: $(UV_VENV)$(NC)"
	@if [ -d "$(UV_VENV)" ]; then \
		echo "$(YELLOW)Virtual environment $(UV_VENV) already exists. Skipping...$(NC)"; \
	else \
		uv venv $(UV_VENV) --python $(PYTHON_VERSION); \
		echo "$(GREEN)✓ Virtual environment created$(NC)"; \
	fi

# Check and install ffmpeg binary
check-ffmpeg:
	@echo "$(BLUE)Checking ffmpeg installation...$(NC)"
	@if command -v ffmpeg &> /dev/null; then \
		echo "$(GREEN)✓ ffmpeg is installed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  ffmpeg not found$(NC)"; \
		echo "$(YELLOW)Installing ffmpeg via homebrew...$(NC)"; \
		if command -v brew &> /dev/null; then \
			brew install ffmpeg; \
			echo "$(GREEN)✓ ffmpeg installed$(NC)"; \
		else \
			echo "$(RED)❌ Homebrew not found. Please install ffmpeg manually:$(NC)"; \
			echo "  brew install ffmpeg"; \
			exit 1; \
		fi \
	fi

# Install dependencies with UV
install-deps-uv: check-ffmpeg
	@echo "$(BLUE)Installing SAM 2 demo dependencies with UV...$(NC)"
	@if [ ! -d "$(UV_VENV)" ]; then \
		echo "$(YELLOW)Virtual environment not found. Creating...$(NC)"; \
		$(MAKE) create-uv-venv; \
	fi
	@echo "$(YELLOW)Installing dependencies (this may take a few minutes)...$(NC)"
	@cd $(APP_ROOT) && \
		. $(APP_ROOT)/demo/$(UV_VENV)/bin/activate && \
		uv pip install -e '.[interactive-demo]' && \
		uv pip install ffmpeg-python
	@echo "$(GREEN)✓ Dependencies installed with UV$(NC)"

# Complete UV setup
setup-uv: check-uv create-uv-venv install-deps-uv download-checkpoints
	@echo "$(GREEN)✓ UV setup complete!$(NC)"
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1. Activate virtual environment: source $(UV_VENV)/bin/activate"
	@echo "  2. Run backend: make backend-mps-uv"
	@echo "  3. Run frontend: make frontend"
	@echo ""
	@echo "$(BLUE)Or run directly without activation:$(NC)"
	@echo "  make backend-mps-uv"

# Run backend with UV virtual environment (MPS support)
backend-mps-uv:
	@if [ ! -d "$(UV_VENV)" ]; then \
		echo "$(YELLOW)⚠️  UV virtual environment not found$(NC)"; \
		echo "$(YELLOW)Run: make setup-uv$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Starting backend with UV venv + MPS support (Model: $(MODEL_SIZE))...$(NC)"
	@echo "$(YELLOW)⚠️  MPS on M4 may be unstable. Use 'make backend-cpu-uv' for stability.$(NC)"
	@echo "$(YELLOW)Backend will be available at: http://localhost:$(PORT_BACKEND)/graphql$(NC)"
	@cd $(BACKEND_DIR) && \
	. $(APP_ROOT)/demo/$(UV_VENV)/bin/activate && \
	PYTORCH_ENABLE_MPS_FALLBACK=1 \
	PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0 \
	APP_ROOT="$(APP_ROOT)" \
	API_URL=http://localhost:$(PORT_BACKEND) \
	MODEL_SIZE=$(MODEL_SIZE) \
	DATA_PATH="$(DATA_PATH)" \
	DEFAULT_VIDEO_PATH=$(DEFAULT_VIDEO) \
	gunicorn \
		--worker-class gthread app:app \
		--workers 1 \
		--threads 1 \
		--bind 0.0.0.0:$(PORT_BACKEND) \
		--timeout $(TIMEOUT) \
		--max-requests 50 \
		--max-requests-jitter 10

# Run backend with UV - tiny model
backend-mps-uv-tiny:
	@$(MAKE) backend-mps-uv MODEL_SIZE=tiny

# Run backend with UV - small model
backend-mps-uv-small:
	@$(MAKE) backend-mps-uv MODEL_SIZE=small

# Run backend with UV - large model
backend-mps-uv-large:
	@$(MAKE) backend-mps-uv MODEL_SIZE=large

# Run backend with UV + CPU fallback
backend-cpu-uv:
	@if [ ! -d "$(UV_VENV)" ]; then \
		echo "$(YELLOW)⚠️  UV virtual environment not found$(NC)"; \
		echo "$(YELLOW)Run: make setup-uv$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Starting backend with UV venv + CPU fallback (Model: $(MODEL_SIZE))...$(NC)"
	@echo "$(YELLOW)⚠️  Running on CPU - performance may be slower$(NC)"
	@echo "$(YELLOW)Backend will be available at: http://localhost:$(PORT_BACKEND)/graphql$(NC)"
	@cd $(BACKEND_DIR) && \
	. $(APP_ROOT)/demo/$(UV_VENV)/bin/activate && \
	PYTORCH_ENABLE_MPS_FALLBACK=1 \
	SAM2_DEMO_FORCE_CPU_DEVICE=1 \
	APP_ROOT="$(APP_ROOT)" \
	API_URL=http://localhost:$(PORT_BACKEND) \
	MODEL_SIZE=$(MODEL_SIZE) \
	DATA_PATH="$(DATA_PATH)" \
	DEFAULT_VIDEO_PATH=$(DEFAULT_VIDEO) \
	gunicorn \
		--worker-class gthread app:app \
		--workers $(WORKERS) \
		--threads $(THREADS) \
		--bind 0.0.0.0:$(PORT_BACKEND) \
		--timeout $(TIMEOUT)

