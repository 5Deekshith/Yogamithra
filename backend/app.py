from fastapi import FastAPI, File, UploadFile
import cv2
import numpy as np
import mediapipe as mp
import base64
from fastapi.responses import JSONResponse
from gtts import gTTS
import pickle
import uvicorn

# Load pre-trained model
model_file = "yoga_pose_model.pkl"
with open(model_file, "rb") as f:
    model = pickle.load(f)

# Load expected angles from JSON
expected_angles_dict = {
    "adho mukha svanasana": {"L-elbow": 160, "R-elbow": 160, "L-knee": 175, "R-knee": 175},
    "balasana": {"L-elbow": 90, "R-elbow": 90, "L-knee": 90, "R-knee": 90},
    "garudasana": {"L-elbow": 45, "R-elbow": 45, "L-knee": 60, "R-knee": 60},
    "marjaryasana": {"L-elbow": 170, "R-elbow": 170, "L-knee": 90, "R-knee": 90},
    "parsva bakasana": {"L-elbow": 90, "R-elbow": 90, "L-knee": 45, "R-knee": 45},
    "salabhasana": {"L-elbow": 170, "R-elbow": 170, "L-knee": 180, "R-knee": 180},
    "setu bandha sarvangasana": {"L-elbow": 160, "R-elbow": 160, "L-knee": 90, "R-knee": 90},
    "utthita trikonasana": {"L-elbow": 180, "R-elbow": 180, "L-knee": 160, "R-knee": 160},
    "virabhadrasana ii": {"L-elbow": 180, "R-elbow": 180, "L-knee": 90, "R-knee": 90}
}

# Initialize Mediapipe
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils

# Mapping landmark index to joint names
index_to_name = {
    mp_pose.PoseLandmark.LEFT_ELBOW.value: "L-elbow",
    mp_pose.PoseLandmark.RIGHT_ELBOW.value: "R-elbow",
    mp_pose.PoseLandmark.LEFT_KNEE.value: "L-knee",
    mp_pose.PoseLandmark.RIGHT_KNEE.value: "R-knee",
    mp_pose.PoseLandmark.LEFT_SHOULDER.value: "L-shoulder",
    mp_pose.PoseLandmark.RIGHT_SHOULDER.value: "R-shoulder",
    mp_pose.PoseLandmark.LEFT_WRIST.value: "L-wrist",
    mp_pose.PoseLandmark.RIGHT_WRIST.value: "R-wrist",
    mp_pose.PoseLandmark.LEFT_ANKLE.value: "L-ankle",
    mp_pose.PoseLandmark.RIGHT_ANKLE.value: "R-ankle",
    mp_pose.PoseLandmark.LEFT_HIP.value: "L-hip",
    mp_pose.PoseLandmark.RIGHT_HIP.value: "R-hip"
}

def calculate_angle(a, b, c):
    a, b, c = np.array(a), np.array(b), np.array(c)
    ba, bc = a - b, c - b
    cosine_angle = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc))
    angle = np.arccos(np.clip(cosine_angle, -1.0, 1.0))
    return np.degrees(angle)

def compare_angles(detected, expected, threshold=10):
    return [part for part in detected if part in expected and abs(detected[part] - expected[part]) > threshold]

def process_image(image, selected_pose):
    with mp_pose.Pose(static_image_mode=True, min_detection_confidence=0.5) as pose:
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = pose.process(image_rgb)
        if not results.pose_landmarks:
            return None, None, "No human detected.", []

        landmarks = results.pose_landmarks.landmark
        angles = {
            "L-wrist": calculate_angle(
                [landmarks[13].x, landmarks[13].y],
                [landmarks[15].x, landmarks[15].y],
                [landmarks[19].x, landmarks[19].y]
            ),
            "R-wrist": calculate_angle(
                [landmarks[14].x, landmarks[14].y],
                [landmarks[16].x, landmarks[16].y],
                [landmarks[20].x, landmarks[20].y]
            ),
            "L-elbow": calculate_angle(
                [landmarks[11].x, landmarks[11].y],
                [landmarks[13].x, landmarks[13].y],
                [landmarks[15].x, landmarks[15].y]
            ),
            "R-elbow": calculate_angle(
                [landmarks[12].x, landmarks[12].y],
                [landmarks[14].x, landmarks[14].y],
                [landmarks[16].x, landmarks[16].y]
            ),
            "L-shoulder": calculate_angle(
                [landmarks[23].x, landmarks[23].y],
                [landmarks[11].x, landmarks[11].y],
                [landmarks[13].x, landmarks[13].y]
            ),
            "R-shoulder": calculate_angle(
                [landmarks[24].x, landmarks[24].y],
                [landmarks[12].x, landmarks[12].y],
                [landmarks[14].x, landmarks[14].y]
            ),
            "L-knee": calculate_angle(
                [landmarks[23].x, landmarks[23].y],
                [landmarks[25].x, landmarks[25].y],
                [landmarks[27].x, landmarks[27].y]
            ),
            "R-knee": calculate_angle(
                [landmarks[24].x, landmarks[24].y],
                [landmarks[26].x, landmarks[26].y],
                [landmarks[28].x, landmarks[28].y]
            ),
            "L-ankle": calculate_angle(
                [landmarks[25].x, landmarks[25].y],
                [landmarks[27].x, landmarks[27].y],
                [landmarks[29].x, landmarks[29].y]
            ),
            "R-ankle": calculate_angle(
                [landmarks[26].x, landmarks[26].y],
                [landmarks[28].x, landmarks[28].y],
                [landmarks[30].x, landmarks[30].y]
            ),
            "L-hip": calculate_angle(
                [landmarks[11].x, landmarks[11].y],
                [landmarks[23].x, landmarks[23].y],
                [landmarks[25].x, landmarks[25].y]
            ),
            "R-hip": calculate_angle(
                [landmarks[12].x, landmarks[12].y],
                [landmarks[24].x, landmarks[24].y],
                [landmarks[26].x, landmarks[26].y]
            )
        }

        expected_angles = expected_angles_dict.get(selected_pose, {})
        incorrect_parts = compare_angles(angles, expected_angles)

        skeleton_image = image.copy()
        for connection in mp_pose.POSE_CONNECTIONS:
            start = landmarks[connection[0]]
            end = landmarks[connection[1]]
            start_point = (int(start.x * image.shape[1]), int(start.y * image.shape[0]))
            end_point = (int(end.x * image.shape[1]), int(end.y * image.shape[0]))

            start_name = index_to_name.get(connection[0], None)
            end_name = index_to_name.get(connection[1], None)

            if start_name in incorrect_parts or end_name in incorrect_parts:
                color = (0, 0, 255)  # Red for incorrect
            else:
                color = (0, 255, 0)  # Green for correct

            cv2.line(skeleton_image, start_point, end_point, color, 5)

        incorrect_parts_image = image.copy()
        for part in incorrect_parts:
            index = [k for k, v in index_to_name.items() if v == part]
            if index:
                point = landmarks[index[0]]
                point_x = int(point.x * image.shape[1])
                point_y = int(point.y * image.shape[0])
                cv2.circle(incorrect_parts_image, (point_x, point_y), 10, (0, 0, 255), -1)

        return angles, skeleton_image, incorrect_parts_image, incorrect_parts

def generate_audio_feedback(feedback_text, output_file="feedback.mp3"):
    tts = gTTS(text=feedback_text, lang='en')
    tts.save(output_file)
    return output_file

app = FastAPI()

@app.post("/classify-pose/")
async def classify_pose(file: UploadFile = File(...), selected_pose: str = "adho mukha svanasana"):
    try:
        image_bytes = await file.read()
        image = cv2.imdecode(np.frombuffer(image_bytes, np.uint8), cv2.IMREAD_COLOR)

        angles, skeleton_img, incorrect_parts_img, incorrect_parts = process_image(image, selected_pose)
        if angles is None:
            return JSONResponse(content={"error": "No human detected."}, status_code=400)

        feedback_text = "Perfect!" if not incorrect_parts else f"Incorrect parts: {', '.join(incorrect_parts)}. Please correct your pose."
        audio_feedback_path = generate_audio_feedback(feedback_text)

        _, skeleton_buffer = cv2.imencode('.jpg', skeleton_img)
        skeleton_base64 = base64.b64encode(skeleton_buffer).decode()
        _, incorrect_buffer = cv2.imencode('.jpg', incorrect_parts_img)
        incorrect_base64 = base64.b64encode(incorrect_buffer).decode()

        response = {
            "predicted_pose": selected_pose,
            "is_correct": len(incorrect_parts) == 0,
            "incorrect_parts": incorrect_parts,
            "angles": angles,
            "skeleton_image": skeleton_base64,
            "incorrect_parts_image": incorrect_base64,
            "audio_feedback_url": f"http://192.168.186.247:8000/classify-pose/{audio_feedback_path}"
        }
        return JSONResponse(content=response)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8000)

