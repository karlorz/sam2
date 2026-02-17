#!/bin/bash
# Test script for SAM 2 Demo Makefile on M4 Mac
# Run this script from your terminal where conda is available

set -e  # Exit on error

echo "🧪 Testing SAM 2 Demo Makefile..."
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test 1: Check if we're in the right directory
echo -e "${BLUE}Test 1: Checking directory...${NC}"
if [ ! -f "Makefile" ]; then
    echo -e "${RED}❌ Makefile not found. Please run this script from the demo directory.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Makefile found${NC}"
echo ""

# Test 2: Check if make is available
echo -e "${BLUE}Test 2: Checking make command...${NC}"
if ! command -v make &> /dev/null; then
    echo -e "${RED}❌ make command not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ make is available${NC}"
echo ""

# Test 3: Test make help
echo -e "${BLUE}Test 3: Testing 'make help'...${NC}"
if make help > /dev/null 2>&1; then
    echo -e "${GREEN}✓ make help works${NC}"
else
    echo -e "${RED}❌ make help failed${NC}"
    exit 1
fi
echo ""

# Test 4: Check if conda is available
echo -e "${BLUE}Test 4: Checking conda availability...${NC}"
if ! command -v conda &> /dev/null; then
    echo -e "${YELLOW}⚠️  conda not found in PATH${NC}"
    echo -e "${YELLOW}Please ensure conda is installed and initialized in your shell${NC}"
    echo -e "${YELLOW}You can initialize conda with: conda init bash (or zsh)${NC}"
    exit 1
fi
echo -e "${GREEN}✓ conda is available${NC}"
echo ""

# Test 5: Check Python version
echo -e "${BLUE}Test 5: Checking Python version...${NC}"
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo -e "${GREEN}✓ Python version: $PYTHON_VERSION${NC}"
echo ""

# Test 6: Check if backend and frontend directories exist
echo -e "${BLUE}Test 6: Checking project structure...${NC}"
if [ ! -d "backend/server" ]; then
    echo -e "${RED}❌ backend/server directory not found${NC}"
    exit 1
fi
if [ ! -d "frontend" ]; then
    echo -e "${RED}❌ frontend directory not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Project structure is correct${NC}"
echo ""

# Test 7: Check if checkpoints script exists
echo -e "${BLUE}Test 7: Checking checkpoint download script...${NC}"
if [ ! -f "../checkpoints/download_ckpts.sh" ]; then
    echo -e "${RED}❌ Checkpoint download script not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Checkpoint script exists${NC}"
echo ""

# Test 8: Check if sam2-demo environment exists
echo -e "${BLUE}Test 8: Checking for sam2-demo conda environment...${NC}"
if conda env list | grep -q "sam2-demo"; then
    echo -e "${GREEN}✓ sam2-demo environment already exists${NC}"
    ENV_EXISTS=true
else
    echo -e "${YELLOW}⚠️  sam2-demo environment not found${NC}"
    echo -e "${YELLOW}You can create it with: make create-conda-env${NC}"
    ENV_EXISTS=false
fi
echo ""

# Summary
echo "=================================="
echo -e "${GREEN}🎉 All basic tests passed!${NC}"
echo ""
echo "Next steps:"
if [ "$ENV_EXISTS" = false ]; then
    echo "  1. Run: ${BLUE}make setup${NC} (one-time setup)"
else
    echo "  1. Environment already exists. Skip to step 2."
fi
echo "  2. Run: ${BLUE}conda activate sam2-demo${NC}"
echo "  3. Run: ${BLUE}make backend-mps${NC} (in one terminal)"
echo "  4. Run: ${BLUE}make frontend${NC} (in another terminal)"
echo ""
echo "For help, run: ${BLUE}make help${NC}"
