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
// read and run only, never write, compact evidence with file:line
// references, and name every unresolved item rather than guess.

const SPARK_MODEL = "muse-spark-1.3";
const SPARK_EFFORT = "medium";

const CONTRACT = [
  "You are a spark agent doing dummy work: fetching, locating, extracting, and running named read-only commands.",
  "Read and run only: never edit, create, move, or delete a file, and never change git state.",
  "Answer exactly the brief, nothing else. Cite file:line for every fact taken from a file.",
  "Never compute a count, total, or version yourself when a command can produce it: run the command and quote it verbatim in the evidence string for that fact.",
  "If the brief asks for something a repository script already produces exactly, name that script under unresolved and do not estimate the answer.",
  "Keep evidence compact: one short string per fact, no prose summaries.",
  "Name every part you could not complete under unresolved instead of guessing.",
].join("\n");

const evidenceSchema = {
  type: "object",
  required: ["complete", "evidence", "unresolved"],
  properties: {
    complete: { type: "boolean" },
    evidence: { type: "array", items: { type: "string" } },
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
  const results = await host.parallel(
    tasks.map((task) => ({
      input: `${task.input}\n\n${CONTRACT}`,
      label: task.label ?? "spark",
      model: SPARK_MODEL,
      effort: SPARK_EFFORT,
      schema: evidenceSchema,
    })),
  );

  const compact = results.map((result, index) => {
    const failed = result === null || result.error_kind;
    const data = !failed && result.data && typeof result.data === "object" ? result.data : null;
    return {
      label: tasks[index].label ?? `task-${index}`,
      ref: result?.ref ?? null,
      complete: data?.complete === true && Array.isArray(data?.evidence) && data.evidence.length > 0,
      evidence: Array.isArray(data?.evidence) ? data.evidence : [],
      notes: typeof result?.notes === "string" && result.notes.trim() ? result.notes : null,
      unresolved: failed
        ? [`spark task failed: ${result?.error_kind ?? "not admitted"}`]
        : (Array.isArray(data?.unresolved) ? data.unresolved : ["spark task returned no structured result"]),
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
