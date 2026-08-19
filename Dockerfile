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

# Diagnostic only -- does not fail the build either way, so we always end up
# with a deployable image, but the build log will show definitively whether
# extra_model_paths.yaml actually exists in THIS built image (not just in the
# Dockerfile source), and whether this ComfyUI install's own code even
# contains the auto-load logic for it.
RUN echo "=== extra_model_paths.yaml presence check ===" \
    && (ls -la /comfyui/extra_model_paths.yaml && cat /comfyui/extra_model_paths.yaml || echo "FILE NOT FOUND at /comfyui/extra_model_paths.yaml") \
    && echo "=== ComfyUI version ===" \
    && (cat /comfyui/comfyui_version.py 2>/dev/null || pip show comfyui 2>/dev/null || echo "version file not found") \
    && echo "=== main.py extra_model_paths references ===" \
    && (grep -rn "extra_model_paths" /comfyui/main.py /comfyui/folder_paths.py /comfyui/utils/extra_config.py 2>/dev/null || echo "no references found in expected files") \
    && echo "=== end diagnostic ==="
# trigger build
