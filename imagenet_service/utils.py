import io
import json

from PIL import Image
from torchvision import models, transforms

from imagenet_service import STATIC_FILES_ROOT

IMAGENET_INDEX_FILE = f"{STATIC_FILES_ROOT}/imagenet_class_index.json"
with open(IMAGENET_INDEX_FILE, encoding="UTF-8") as index_file:
    IMAGENET_CLASS_INDEX = json.load(index_file)


def get_model():
    # Make sure to set `weights` as `'IMAGENET1K_V1'` to use the pretrained weights:
    model = models.densenet121(weights="IMAGENET1K_V1")
    # Switch to `eval` mode:
    model.eval()
    return model


def transform_image(image_bytes):
    my_transforms = transforms.Compose(
        [
            transforms.Resize(255),
            transforms.CenterCrop(224),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
        ]
    )
    image = Image.open(io.BytesIO(image_bytes))
    return my_transforms(image).unsqueeze(0)


# ImageNet classes are often of the form `can_opener` or `Egyptian_cat`
# will use this method to properly format it so that we get
# `Can Opener` or `Egyptian Cat`
def format_class_name(class_name):
    class_name = class_name.replace("_", " ")
    class_name = class_name.title()
    return class_name
