import os
from pathlib import Path

import coremltools as ct
import coremltools.optimize.coreml as cto
import torch
from transformers import CLIPModel


ROOT = Path(os.environ["MEALMIRROR_MODEL_LAB"])
MODEL = ROOT / "TinyCLIP"


class ImageEncoder(torch.nn.Module):
    def __init__(self, clip: CLIPModel):
        super().__init__()
        self.vision_model = clip.vision_model
        self.projection = clip.visual_projection
        self.register_buffer("mean", torch.tensor([0.48145466, 0.4578275, 0.40821073]).view(1, 3, 1, 1))
        self.register_buffer("std", torch.tensor([0.26862954, 0.26130258, 0.27577711]).view(1, 3, 1, 1))

    def forward(self, image):
        pixels = (image - self.mean) / self.std
        pooled = self.vision_model(pixel_values=pixels, return_dict=False)[1]
        features = self.projection(pooled)
        return features / features.norm(dim=-1, keepdim=True)


clip = CLIPModel.from_pretrained(MODEL, local_files_only=True).eval()
encoder = ImageEncoder(clip).eval()
example = torch.rand(1, 3, 224, 224)
traced = torch.jit.trace(encoder, example, strict=False)
image_input = ct.ImageType(name="image", shape=example.shape, scale=1 / 255)
base = ct.convert(
    traced,
    source="pytorch",
    convert_to="mlprogram",
    minimum_deployment_target=ct.target.iOS17,
    inputs=[image_input],
    outputs=[ct.TensorType(name="embedding")],
    compute_precision=ct.precision.FLOAT16,
)
base_path = ROOT / "TinyCLIPImageEncoder.mlpackage"
base.save(str(base_path))
print("float16_bytes", sum(p.stat().st_size for p in base_path.rglob("*") if p.is_file()))

quantized = cto.linear_quantize_weights(
    base,
    config=cto.OptimizationConfig(global_config=cto.OpLinearQuantizerConfig(mode="linear_symmetric", dtype="int8")),
)
quantized_path = ROOT / "TinyCLIPImageEncoder-int8.mlpackage"
quantized.save(str(quantized_path))
print("int8_bytes", sum(p.stat().st_size for p in quantized_path.rglob("*") if p.is_file()))
