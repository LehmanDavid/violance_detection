import pickle
import tempfile
from fastapi import FastAPI, UploadFile
import pickle
import numpy as np

from preprocess import *


app = FastAPI()

# Load your model
with open('finalized_model.sav', 'rb') as model_file:
    model = pickle.load(model_file)


# Load feature extraction model (adjust paths as needed)
feature_extractor = getFeatureExtractor('weights/weights.h5', 'fc6')


@app.post("/predict")
async def predict(file: UploadFile):
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as temp_file:
        temp_file.write(await file.read())
        temp_file_path = temp_file.name

    # Preprocess the video
    video_chunks = process_video_for_prediction(temp_file_path)

    # Extract features for each chunk
    features = [feature_extractor.predict(
        chunk[np.newaxis, ...]) for chunk in video_chunks]
    features = np.concatenate(features, axis=0)

    prediction = model.predict(features)
    # Convert the prediction to a list if it's a NumPy array
    if isinstance(prediction, np.ndarray):
        prediction_list = prediction.tolist()
    else:
        # Assuming 'prediction' is already in a serializable format
        prediction_list = prediction

    aggregated_prediction = 1 if sum(
        prediction_list) / len(prediction_list) > 0.5 else 0

    if aggregated_prediction == 1:
        return {"prediction": 'violent'}
    else:
        return {"prediction": 'non-violent'}

