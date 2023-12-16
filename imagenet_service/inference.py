from imagenet_service.utils import IMAGENET_CLASS_INDEX, get_model, transform_image


def get_prediction(image_bytes):
    tensor = transform_image(image_bytes=image_bytes)
    model = get_model()
    outputs = model.forward(tensor)
    _, y_hat = outputs.max(1)
    predicted_idx = str(y_hat.item())
    return IMAGENET_CLASS_INDEX[predicted_idx]
