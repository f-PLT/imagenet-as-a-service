from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.responses import JSONResponse

from imagenet_service.inference import get_prediction
from imagenet_service.utils import format_class_name

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Welcome, ths is a small service to explore and play around ImageNet models using Pytorch"}


@app.post("/predict")
def predict(file: UploadFile = File(...)):
    if not file:
        raise HTTPException(status_code=400, detail="File not found")
    img_bytes = file.file.read()
    class_id, class_name = get_prediction(image_bytes=img_bytes)
    class_name = format_class_name(class_name)
    return JSONResponse(content={"class_id": class_id, "class_name": class_name})
