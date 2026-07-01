const targets = [
  ["docs", "http://localhost:8000"],
  ["sample-app", "http://localhost:8080"]
];

const failures = [];

for (const [name, url] of targets) {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      failures.push(`${name} returned HTTP ${response.status}`);
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    failures.push(`${name} is unavailable: ${message}`);
  }
}

if (failures.length > 0) {
  process.stderr.write(`${failures.join("\n")}\n`);
  process.exitCode = 1;
}
