FROM runpod/worker-comfyui:5.8.5-base

# Path confirmed against runpod-workers/worker-comfyui's own published
# Dockerfile (github.com/runpod-workers/worker-comfyui), not assumed.
RUN git clone https://github.com/city96/ComfyUI-GGUF /comfyui/custom_nodes/ComfyUI-GGUF
RUN git clone https://github.com/DarioFT/ComfyUI-Qwen3-TTS /comfyui/custom_nodes/ComfyUI-Qwen3-TTS

# The base image installs custom-node requirements.txt files as part of its
# OWN build -- that loop does not automatically re-run for nodes added here,
# in a derived image. Installing each explicitly so this doesn't fail the
# same way (a node importing successfully but missing a dependency) after
# already fixing the "node not found" problem.
RUN if [ -f /comfyui/custom_nodes/ComfyUI-GGUF/requirements.txt ]; then \
      pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-GGUF/requirements.txt; \
    fi
RUN if [ -f /comfyui/custom_nodes/ComfyUI-Qwen3-TTS/requirements.txt ]; then \
      pip install --no-cache-dir -r /comfyui/custom_nodes/ComfyUI-Qwen3-TTS/requirements.txt; \
    fi
# trigger build
