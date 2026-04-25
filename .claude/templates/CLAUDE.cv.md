# <slug> — Computer Vision Competition Rules

## Scoring
- Metric: <!-- e.g. mAP@0.5 | Dice | accuracy | AUC -->
- Direction: <!-- higher-better | lower-better -->
- Local proxy: <!-- script or function -->

## Submission
- Format: <!-- CSV with RLE masks | bounding boxes | class labels -->
- Daily limit: <!-- N -->

## Data
- Train images: <!-- N -->
- Image size: <!-- e.g. 1024×1024 | variable -->
- Channels: <!-- RGB | grayscale | multi-spectral -->
- Labels: <!-- per-image class | per-pixel mask | bounding boxes -->
- Mask format: <!-- RLE | PNG | JSON COCO -->

## Modeling approach
- Backbone: <!-- e.g. efficientnet-b4 | convnext-large | ViT-L/16 -->
- Framework: <!-- PyTorch + timm | detectron2 | ultralytics | mmdetection -->
- Augmentation: <!-- albumentations pipeline -->
- Loss: <!-- BCE | Focal | Dice | ComboLoss -->
- Compute: <!-- local GPU | Kaggle T4 x2 | Kaggle A100 -->

## CV strategy
- Split: <!-- StratifiedKFold on label | GroupKFold on patient_id | site_id -->
- OOF predictions: save to `models/<version>/oof_masks.npy`

## TTA (test-time augmentation)
- <!-- e.g. HFlip + 3 rotations → average logits -->

## Kaggle notebook (if code competition)
- Notebook slug: `<username>/<notebook-slug>`
- Dataset sources: competition images + weights as Kaggle Dataset
- Accelerator: `NvidiaTeslaT4` (×2) | `NvidiaL4` | `NvidiaH100`
- Internet: off (standard)

## Known quirks
- <!-- e.g. "image aspect ratios vary wildly — pad to square before resize" -->
- <!-- e.g. "some masks are empty — handle zero-area predictions" -->

## References
- Overview : https://www.kaggle.com/competitions/<slug>/overview
- Data     : https://www.kaggle.com/competitions/<slug>/data
