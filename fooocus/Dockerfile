ARG BASE_IMAGE

FROM $BASE_IMAGE

WORKDIR /workspace/fooocus

RUN apt update -y && apt install git wget curl libgl1 libglib2.0-0 -y

ARG FOOOCUS_VERSION
RUN git clone https://github.com/lllyasviel/Fooocus .
RUN git checkout v${FOOOCUS_VERSION}

ENV TORCH_INDEX_URL=https://download.pytorch.org/whl/cu128 \
    TORCH_COMMAND="pip install --index-url https://download.pytorch.org/whl/cu128 torch==2.7.0+cu128 torchvision==0.22.0+cu128 torchaudio==2.7.0+cu128" \
    XFORMERS_PACKAGE=xformers==0.0.30

# Patch Fooocus 2.5.x for Starlette's newer TemplateResponse signature.
RUN python - <<'PY'
from pathlib import Path

path = Path("modules/ui_gradio_extensions.py")
text = path.read_text()
old = """def reload_javascript():
    js = javascript_html()
    css = css_html()

    def template_response(*args, **kwargs):
        res = GradioTemplateResponseOriginal(*args, **kwargs)
        res.body = res.body.replace(b'</head>', f'{js}</head>'.encode(\"utf8\"))
        res.body = res.body.replace(b'</body>', f'{css}</body>'.encode(\"utf8\"))
        res.init_headers()
        return res

    gr.routes.templates.TemplateResponse = template_response
"""
new = """def reload_javascript():
    js = javascript_html()
    css = css_html()

    def template_response(*args, **kwargs):
        if args and isinstance(args[0], str) and len(args) > 1 and isinstance(args[1], dict):
            request = args[1].get(\"request\")
            if request is not None:
                args = (request, args[0], args[1]) + args[2:]

        res = GradioTemplateResponseOriginal(*args, **kwargs)
        res.body = res.body.replace(b'</head>', f'{js}</head>'.encode(\"utf8\"))
        res.body = res.body.replace(b'</body>', f'{css}</body>'.encode(\"utf8\"))
        res.init_headers()
        return res

    gr.routes.templates.TemplateResponse = template_response
"""

if old not in text:
    raise SystemExit("Expected Fooocus template_response block was not found")

path.write_text(text.replace(old, new))
PY

# Patch Fooocus 2.5.x for RTX 50-series / Blackwell GPUs.
RUN python - <<'PY'
from pathlib import Path

patches = {
    "extras/ip_adapter.py": (
        """            org_dtype = n.dtype\n            current_step = float(model.model.diffusion_model.current_step.detach().cpu().numpy()[0])\n            cond_or_uncond = extra_options['cond_or_uncond']\n""",
        """            org_dtype = n.dtype\n            current_step = float(model.model.diffusion_model.current_step.detach().cpu().float().numpy()[0])\n            cond_or_uncond = extra_options['cond_or_uncond']\n""",
    ),
    "ldm_patched/modules/model_management.py": (
        """def unet_dtype(device=None, model_params=0):\n    if args.unet_in_bf16:\n        return torch.bfloat16\n    if args.unet_in_fp16:\n        return torch.float16\n    if args.unet_in_fp8_e4m3fn:\n        return torch.float8_e4m3fn\n    if args.unet_in_fp8_e5m2:\n        return torch.float8_e5m2\n    if should_use_fp16(device=device, model_params=model_params):\n        return torch.float16\n    return torch.float32\n\n# None means no manual cast\ndef unet_manual_cast(weight_dtype, inference_device):\n    if weight_dtype == torch.float32:\n        return None\n\n    fp16_supported = ldm_patched.modules.model_management.should_use_fp16(inference_device, prioritize_performance=False)\n""",
        """def unet_dtype(device=None, model_params=0):\n    if torch.cuda.is_available():\n        target_device = device if device is not None else \"cuda\"\n        try:\n            if torch.cuda.get_device_properties(target_device).major >= 12:\n                return torch.bfloat16\n        except Exception:\n            pass\n\n    if args.unet_in_bf16:\n        return torch.bfloat16\n    if args.unet_in_fp16:\n        return torch.float16\n    if args.unet_in_fp8_e4m3fn:\n        return torch.float8_e4m3fn\n    if args.unet_in_fp8_e5m2:\n        return torch.float8_e5m2\n    if should_use_fp16(device=device, model_params=model_params):\n        return torch.float16\n    return torch.float32\n\n# None means no manual cast\ndef unet_manual_cast(weight_dtype, inference_device):\n    if weight_dtype == torch.float32:\n        return None\n\n    if weight_dtype == torch.bfloat16:\n        return None\n\n    fp16_supported = ldm_patched.modules.model_management.should_use_fp16(inference_device, prioritize_performance=False)\n""",
    ),
    "modules/patch.py": (
        """def patched_unet_forward(self, x, timesteps=None, context=None, y=None, control=None, transformer_options={}, **kwargs):\n    self.current_step = 1.0 - timesteps.to(x) / 999.0\n    patch_settings[os.getpid()].global_diffusion_progress = float(self.current_step.detach().cpu().numpy().tolist()[0])\n\n    y = timed_adm(y, timesteps)\n""",
        """def patched_unet_forward(self, x, timesteps=None, context=None, y=None, control=None, transformer_options={}, **kwargs):\n    self.current_step = 1.0 - timesteps.to(x) / 999.0\n    patch_settings[os.getpid()].global_diffusion_progress = float(self.current_step.detach().cpu().float().flatten()[0].item())\n\n    y = timed_adm(y, timesteps)\n""",
    ),
}

for file_name, (old, new) in patches.items():
    path = Path(file_name)
    text = path.read_text()
    if old not in text:
        raise SystemExit(f"Expected Blackwell patch target was not found in {file_name}")
    path.write_text(text.replace(old, new))
PY

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install -r requirements_versions.txt && \
    pip install --index-url "$TORCH_INDEX_URL" torch==2.7.0+cu128 torchvision==0.22.0+cu128 torchaudio==2.7.0+cu128 && \
    pip install --no-deps jupyterlab "$XFORMERS_PACKAGE"
    
RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    sed '$d' launch.py > setup.py && \
    python setup.py

COPY --chmod=755 scripts/* ./

RUN ./setup-ssh.sh

CMD ["/workspace/fooocus/start.sh"]
