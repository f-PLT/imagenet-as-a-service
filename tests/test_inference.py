import pytest

from imagenet_service.inference import get_prediction
from tests.utils import get_resource_path


@pytest.mark.parametrize(
    "input_image,result",
    [
        (get_resource_path("resources/cat.jpg"), ["n02123159", "tiger_cat"]),
        (get_resource_path("resources/dog.jpg"), ["n02099601", "golden_retriever"]),
    ],
)
def test_get_prediction(input_image, result):
    with open(input_image, "rb") as test_file:
        image_bytes = test_file.read()
        results = get_prediction(image_bytes)
        assert results == result
