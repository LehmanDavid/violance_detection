import pickle
import tempfile
from fastapi import FastAPI, UploadFile, Depends, status
import pickle
import numpy as np
from backend import models, schemas
from sqlalchemy.orm import Session
from fastapi import FastAPI
from backend.db import get_db

from preprocess import *


app = FastAPI()

# Load your model
with open('finalized_model.sav', 'rb') as model_file:
    model = pickle.load(model_file)


# Load feature extraction model (adjust paths as needed)
feature_extractor = getFeatureExtractor('weights/weights.h5', 'fc6')


@app.post("/predict", tags = ["Prediction"])
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



@app.get("/people/{person_id}", tags=["CRUD"])
def get_person(person_id: int, db: Session = Depends(get_db)):
    return db.query(models.PersonModel).filter(models.PersonModel.id == person_id).first()

@app.get("/get-people", tags=["CRUD"])
def get_people(db: Session = Depends(get_db)):
    people = db.query(models.PersonModel).all()
    return {"data": people}

@app.post("/create-person", status_code=status.HTTP_201_CREATED, tags=["CRUD"])
def create_person(person: schemas.Person, db: Session = Depends(get_db)):
    db_person = models.PersonModel(**person.model_dump())
    db.add(db_person)
    db.commit()
    db.refresh(db_person)
    return {"status: ok"}

@app.delete("/people/{person_id}", tags=["CRUD"])
def delete_person(person_id: int, db: Session = Depends(get_db)):
    db.query(models.PersonModel).filter(models.PersonModel.id == person_id).delete()
    db.commit()
    return {"status: ok"}

@app.delete("/people", tags=["CRUD"])
def delete_all_people(db: Session = Depends(get_db)):
    db.query(models.PersonModel).delete()
    db.commit()
    return {"status: ok"}