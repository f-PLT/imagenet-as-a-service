import io

import pytest
import torch
from torchvision.models import DenseNet
from PIL import Image

from imagenet_service.utils import get_model, transform_image


def test_get_model():
    test_model = get_model()
    assert isinstance(test_model, DenseNet)


def test_transform_image():
    with open("resources/cat.jpg", "rb") as test_file:
        image_bytes = test_file.read()
        test_transformed = transform_image(image_bytes)
        assert torch.is_tensor(test_transformed)
