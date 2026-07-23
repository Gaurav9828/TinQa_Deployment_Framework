from pydantic import BaseModel, Field

class WiFiRequest(BaseModel):
    ssid: str = Field(..., min_length=1, max_length=64)
    password: str = Field(..., min_length=8, max_length=64)