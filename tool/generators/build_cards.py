import json
import os
import random

os.makedirs('assets/data', exist_ok=True)

COLORS = ['indigo', 'emerald', 'amber', 'rose', 'violet', 'cyan', 'teal', 'obsidian']

def make_card(cid, title, subtitle, back, hint, category, subcat, color, importance, answer, distractors):
    # Ensure answer is not in distractors
    clean_distractors = [d for d in distractors if d != answer]
    opts = [answer] + clean_distractors[:3]
    while len(opts) < 4:
        opts.append(f"Diğer {len(opts)+1}")
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

print("Loading generator logic...")
