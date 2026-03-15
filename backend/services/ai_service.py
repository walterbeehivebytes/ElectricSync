"""Claude AI service for work order generation and crew dispatch recommendations."""
import os
import json
import anthropic

_client = None


def _get_client() -> anthropic.Anthropic:
    global _client
    if _client is None:
        api_key = os.getenv("ANTHROPIC_API_KEY")
        if not api_key:
            raise ValueError("ANTHROPIC_API_KEY environment variable not set")
        _client = anthropic.Anthropic(api_key=api_key)
    return _client


def generate_work_order(description: str) -> dict:
    """
    PM provides a plain-text description of work needed.
    Claude returns a structured work order with tasks, materials, and estimates.
    """
    client = _get_client()

    prompt = f"""You are an expert electrical project manager with 20 years of experience.
A Project Manager has described some work that needs to be done on a job site.
Generate a structured work order broken down into concrete tasks.

Job description:
{description}

Respond with ONLY valid JSON in this exact format (no markdown, no explanation):
{{
  "title": "Brief work order title (max 60 chars)",
  "overall_priority": "low|medium|high|urgent",
  "estimated_total_hours": 16,
  "tasks": [
    {{
      "title": "Task title (max 60 chars)",
      "description": "What needs to be done and how",
      "priority": "low|medium|high|urgent",
      "estimated_hours": 8,
      "materials": ["material 1", "material 2"],
      "safety_requirements": ["OSHA requirement or PPE needed"]
    }}
  ]
}}

Guidelines:
- Break work into 2-5 logical tasks that one team can execute sequentially
- Materials should be specific (e.g. "3/4 EMT conduit" not just "conduit")
- Safety requirements must match NEC 2023 and OSHA standards
- Estimated hours should be realistic for a journeyman electrician
- Priority should reflect urgency and impact on other trades"""

    message = client.messages.create(
        model="claude-opus-4-6",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}],
    )

    raw = message.content[0].text.strip()
    # Strip markdown code blocks if Claude wraps the JSON
    if raw.startswith("```"):
        raw = raw.split("```")[1]
        if raw.startswith("json"):
            raw = raw[4:]
    return json.loads(raw.strip())


def dispatch_recommend(tasks: list[dict], crew: list[dict]) -> dict:
    """
    Site Manager provides unassigned tasks and available crew.
    Claude recommends optimal assignments with reasoning.
    """
    client = _get_client()

    prompt = f"""You are an expert electrical site manager optimizing crew assignments.

UNASSIGNED TASKS:
{json.dumps(tasks, indent=2)}

AVAILABLE CREW:
{json.dumps(crew, indent=2)}

Recommend the optimal task assignments. Consider:
- Task priority (urgent first)
- Crew member current workload (balance the load)
- Task skill requirements vs crew experience
- Geographic proximity on the job site where possible

Respond with ONLY valid JSON (no markdown, no explanation):
{{
  "assignments": [
    {{
      "task_id": "task id",
      "task_title": "task title",
      "recommended_user_id": "user id",
      "recommended_user_name": "crew member name",
      "reasoning": "1-2 sentence explanation of why this person for this task"
    }}
  ],
  "summary": "1-2 sentence overall dispatch strategy summary"
}}"""

    message = client.messages.create(
        model="claude-opus-4-6",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}],
    )

    raw = message.content[0].text.strip()
    if raw.startswith("```"):
        raw = raw.split("```")[1]
        if raw.startswith("json"):
            raw = raw[4:]
    return json.loads(raw.strip())
