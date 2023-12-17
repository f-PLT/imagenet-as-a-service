import pytest

from imagenet_service.inference import get_prediction


@pytest.mark.parametrize(
    "input_image,result",
    [
        ("resources/cat.jpg", ['n02123159', 'tiger_cat']),
        ("resources/dog.jpg", ['n02099601', 'golden_retriever']),
    ]
)
def test_get_prediction(input_image, result):
    with open(input_image, "rb") as test_file:
        image_bytes = test_file.read()
        results = get_prediction(image_bytes)
        assert results == result
