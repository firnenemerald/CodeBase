# main.py (Optimized with Shape-First Iterative Search)

import os
import argparse
import pandas as pd
import google.generativeai as genai
from dotenv import load_dotenv
import PIL.Image
import math

# --- Constants ---
SECRETS_DIR = "secrets"
DATABASE_PATH = os.path.join(SECRETS_DIR, "tablet_info.xlsx")
IMAGE_DIR = "sample_images"
LOCAL_SEARCH_BATCH_SIZE = 300

# --- Configuration ---
load_dotenv(dotenv_path=os.path.join(SECRETS_DIR, ".env"))
try:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise KeyError
    genai.configure(api_key=api_key)
except KeyError:
    print("❌ ERROR: GEMINI_API_KEY not found. Please check your .env file inside the 'secrets' folder.")
    exit()

# --- Model Initialization ---
model = genai.GenerativeModel('gemini-1.5-flash')

# --- Helper functions (load_pill_database and format helpers are unchanged) ---
def load_pill_database(xlsx_path):
    """Loads the pill descriptions from the specified Excel file."""
    try:
        df = pd.read_excel(xlsx_path)
        for col in ["품목일련번호", "업소일련번호"]:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0).astype(int)
        # Ensure the shape column ('제형') is a string for matching
        if '제형' in df.columns:
            df['제형'] = df['제형'].astype(str)
        print(f"✅ Successfully loaded {len(df)} pills from {xlsx_path}")
        return df
    except FileNotFoundError:
        print(f"❌ ERROR: Database file not found at '{xlsx_path}'")
        return None
    except Exception as e:
        print(f"❌ ERROR: Could not read the Excel file. Reason: {e}")
        return None

def get_pill_shape(image_obj):
    """
    NEW FUNCTION: Uses the LLM to identify the pill's shape more reliably.
    """
    print("Pre-analysis: Determining pill shape...")
    try:
        # Provide the exact list of possible shapes to the LLM
        shape_list = "마름모형, 반원형, 사각형, 삼각형, 오각형, 원형, 육각형, 장방형, 타원형, 팔각형, 기타"
        shape_prompt = [
            f"Analyze the 2D shape of the pill in the image. "
            f"Respond with ONLY ONE of the following Korean words from this list: {shape_list}.",
            "Do not describe the pill, just return the single most accurate shape name from the list.",
            image_obj
        ]
        response = model.generate_content(shape_prompt, request_options={'timeout': 20})
        shape = response.text.strip()

        # Validate that the response is one of the expected shapes
        if shape in shape_list.split(', '):
             print(f"Detected shape: {shape}")
             return shape
        print(f"⚠️ LLM returned an unexpected shape '{shape}'. Cannot filter by shape.")
        return None
    except Exception as e:
        print(f"⚠️ Could not determine shape from image. Error: {e}")
        return None

def format_database_for_prompt(df):
    """Formats the DataFrame into a detailed string for the LLM's local search."""
    # This function remains the same
    formatted_string = "Here is a list of candidate pills from our database:\n\n"
    for index, row in df.iterrows():
        formatted_string += f"- 품목일련번호 (ID): {row.get('품목일련번호', 'N/A')}\n"
        formatted_string += f"  품목명 (Name): {row.get('품목명', 'N/A')}\n"
        formatted_string += f"  각인 (Imprint): 앞 '{row.get('표시앞', '')}', 뒤 '{row.get('표시뒤', '')}'\n"
        formatted_string += f"  모양 (Shape): {row.get('제형', 'N/A')}\n"
        formatted_string += f"  색상 (Color): {row.get('색상', 'N/A')}\n\n"
    return formatted_string

def format_pill_details(pill_row):
    """Formats a single row of pill data into the final user-facing output."""
    # This function remains the same
    raw_date = str(pill_row.get('품목허가일자', ''))
    formatted_date = f"{raw_date[:4]}-{raw_date[4:6]}-{raw_date[6:]}" if len(raw_date) == 8 else raw_date
    details = (
        f"약물 이름: \"{pill_row.get('품목명', '정보 없음')}\" (일련번호 \"{pill_row.get('품목일련번호', '정보 없음')}\")\n"
        f"제조사: \"{pill_row.get('업소명', '정보 없음')}\" (일련번호 \"{pill_row.get('업소일련번호', '정보 없음')}\")\n"
        f"이미지:\n{pill_row.get('이미지', '정보 없음')}\n"
        f"성상: \"{pill_row.get('성상', '정보 없음')}\"\n"
        f"크기: {pill_row.get('크기장축', 'N/A')} x {pill_row.get('크기단축', 'N/A')}\n"
        f"분류: \"{pill_row.get('전문일반구분', '')}\" - \"{pill_row.get('분류명', '정보 없음')}\" (분류번호 \"{pill_row.get('분류번호', '정보 없음')}\")\n"
        f"허가일자: {formatted_date}"
    )
    return details

def identify_pill(image_path, pill_database_df):
    """Performs identification by pre-filtering by SHAPE, then batch iterating."""
    if not os.path.exists(image_path):
        return f"❌ ERROR: Image file not found at '{image_path}'", None

    img = PIL.Image.open(image_path)

    # --- UPDATED: Phase 1: Pre-filter database by SHAPE ---
    extracted_shape = get_pill_shape(img)
    if extracted_shape:
        # Use an exact match for the shape category
        candidates_df = pill_database_df[pill_database_df['제형'] == extracted_shape].copy()
        print(f"Found {len(candidates_df)} candidates matching the shape '{extracted_shape}'.")
    else:
        print("⚠️ Could not determine shape. All pills in the database will be searched.")
        candidates_df = pill_database_df.copy()

    # --- Iterative Batch Search Logic (Unchanged) ---
    if not candidates_df.empty:
        num_batches = math.ceil(len(candidates_df) / LOCAL_SEARCH_BATCH_SIZE)
        print(f"Beginning local search in {num_batches} batch(es)...")

        for i in range(num_batches):
            print(f"\n---------------------------\nSTEP 1: 🔎 Searching Batch {i+1} of {num_batches}...")
            start_index = i * LOCAL_SEARCH_BATCH_SIZE
            end_index = start_index + LOCAL_SEARCH_BATCH_SIZE
            batch_df = candidates_df.iloc[start_index:end_index]
            database_text = format_database_for_prompt(batch_df)
            local_prompt = [
                "You are a pill identification expert. Your task is to identify the pill in the image using ONLY the provided database text.",
                "Carefully compare the image's features (shape, color, imprint) to each entry in the list.",
                "If you find a confident match, respond with ONLY the '품목일련번호 (ID)' of that pill and nothing else.",
                "If you CANNOT find a confident match in this batch, respond with the exact keyword: NO_MATCH_FOUND",
                "\n--- Database Batch ---\n", database_text,
                "\n--- Image to Analyze ---\n", img
            ]
            try:
                response = model.generate_content(local_prompt)
                local_result = response.text.strip()
                if local_result != "NO_MATCH_FOUND" and local_result.isdigit():
                    pill_id = int(local_result)
                    matched_row = pill_database_df[pill_database_df['품목일련번호'] == pill_id]
                    if not matched_row.empty:
                        print(f"✅ Match found in Batch {i+1}! Pill ID: {pill_id}")
                        return "LOCAL_SUCCESS", matched_row.iloc[0]
                else:
                    print(f"No definitive match found in Batch {i+1}.")
            except Exception as e:
                print(f"An error occurred during local search on Batch {i+1}: {e}")
                print("Moving to the next batch or web search.")

    # --- Step 2: Web Search (Unchanged) ---
    print("\n---------------------------\nSTEP 2: 🌐 Local search complete. No match found. Performing web search...")
    web_prompt = [
        "You are a pill identification expert. Analyze the attached image of a pill. Using your general knowledge and web search capabilities, please identify it.",
        "Provide the most likely pill name, manufacturer, and key characteristics like imprint, shape, and color. Do not provide medical advice.",
        "Image to analyze:", img
    ]
    try:
        response = model.generate_content(web_prompt)
        return "WEB_SUCCESS", response.text
    except Exception as e:
        return f"An error occurred during web search API call: {e}", None

# --- Main Execution (Unchanged) ---
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Identify a pill using an image and an Excel database, with a web fallback.")
    parser.add_argument("image_filename", help=f"The filename of the pill image (must be in the '{IMAGE_DIR}' folder).")
    args = parser.parse_args()
    pill_db = load_pill_database(DATABASE_PATH)
    if pill_db is not None:
        image_path = os.path.join(IMAGE_DIR, args.image_filename)
        status, result = identify_pill(image_path, pill_db)
        print("\n--- Identification Result ---")
        if status == "LOCAL_SUCCESS":
            formatted_details = format_pill_details(result)
            print(formatted_details)
        elif status == "WEB_SUCCESS":
            print("⚠️ The following information is from a general web search and NOT from the verified database:\n")
            print(result)
        else:
            print(status)
        print("---------------------------\n")
        print("IMPORTANT: This is an experimental tool. Always consult a doctor or pharmacist for definitive pill ID.")