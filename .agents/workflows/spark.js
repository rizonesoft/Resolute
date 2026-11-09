// Spark: dummy work on the cheap tier.
//
// Runs each brief as one subagent on muse-spark-1.3 at medium effort, in
// parallel, under a bounded evidence contract. The lead (whatever model
// the session runs) keeps every decision, every write, and final
// acceptance; sparks only fetch, locate, extract, and run named
// read-only commands, then report compact evidence the lead verifies.
//
// True mechanical work never reaches a model at all: anything a script
// can produce exactly (counts, file existence, line counts, claim
// re-measurement, plan stats, validation) is run as a script by the
// lead, for example scripts/todo-graph.py, scripts/todo-claims.py, or
// scripts/verify-agent-tiers.py. Spark is for the dummy work around
// those scripts: finding which file or line to look at, extracting a
// quoted value, and running a named read-only command whose output
// needs selecting rather than deciding.
//
// Why a saved workflow rather than agent definitions: Muse Spark is a
// Muse model, and Claude Code agent definitions cannot run it. In a
// Muse session this routing is expressed per call, and this file is the
// one place the model, the effort, and the contract are written.
//
// Usage: run this file through the workflow tool (scriptPath
// .agents/workflows/spark.js) with args of the shape
//   { "tasks": [ { "label": "inventory", "input": "Count ..." } ] }
// One task per independent brief. Batch related small queries into one
// brief instead of one task per question: the spawn cost is per task.
//
// Every brief inherits this contract, appended to the caller's input:
// read and run only, never write, compact evidence where every fact
// carries a cited source (a file:line or the exact command that
// produced it), and name every unresolved item rather than guess.
//
// Two guards run in this file, before and after the spawn, so neither
// depends on the lead remembering a rule:
// 1. A brief that carries judgment (deciding what is relevant,
//    assessing, recommending, explaining why) is refused before any
//    agent spawns. The screen is deliberately fail-closed: a refused
//    brief goes back to the lead, and rewording it past the screen is
//    itself a routing failure.
// 2. Evidence without a cited source is dropped and the task is
//    reported incomplete, so uncited prose can never reach the lead
//    as a fact to act on. The lead still opens the cited line or
//    re-runs the quoted command before using any returned fact.

const SPARK_MODEL = "muse-spark-1.3";
const SPARK_EFFORT = "medium";

const JUDGMENT_TERMS =
  /\b(review|audit|assess|assessing|evaluate|evaluating|judge|judgment|decide|decision|recommend|relevant|relevance|appropriate|best|should|why|explain|diagnose|diagnosis|choose|choosing)\b/i;

function isJudgmentBrief(input) {
  return JUDGMENT_TERMS.test(String(input ?? ""));
}

function isCitedSource(source) {
  if (typeof source !== "string") return false;
  const trimmed = source.trim();
  return /^.+:\d+$/.test(trimmed) || /^command:\s*\S/.test(trimmed);
}

const CONTRACT = [
  "You are a spark agent doing dummy work: fetching, locating, extracting, and running named read-only commands.",
  "Read and run only: never edit, create, move, or delete a file, and never change git state.",
  "Answer exactly the brief, nothing else. Every evidence item is one fact with its source: source is exactly a file:line reference (path:123) for a fact taken from a file, or command: followed by the exact command whose output produced the fact.",
  "Never compute a count, total, or version yourself when a command can produce it: run the command and cite it as command: in the source for that fact.",
  "If any part of the brief requires deciding what is relevant, assessing, recommending, choosing, or explaining why, do not answer that part: name it under unresolved as judgment for the lead.",
  "If the brief asks for something a repository script already produces exactly, name that script under unresolved and do not estimate the answer.",
  "Keep evidence compact: one fact per evidence item, no prose summaries.",
  "Name every part you could not complete under unresolved instead of guessing.",
].join("\n");

const evidenceSchema = {
  type: "object",
  required: ["complete", "evidence", "unresolved"],
  properties: {
    complete: { type: "boolean" },
    evidence: {
      type: "array",
      items: {
        type: "object",
        required: ["fact", "source"],
        properties: {
          fact: { type: "string" },
          source: { type: "string" },
        },
      },
    },
    unresolved: { type: "array", items: { type: "string" } },
  },
};

export default async function workflow(host) {
  // The caller may deliver args as an object or as a JSON-encoded string;
  // accept both rather than silently running with no tasks.
  let parsed = args;
  if (typeof parsed === "string") {
    try {
      parsed = JSON.parse(parsed);
    } catch {
      parsed = null;
    }
  }
  const tasks = Array.isArray(parsed?.tasks) ? parsed.tasks : [];
  if (tasks.length === 0) {
    return {
      summary: JSON.stringify({
        status: "no tasks",
        results: [],
        unresolved: ["spark called with no tasks"],
      }),
    };
  }

  phase("spark");
  const allowed = [];
  const allowedIndex = [];
  tasks.forEach((task, index) => {
    if (!isJudgmentBrief(task.input)) {
      allowed.push(task);
      allowedIndex.push(index);
    }
  });
  const spawned = await host.parallel(
    allowed.map((task) => ({
      input: `${task.input}\n\n${CONTRACT}`,
      label: task.label ?? "spark",
      model: SPARK_MODEL,
      effort: SPARK_EFFORT,
      schema: evidenceSchema,
    })),
  );
  const byIndex = new Map(allowedIndex.map((taskIndex, i) => [taskIndex, spawned[i]]));

  const compact = tasks.map((task, index) => {
    if (isJudgmentBrief(task.input)) {
      return {
        label: task.label ?? `task-${index}`,
        ref: null,
        complete: false,
        evidence: [],
        notes: null,
        unresolved: [
          "judgment-bearing brief refused before spawn: route it to the lead, and do not reword it past this screen",
        ],
      };
    }
    const result = byIndex.get(index);
    const failed = result === null || result === undefined || result.error_kind;
    const data = !failed && result.data && typeof result.data === "object" ? result.data : null;
    const rawEvidence = Array.isArray(data?.evidence) ? data.evidence : [];
    const evidence = [];
    const dropped = [];
    for (const item of rawEvidence) {
      const fact = typeof item?.fact === "string" ? item.fact.trim() : "";
      const source = typeof item?.source === "string" ? item.source.trim() : "";
      if (fact && isCitedSource(source)) {
        evidence.push({ fact, source });
      } else {
        dropped.push(`dropped evidence without a cited source, do not act on it: ${fact || "(empty fact)"}`);
      }
    }
    const declared = Array.isArray(data?.unresolved) ? data.unresolved : null;
    return {
      label: task.label ?? `task-${index}`,
      ref: result?.ref ?? null,
      complete:
        data?.complete === true && evidence.length > 0 && dropped.length === 0,
      evidence,
      notes: typeof result?.notes === "string" && result.notes.trim() ? result.notes : null,
      unresolved: failed
        ? [`spark task failed: ${result?.error_kind ?? "not admitted"}`]
        : [...(declared ?? ["spark task returned no structured result"]), ...dropped],
    };
  });

  const unresolved = compact.flatMap((entry) => entry.unresolved);
  const report = {
    status: unresolved.length === 0 && compact.every((entry) => entry.complete) ? "complete" : "partial",
    model: SPARK_MODEL,
    effort: SPARK_EFFORT,
    results: compact,
    unresolved,
  };
  return { summary: JSON.stringify(report) };
}
