import argparse
import csv
import json
import os
from collections import Counter
from typing import Dict, Iterable, List, Optional

import requests

VALID_LABELS = {"REAL", "FAKE", "UNCERTAIN"}


def normalize_label(value: str) -> str:
    value = value.strip().upper()
    if value in {"TRUE", "T", "YES"}:
        return "REAL"
    if value in {"FALSE", "F", "NO"}:
        return "FAKE"
    if value in {"UNCERTAIN", "UNKNOWN", "NOT SURE", "UNSURE"}:
        return "UNCERTAIN"
    return value


def load_dataset(path: str) -> List[Dict[str, str]]:
    if not os.path.isfile(path):
        raise FileNotFoundError(f"Dataset file not found: {path}")

    _, ext = os.path.splitext(path.lower())
    data = []

    if ext == ".jsonl":
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                if line.strip():
                    item = json.loads(line)
                    data.append(item)
    elif ext == ".json":
        with open(path, "r", encoding="utf-8") as f:
            payload = json.load(f)
            if isinstance(payload, list):
                data = payload
            else:
                raise ValueError("JSON dataset file must contain a list of records")
    elif ext == ".csv":
        with open(path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            data = [row for row in reader]
    else:
        raise ValueError("Unsupported dataset format. Use .json, .jsonl, or .csv")

    normalized = []
    for item in data:
        title = str(item.get("title", "")).strip()
        text = str(item.get("text", "")).strip()
        expected_label = normalize_label(str(item.get("expected_label", "")).strip())
        if expected_label not in VALID_LABELS:
            raise ValueError(f"Invalid expected_label: {expected_label} in item: {item}")
        normalized.append({"title": title, "text": text, "expected_label": expected_label})
    return normalized


def build_default_dataset() -> List[Dict[str, str]]:
    return [
        {
            "title": "Presifent of Sri Inka",
            "text": "ranil is the presifent of sri lnka",
            "expected_label": "REAL",
        },
        {
            "title": "Presifent of Sri Inka",
            "text": "donuld trumph is the presifent of sri lnka",
            "expected_label": "FAKE",
        },
        {
            "title": "AKD Wins Election",
            "text": "Anura Kumara Dissanayake is the new president of Sri Lanka",
            "expected_label": "REAL",
        },
        {
            "title": "Unknown claim",
            "text": "The moon is made of green cheese",
            "expected_label": "FAKE",
        },
        {
            "title": "Current world leader",
            "text": "The prime minister of the United Kingdom is Rishi Sunak",
            "expected_label": "FAKE",
        },
    ]


def evaluate(predictions: List[Dict[str, str]]) -> Dict[str, float]:
    correct = sum(1 for p in predictions if p["label"] == p["expected_label"])
    total = len(predictions)
    accuracy = correct / total if total else 0.0

    label_counts = Counter()
    true_counts = Counter()
    predicted_counts = Counter()
    correct_counts = Counter()

    for item in predictions:
        expected = item["expected_label"]
        predicted = item["label"]
        label_counts[expected] += 1
        predicted_counts[predicted] += 1
        if expected == predicted:
            correct_counts[expected] += 1

    for label in VALID_LABELS:
        true_counts[label] = label_counts[label]

    precision = {}
    recall = {}
    f1 = {}
    for label in VALID_LABELS:
        tp = correct_counts[label]
        fp = predicted_counts[label] - tp
        fn = true_counts[label] - tp
        precision[label] = tp / (tp + fp) if tp + fp else 0.0
        recall[label] = tp / (tp + fn) if tp + fn else 0.0
        f1[label] = 2 * precision[label] * recall[label] / (precision[label] + recall[label]) if precision[label] + recall[label] else 0.0

    macro_precision = sum(precision.values()) / len(VALID_LABELS)
    macro_recall = sum(recall.values()) / len(VALID_LABELS)
    macro_f1 = sum(f1.values()) / len(VALID_LABELS)

    return {
        "accuracy": accuracy,
        "macro_precision": macro_precision,
        "macro_recall": macro_recall,
        "macro_f1": macro_f1,
        "label_counts": dict(label_counts),
        "predicted_counts": dict(predicted_counts),
        "correct_counts": dict(correct_counts),
        "precision": precision,
        "recall": recall,
        "f1": f1,
    }


def request_prediction(url: str, title: str, text: str) -> Optional[Dict[str, str]]:
    payload = {"title": title, "text": text}
    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers, timeout=30)
    response.raise_for_status()
    data = response.json()
    label = normalize_label(str(data.get("label", "")).strip())
    if label not in VALID_LABELS:
        raise ValueError(f"Invalid label returned by service: {label}")
    return {
        "label": label,
        "confidence": float(data.get("confidence", 0.0)),
        "reason": str(data.get("reason", "")),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Evaluate TruthLens ML service accuracy against labeled claims.")
    parser.add_argument("--dataset", help="Path to a JSON/JSONL/CSV file containing title,text,expected_label records.")
    parser.add_argument("--url", default="http://127.0.0.1:10000/api/predict", help="ML service prediction endpoint URL.")
    parser.add_argument("--show-details", action="store_true", help="Print prediction details for each tested claim.")
    args = parser.parse_args()

    if args.dataset:
        dataset = load_dataset(args.dataset)
    else:
        dataset = build_default_dataset()

    predictions = []
    print(f"Evaluating {len(dataset)} claim(s) against {args.url}\n")

    for record in dataset:
        try:
            result = request_prediction(args.url, record["title"], record["text"])
            predictions.append({
                "title": record["title"],
                "text": record["text"],
                "expected_label": record["expected_label"],
                "label": result["label"],
                "confidence": result["confidence"],
                "reason": result["reason"],
            })
            if args.show_details:
                print("TITLE:", record["title"])
                print("TEXT:", record["text"])
                print("EXPECTED:", record["expected_label"])
                print("PREDICTED:", result["label"], f"(confidence={result['confidence']:.2f})")
                print("REASON:", result["reason"])
                print("---")
        except Exception as exc:
            print(f"ERROR: failed to get prediction for '{record['title']}': {exc}")
            predictions.append({
                "title": record["title"],
                "text": record["text"],
                "expected_label": record["expected_label"],
                "label": "UNKNOWN",
                "confidence": 0.0,
                "reason": str(exc),
            })

    metrics = evaluate([p for p in predictions if p["label"] in VALID_LABELS])

    print("\nRESULTS")
    print("-------")
    print(f"Accuracy: {metrics['accuracy'] * 100:.2f}%")
    print(f"Macro precision: {metrics['macro_precision'] * 100:.2f}%")
    print(f"Macro recall: {metrics['macro_recall'] * 100:.2f}%")
    print(f"Macro F1: {metrics['macro_f1'] * 100:.2f}%")
    print("\nLabel counts:")
    for label in sorted(VALID_LABELS):
        print(f"  {label}: expected={metrics['label_counts'].get(label, 0)} predicted={metrics['predicted_counts'].get(label, 0)} correct={metrics['correct_counts'].get(label, 0)}")

    print("\nPer-label metrics:")
    for label in sorted(VALID_LABELS):
        print(f"  {label}: precision={metrics['precision'][label] * 100:.2f}%, recall={metrics['recall'][label] * 100:.2f}%, f1={metrics['f1'][label] * 100:.2f}%")


if __name__ == "__main__":
    main()
