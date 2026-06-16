import io 
import torch
import librosa 
from fastapi import FastAPI, UploadFile, File 
from fastapi.middleware.cors import CORSMiddleware 
from transformers import Wav2Vec2ForSequenceClassification, Wav2Vec2Processor 
app = FastAPI()
@app.get("/")
async def root():
    return {"message":"Server is running!"}
app.add_middleware( 
    CORSMiddleware, 
    allow_origins=["*"],
      allow_methods=["*"], 
      allow_headers=["*"], ) 
MODEL_PATH = "./wav2vec2-emotion-model" 
processor = Wav2Vec2Processor.from_pretrained(MODEL_PATH)
model = Wav2Vec2ForSequenceClassification.from_pretrained(MODEL_PATH) 

EMOTION_GROUPS = { "confidence": {"happy", "calm", "surprised"}, 
                  "neutral": {"neutral","disgust"}, 
                  "anxiety": {"fear", "sad", }, 
                  "anger": {"angry"}, } 
def predict_segment(segment) -> str:
     inputs = processor(segment, sampling_rate=16000, return_tensors="pt", padding=True) 
     with torch.no_grad():
         logits = model(**inputs).logits
         predicted_id = torch.argmax(logits, dim=-1).item()
         return model.config.id2label[predicted_id].lower() 
def calculate_percentages(results: list[str]) -> dict: 
        total = len(results) 
        return {
             group: round(sum(e in emotions for e in results) / total * 100, 1) 
             for group, emotions in EMOTION_GROUPS.items() 
             }
@app.post("/analyze")
async def analyze_voice(file: UploadFile = File(...)):
             audio_bytes = await file.read()
             y, sr = librosa.load(io.BytesIO(audio_bytes), sr=16000)
             segment_size = 3 * sr 
             y, _=librosa.effects.trim(y)
             segments = [y[i:i + segment_size] for i in range(0, len(y), segment_size)] 
             results = [predict_segment(seg) for seg in segments] 
             print(f"Raw results from segments: {results}")
             return calculate_percentages(results)
