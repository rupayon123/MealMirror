# FoodSeg103 MobileNet research screen — October 4, 2026

This is a **rejected research candidate**. No checkpoint, dataset photo, or
per-image prediction belongs in the Challenge app or this repository. The
[model card](https://huggingface.co/mawiie/food-segmentation-mobilenet)
labels the checkpoint MIT and reports 23.33% validation mean intersection over
union on FoodSeg103. Its Western food training distribution and 104-class
closed taxonomy do not support a claim that it understands any cooked meal.
The upstream model card's license label does not settle every right in its
ImageNet-pretrained backbone or [FoodSeg103's Recipe1M-derived
data](https://github.com/LARC-CMU-SMU/FoodSeg103-Benchmark-v1).

## Fixed protocol

- Checkpoint: `mawiie/food-segmentation-mobilenet` revision
  `93d8c84b121ecce76ed752be538e01d72df15825`, file `best_model.pth`,
  SHA-256 `6ecc4da2210d8a2128f6a79670d40f25c8f5ffbf11b3358689669c431896600f`.
  Load state tensors with `torch.load(weights_only=True)` into the documented
  DeepLabV3+ / MobileNetV2 architecture. The model file is 17,908,102 bytes;
  a single-member deflated ZIP is 16,460,281 bytes. Added to the then-current
  12,186,608-byte app ZIP, this exceeds Apple's published 25 MB ceiling;
  quantized Core ML size was not tested.
- Meals: 200 [UECFoodPix](https://mm.cs.uec.ac.jp/uecfoodpix/) test photos,
  chosen by `random.Random(20271003).sample` from numerically sorted test IDs
  after excluding the category-ordered first 100. This reuses the existing
  [`select_uec_validation.py`](../vision/select_uec_validation.py) selection.
  UECFoodPix permits non-commercial research; its photos stay outside the app.
- Nonfood: the first 100 images in the pinned
  [Oxford-IIIT Pet](https://www.robots.ox.ac.uk/~vgg/data/pets/) test mirror
  (`timm/oxford-iiit-pet`, revision `089695c834a7deb60505b7cc506672db1c31a6aa`)
  and first 100 in the pinned
  [Oxford 102 Flowers](https://www.robots.ox.ac.uk/~vgg/data/flowers/102/) validation mirror
  (`dpdl-benchmark/oxford_flowers102`, revision
  `544b55c9af69a05742ead7571cd7ae23cfcd758b`).
- Preprocessing: RGB; resize shorter side to 512 pixels, center crop 512×512,
  convert to tensor, then ImageNet mean/std normalization. Inference used MPS
  on an M4 Mac with PyTorch 2.14.1, torchvision 0.29.1,
  segmentation-models-pytorch 0.5.0, Pillow 12.3.0, and pyarrow 23.0.1.
- A pixel counts as predicted food if the highest-logit class is any of the
  103 non-background classes. The two exploratory rules accept a photo when
  **more than** 5% or 50% of pixels are predicted food, respectively. These
  thresholds were inspected on this sample, so neither is independently
  calibrated. This checks food versus nonfood behavior, not correctness of
  ingredient names or carbohydrate values.

| Sample | Photos | >5% food pixels | >50% food pixels |
| --- | ---: | ---: | ---: |
| UECFoodPix meals | 200 | 199 | 90 |
| Oxford pets | 100 | 82 | 9 |
| Oxford flowers | 100 | 87 | 25 |

At the permissive rule, 169/200 nonfood photos receive a food result. Even the
stricter exploratory rule accepts 34/200 nonfood photos while losing more than
half the meals. Examples included flowers labeled as strawberry or tomato and
pets labeled as chicken/duck. The fixed benchmark is a useful rejection screen,
not a clinical or cross-cultural validation. **Do not integrate this model.**

## Reproduce without adding assets to the repository

Install the versions above in an external Python 3.11 environment, then
download the pinned checkpoint and dataset archives into an external research
directory. The checkpoint can be fetched with Hugging Face Hub's
`hf_hub_download` using the revision above. The Oxford parquet mirrors can be
fetched with `snapshot_download` at the revisions above; the required files
are `data/test-00000-of-00001.parquet` and
`data/validation-00000-of-00001.parquet`. Download the UECFoodPix tar from its
official provider. [`benchmark.py`](benchmark.py) checks the four input SHA-256
digests before running and prints only the aggregate table:

```sh
python research/foodseg-mobilenet/benchmark.py \
  --model /outside-repo/best_model.pth \
  --uec-tar /outside-repo/UECFOODPIX.tar \
  --pets-parquet /outside-repo/OxfordPets/data/test-00000-of-00001.parquet \
  --flowers-parquet /outside-repo/OxfordFlowers/data/validation-00000-of-00001.parquet
```

No image, checkpoint, or per-image output is written by the script. This probe
does not establish Core ML conversion, iPhone latency, clinical accuracy, or
safe identification of ingredients hidden within a meal.
