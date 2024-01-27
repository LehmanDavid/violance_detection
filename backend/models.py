from sqlalchemy import Column, String, Float, Boolean, Integer
from sqlalchemy.ext.declarative import declarative_base


Base = declarative_base()


class PersonModel(Base):
    __tablename__ = "people"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    profile_img = Column(String)
    lat = Column(Float)
    lon = Column(Float)
    is_alert = Column(Boolean)
