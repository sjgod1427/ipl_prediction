from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd

# Create FastAPI instance
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all for now; restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load trained model
model = joblib.load("IPL_model.pkl")

# Define input schema
class MatchInput(BaseModel):
    batting_team: str
    bowling_team: str
    city: str
    runs_left: int
    overs_left: float
    wickets_left: int
    current_runs: int
    total_runs_x: int
    
    
def overs_to_balls(overs: float) -> int:
    """Convert overs to balls (e.g., 2.3 overs = 14 balls)"""
    whole_overs = int(overs)
    remaining_balls = round((overs % 1) * 10)
    # Ensure remaining balls don't exceed 5 (valid in cricket)
    if remaining_balls > 5:
        remaining_balls = 5
    return whole_overs * 6 + remaining_balls


@app.post("/predict")
def predict_win(input: MatchInput):
    try:
        # Calculate derived metrics
        runs_left = input.total_runs_x - input.current_runs
        balls_left = overs_to_balls(input.overs_left)
        
        # Prevent division by zero
        if balls_left == 0:
            return {"error": "Cannot predict when no balls are left"}
        
        if input.overs_left == 0:
            return {"error": "Cannot predict when no overs are left"}
        
        # Calculate required run rate
        required_run_rate = runs_left / (balls_left / 6)
        
        # Calculate current run rate (runs per over)
        # Current rate should be based on overs completed, not overs left
        overs_completed = 20 - input.overs_left
        if overs_completed == 0:
            current_rate = 0  # No overs completed yet
        else:
            current_rate = input.current_runs / overs_completed
        
        # Create DataFrame for prediction
        data = pd.DataFrame([{
            "batting_team": input.batting_team,
            "bowling_team": input.bowling_team,
            "city": input.city,
            "runs_left": runs_left,
            "balls_left": balls_left,
            "wickets": input.wickets_left,
            "total_runs_x": input.total_runs_x,
            "current_rate": current_rate,
            "rrr": required_run_rate
        }])

        # Make prediction
        prediction = model.predict_proba(data)[0]
        print(f"Prediction probabilities: {prediction}")
        
        return {
            "batting_win_probability": round(prediction[1] * 100, 2),
            "bowling_win_probability": round(prediction[0] * 100, 2)
        }
        
    except Exception as e:
        print(f"Error during prediction: {str(e)}")
        return {"error": f"Prediction failed: {str(e)}"}


# Optional: Add a health check endpoint
@app.get("/health")
def health_check():
    return {"status": "healthy", "model_loaded": model is not None}


# Optional: Add an endpoint to get valid teams and cities
@app.get("/metadata")
def get_metadata():
    return {
        "teams": [
            'Royal Challengers Bangalore',
            'Kings XI Punjab',
            'Delhi Daredevils',
            'Mumbai Indians',
            'Kolkata Knight Riders',
            'Rajasthan Royals',
            'Deccan Chargers',
            'Chennai Super Kings',
            'Kochi Tuskers Kerala',
            'Pune Warriors',
            'Sunrisers Hyderabad',
            'Gujarat Lions',
            'Rising Pune Supergiants',
            'Rising Pune Supergiant',
            'Delhi Capitals',
            'Punjab Kings',
            'Lucknow Super Giants',
            'Gujarat Titans',
            'Royal Challengers Bengaluru'
        ],
        "cities": [
            'Bangalore', 'Chandigarh', 'Delhi', 'Mumbai', 'Kolkata', 'Jaipur',
            'Hyderabad', 'Chennai', 'Cape Town', 'Port Elizabeth', 'Durban',
            'Centurion', 'East London', 'Johannesburg', 'Kimberley',
            'Bloemfontein', 'Ahmedabad', 'Cuttack', 'Nagpur', 'Dharamsala',
            'Kochi', 'Indore', 'Visakhapatnam', 'Pune', 'Raipur', 'Ranchi',
            'Abu Dhabi', 'Rajkot', 'Kanpur', 'Bengaluru', 'Dubai', 'Sharjah',
            'Navi Mumbai', 'Lucknow', 'Guwahati', 'Mohali'
        ]
    }
    
handler = app    