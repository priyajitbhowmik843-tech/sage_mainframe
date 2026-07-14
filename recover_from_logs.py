import json
import os
import glob

brain_dir = r"C:\Users\Priyajit Bhowmik\.gemini\antigravity\brain"
transcripts = glob.glob(os.path.join(brain_dir, "*", ".system_generated", "logs", "transcript_full.jsonl"))

latest_transcripts = sorted(transcripts, key=os.path.getmtime, reverse=True)[:5]

output_file = "RECOVERED_CODE.txt"
with open(output_file, 'w', encoding='utf-8') as out:
    for t in latest_transcripts:
        out.write(f"\n\n========================================\nFROM: {t}\n========================================\n")
        try:
            with open(t, 'r', encoding='utf-8') as f:
                for line in f:
                    try:
                        data = json.loads(line)
                        content = data.get("content", "")
                        if content and "class VideographerDashboard" in content:
                            out.write("\n\n--- MATCH FOUND ---\n")
                            out.write(content)
                        # Also look for tool calls replacing file content
                        if "tool_calls" in data:
                            for tc in data["tool_calls"]:
                                if tc.get("name") in ("replace_file_content", "write_to_file", "multi_replace_file_content"):
                                    args = tc.get("arguments", {})
                                    if args and "employee_dashboard" in str(args):
                                        out.write("\n\n--- TOOL CALL MATCH FOUND ---\n")
                                        out.write(json.dumps(args, indent=2))
                    except:
                        pass
        except Exception as e:
            out.write(f"Error reading: {e}\n")

print(f"Saved to {output_file}")
