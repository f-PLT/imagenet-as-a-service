import time
from multiprocessing import Process

import pytest
import uvicorn
from fastapi.testclient import TestClient

from imagenet_service.main import app
from tests.utils import get_resource_path


def run_app():
    uvicorn.run(app, host="127.0.0.1", port=8765)


@pytest.fixture(scope="module", name="test_app")
def fixture_test_app():
    # Start FastAPI app in a separate process
    app_process = Process(target=run_app)
    app_process.start()

    # Wait for the app to start
    time.sleep(2)

    yield TestClient(app)

    # Stop the app process
    app_process.terminate()


def test_root(test_app):
    response = test_app.get("/")
    assert response.status_code == 200


@pytest.mark.parametrize(
    "input_image,result",
    [
        (
            get_resource_path("resources/cat.jpg"),
            {"class_id": "n02123159", "class_name": "Tiger Cat"},
        ),
        (
            get_resource_path("resources/dog.jpg"),
            {"class_id": "n02099601", "class_name": "Golden Retriever"},
        ),
    ],
)
def test_create_item(test_app, input_image, result):
    filepath = get_resource_path(input_image)
    with open(filepath, "rb") as image:
        data = {"file": ("image.jpg", image, "image/jpeg")}
        print(data)
        response = test_app.post("/predict", files=data)
        assert response.status_code == 200
        assert response.json() == result
