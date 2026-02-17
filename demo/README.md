# SAM 2 Demo

Welcome to the SAM 2 Demo! This project consists of a frontend built with React TypeScript and Vite and a backend service using Python Flask and Strawberry GraphQL. Both components can be run in Docker containers or locally on MPS (Metal Performance Shaders) or CPU. However, running the backend service on MPS or CPU devices may result in significantly slower performance (FPS).

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- Docker and Docker Compose
- [OPTIONAL] Node.js and Yarn for running frontend locally
- [OPTIONAL] Anaconda for running backend locally

### Installing Docker

To install Docker, follow these steps:

1. Go to the [Docker website](https://www.docker.com/get-started)
2. Follow the installation instructions for your operating system.

### [OPTIONAL] Installing Node.js and Yarn

To install Node.js and Yarn, follow these steps:

1. Go to the [Node.js website](https://nodejs.org/en/download/).
2. Follow the installation instructions for your operating system.
3. Once Node.js is installed, open a terminal or command prompt and run the following command to install Yarn:

```
npm install -g yarn
```

### [OPTIONAL] Installing Anaconda

To install Anaconda, follow these steps:

1. Go to the [Anaconda website](https://www.anaconda.com/products/distribution).
2. Follow the installation instructions for your operating system.

## Quick Start

### Option 1: Docker (CPU only)

To get both the frontend and backend running quickly using Docker, you can use the following command:

```bash
docker compose up --build
```

> [!WARNING]
> On macOS, Docker containers only support running on CPU. MPS is not supported through Docker. If you want to run the demo backend service on MPS, you will need to run it locally (see options below).

### Option 2: Makefile for M4 Mac (MPS Support - Recommended for Apple Silicon)

For M4 Mac users who want to leverage MPS for better performance, we provide a simplified Makefile with two options:

#### Option 2a: UV Setup (Fastest - Recommended ⚡)

UV is 10-100x faster than pip/conda and doesn't require conda installation:

```bash
cd demo
make setup-uv       # One-time setup with UV (fast!)
make backend-mps-uv # Run backend with MPS
# In a new terminal:
make frontend       # Run frontend
```

**Why UV?**
- ⚡ 10-100x faster package installation
- 🚀 No conda required (uses standard Python venv)
- 💾 Better caching and dependency resolution
- ✅ Already installed on your system!

See [`UV_QUICK_START.md`](UV_QUICK_START.md) for detailed UV instructions.

#### Option 2b: Conda Setup (Traditional)

```bash
cd demo
make setup          # One-time setup with conda
conda activate sam2-demo
make backend-mps    # Run backend with MPS
# In a new terminal:
make frontend       # Run frontend
```

See the "Running Backend with MPS Support (Simplified with Makefile)" section below for more details.

## Accessing the Services

Once running (via Docker or locally), you can access the services at:

- **Frontend:** [http://localhost:7262](http://localhost:7262)
- **Backend:** [http://localhost:7263/graphql](http://localhost:7263/graphql)

## Running Backend with MPS Support (Simplified with Makefile)

For M4 Mac users, we provide a Makefile that simplifies running the backend with MPS support.

### Quick Start with Makefile

1. **[Optional] Run validation test** to ensure everything is set up correctly:
   ```bash
   cd demo
   ./test_makefile.sh
   ```

2. **One-time setup** (creates conda env, installs dependencies, downloads checkpoints):
   ```bash
   make setup
   ```

3. **Activate the conda environment:**
   ```bash
   conda activate sam2-demo
   ```

4. **Run the backend with MPS support:**
   ```bash
   make backend-mps
   ```

5. **In a new terminal, run the frontend:**
   ```bash
   cd demo
   make frontend
   ```

### Available Makefile Commands

Run `make help` to see all available commands. Common ones include:

- `make backend-mps` - Run backend with MPS support (default: base_plus model)
- `make backend-mps-tiny` - Run backend with tiny model
- `make backend-mps-small` - Run backend with small model
- `make backend-mps-large` - Run backend with large model
- `make backend-cpu` - Run backend with CPU fallback (if MPS crashes)
- `make frontend` - Run frontend development server

You can also customize the model size:
```bash
make backend-mps MODEL_SIZE=large
```

## Running Backend with MPS Support (Manual Setup)

MPS (Metal Performance Shaders) is not supported with Docker. To use MPS, you need to run the backend on your local machine.

### Setting Up Your Environment

1. **Create Conda environment**

   Create a new Conda environment for this project by running the following command or use your existing conda environment for SAM 2:

   ```
   conda create --name sam2-demo python=3.10 --yes
   ```

   This will create a new environment named `sam2-demo` with Python 3.10 as the interpreter.

2. **Activate the Conda environment:**

   ```bash
   conda activate sam2-demo
   ```

3. **Install ffmpeg**

   ```bash
   conda install -c conda-forge ffmpeg
   ```

4. **Install SAM 2 demo dependencies:**

Install project dependencies by running the following command in the SAM 2 checkout root directory:

```bash
pip install -e '.[interactive-demo]'
```

### Running the Backend Locally

Download the SAM 2 checkpoints:

```bash
(cd ./checkpoints && ./download_ckpts.sh)
```

Use the following command to start the backend with MPS support:

```bash
cd demo/backend/server/
```

```bash
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
```

Options for the `MODEL_SIZE` argument are "tiny", "small", "base_plus" (default), and "large".

> [!WARNING]
> Running the backend service on MPS devices can cause fatal crashes with the Gunicorn worker due to insufficient MPS memory. Try switching to CPU devices by setting the `SAM2_DEMO_FORCE_CPU_DEVICE=1` environment variable.

### Starting the Frontend

If you wish to run the frontend separately (useful for development), follow these steps:

1. **Navigate to demo frontend directory:**

   ```bash
   cd demo/frontend
   ```

2. **Install dependencies:**

   ```bash
   yarn install
   ```

3. **Start the development server:**

   ```bash
   yarn dev --port 7262
   ```

This will start the frontend development server on [http://localhost:7262](http://localhost:7262).

## Docker Tips

- To rebuild the Docker containers (useful if you've made changes to the Dockerfile or dependencies):

  ```bash
  docker compose up --build
  ```

- To stop the Docker containers:

  ```bash
  docker compose down
  ```

## Contributing

Contributions are welcome! Please read our contributing guidelines to get started.

## License

See the LICENSE file for details.

---

By following these instructions, you should have a fully functional development environment for both the frontend and backend of the SAM 2 Demo. Happy coding!
