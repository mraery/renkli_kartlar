import json
import os
import random

os.makedirs('assets/data', exist_ok=True)

# Helper to shuffle options and ensure answer is among them
def make_card(cid, title, subtitle, back, hint, category, subcat, color, importance, answer, distractors):
    opts = list(set([answer] + distractors[:3]))
    while len(opts) < 4:
        opts.append(f"Seçenek {len(opts) + 1}")
    random.shuffle(opts)
    return {
        "id": cid,
        "frontTitle": title,
        "frontSubtitle": subtitle,
        "backContent": back,
        "hint": hint,
        "category": category,
        "subCategory": subcat,
        "colorName": color,
        "importance": importance,
        "options": opts,
        "correctAnswer": answer
    }

print("Generator script created.")
