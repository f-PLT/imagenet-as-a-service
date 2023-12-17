import torch
from torchvision.models import DenseNet

from imagenet_service.utils import get_model, transform_image
from tests.utils import get_resource_path


def test_get_model():
    test_model = get_model()
    assert isinstance(test_model, DenseNet)


def test_transform_image():
    with open(get_resource_path("resources/cat.jpg"), "rb") as test_file:
        image_bytes = test_file.read()
        test_transformed = transform_image(image_bytes)
        assert torch.is_tensor(test_transformed)
